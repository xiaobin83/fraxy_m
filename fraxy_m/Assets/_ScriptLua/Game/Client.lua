local Client = {}

local Config = require 'Config'
local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[CLI]')

local FSM = require 'Utils.FSM'
setmetatable(Client, { __index = FSM } )


local Time = require 'Utils.Time'

local Unity = require 'unity.Unity'
local Profiler = Unity.Profiling.Profiler
local MsgPack = require 'Game.MsgPack'
local Utils = require 'Utils.Utils'

local Chan = csharp.checked_import('networking.Chan') 
local ChanBreakReason = Chan[{csharp.p_nested_type(), 'BreakReason'}]
local Reason_ChanModule = ChanBreakReason.ChanModule

local _OnConnected
local _OnRecv
local _Send


local Delegate = require 'Utils.Delegate'
local _InitDelegates = function(s)
	s.delegates = {
		loadScene = Delegate(),
		onMsgReceived = Delegate(),
	}
end


function Client:Awake()

	FSM.Awake(self)

	local Native = csharp.checked_import('Client')
	self.native = assert(self:GetComponent(Native))

	-- init
	self.serverId = 0 
	self.networkId = false 
	self.networkIdEnd = false
	self.chanEstablished = false

	_InitDelegates(self)
end



function Client:Connect(address, port, id, serverId, config, dbgAnchor)
	self.config = config or Config.testClientConfig
	self.id = id
	self.team = assert(self:GetTeam(id))
	self.time = Time.New('client' .. id)
	self.address = (not address or address == 'none') and 'localhost' or address
	self.port = self.address == 'localhost' and Config.localServerPort or port
	self.serverId = serverId or self.serverId
	self.dbgAnchor = dbgAnchor
	self:SendFsmEvent('CE_StartConnect')
end

function Client:GetTeam(pid)
	for name, team in pairs(self.config.team) do
		if Utils.Contains(team, pid) then
			return name
		end
	end
end

function Client:NextNetworkId()
	local r = assert(self.networkId)
	self.networkId = self.networkId + 1
	return r
end

function Client:SendGameMsg(name, msg)
	local bytes = MsgPack.Pack('game', name, msg, self.serverId, self.id)
	_Send(self, bytes)
end

-- connect & recv
local _Debug_OnConnected

_OnConnected = function(s, chan)
	_LogT('_OnConnected')
	chan.name = 'client'
	if Config.useEncryptedChan then
		_LogI('client using encrypted chan')
		local EncryptedChanModule = require 'Game.EncryptedChanModule'
		local cm = EncryptedChanModule.New()
		cm.onEstablished = function()
			_LogT('encrypted chan established')
			s.chanEstablished = true 
			s:SendFsmEvent('CE_Connected')
		end
		s.chanEncryptedModule = cm
		chan:SetChanModule(cm.native)
	else
		s.chanEstablished = true
		s:SendFsmEvent('CE_Connected')
	end
	s.chan = chan
	_Debug_OnConnected(s)
end

_OnRecv = function(s, data)
	--_LogT('_OnRecv ' .. #data .. ' bytes:\n'..csharp.hex_dump(data))

	local op = MsgPack.Peek(data)

	if op == 'PikeSeedRequest' then
		if not s.chanEncryptedModule then
			s.chan:Break(Reason_ChanModule)
			return
		end
		s.chanEncryptedModule:CheckInitReply(data)
	elseif op == 'SendRequest' then
		Profiler.BeginSample('Client.MsgPack.Unpack')
		local gameOp, msg = MsgPack.Unpack(data)
		Profiler.EndSample()
		--_LogD(gameOp .. ':' .. tostring(msg))
		if gameOp == 'SyncTimeAck' then
			s.time:RecvDelta(msg.ts, msg.srv_ts)
		elseif gameOp == 'ReadyAck' then
			s.networkId = msg.networkId
			s.networkIdEnd = msg.networkId + Config.maxNetworkInstancePerClient
			s.sceneToLoad = msg.scene
			s:SendFsmEvent('CE_ReadyAcked')
		elseif gameOp == 'StartGame' then
			s:SendFsmEvent('CE_StartGame')
		elseif gameOp == 'Echo' then
			_LogI('Echo back ' .. msg.content)
		else
			Profiler.BeginSample('Client.onMsgReceived')
			s.delegates.onMsgReceived(gameOp, msg)
			Profiler.EndSample()
		end
	end


end

_Send = function(s, bytes)
	assert(s.chanEstablished)
	s.chan:Send(bytes)
end

-- commands

local _Login = function(s)
	local bytes = MsgPack.Pack('relay', 'LoginRequest', {token = tostring(s.id)})
	_Send(s, bytes)
end

local _SyncTimeCo = function(s)
	local co = coroutine.create(
		function()
			s.time:StartSyncTime()
			for i = 1, Config.timeSyncTimes do
				local bytes = MsgPack.Pack('game', 'SyncTime', { ts = s.time:TS() }, s.serverId, s.id)
				_Send(s, bytes)
				coroutine.yield(Unity.WaitForSeconds(Config.timeDurationBetweenTwoSyncPacks))
			end
			s.time:EndTimeSync()
		end)
	return co
end

local _SyncTime = function(s)
	_LogI('SyncTime')
	s:StartLuaCoroutine(_SyncTimeCo(s))
end

local _Ready = function(s)
	_LogI('Ready')
	local bytes = MsgPack.Pack('game', 'Ready', nil, s.serverId, s.id)
	_Send(s, bytes)
end

local _ReadyToGo = function(s)
	_LogI('ReadyToGo')
	local bytes = MsgPack.Pack('game', 'ReadyToGo', nil, s.serverId, s.id)
	_Send(s, bytes)
end

-- commands 

function Client:Echo(content)
	_LogI('Echo ' .. content)
	local bytes = MsgPack.Pack('game', 'Echo', {content = content}, self.serverId, self.id)	
	_Send(self, bytes)
end

function Client:Words(content)
	_LogI('Words ' .. content)
	local bytes = MsgPack.Pack('game', 'Words', {content = content}, self.serverId, self.id)
	_Send(self, bytes)
end

-- FSM 

function Client:FSM_OnStartConnect()
	local onConnected = function(chan)
		_OnConnected(self, chan, self.dbgAnchor)
	end
	local onRecv = function(data)
		local ok, err = pcall(_OnRecv, self, data)
		if not ok then
			_LogE('ERROR: ' .. err)
		end
	end
	self.native:Connect(self.address, self.port, onConnected, onRecv)
end

function Client:FSM_OnConnected()
	_Login(self)
	_Ready(self)
end

function Client:FSM_OnReadyAcked()
	_SyncTime(self)
	self.delegates.loadScene(
		self.sceneToLoad, 
		function()
			self:SendFsmEvent('CE_SceneLoaded')
		end)
end

function Client:FSM_OnReadyToGo()
	_ReadyToGo(self)
end

function Client:FSM_OnGameStarted()
	-- todo:
	_LogD('FSM_OnGameStarted ' .. self.id)
end

-- debug

local _ExecuteCommand = function(s, cmd)
	_LogD('execute cmd: ' .. cmd)
	local chunk, errmsg = load('return function(s)\n' .. cmd .. '\nend\n')
	if not chunk then
		_LogE(errmsg)
		return errmsg
	end
	local f = chunk()
	local ok, ret =  pcall(f, s)
	if not ok then
		_LogE(ret)
	end
	return ret
end

_Debug_OnConnected = function(s)
	if _UNITY['EDITOR'] then
		FSDBG = csharp.checked_import('FullScreenDebugable')
		FSDBG.instance:Editor_AddToolbarButton(
			'[' .. s.id .. ']',
			function()
				s.native:Editor_ToggleGUI()
			end
		)
		local Screen = Unity.Screen
		if s.dbgAnchor == 'left' then
			s.native:Editor_SetArea(0, 400, 400, Screen.height - 400)
		elseif s.dbgAnchor == 'right' then
			s.native:Editor_SetArea(Screen.width - 400, 400, 400, Screen.height - 400)
		end

		s.native:Editor_SetTitle(
			s.address .. ':' .. s.port .. ' [' .. s.id .. ']'
		)
		s.native:Editor_SetCmdHandler(
			function(cmd)
				local r = _ExecuteCommand(s, cmd)
				FSDBG.instance:Editor_PopUp('client> ' .. tostring(r) .. '\n')
			end
		)
		s.native:Editor_AddButton(
			'Echo', 
			function ()
				s:Echo('Hello World!') -- Utils.RandomString(10))
			end)
	end
end


return Client
