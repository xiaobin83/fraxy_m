local Server = {}

Server._doc = [[
Lowerlevel of game server, handles all things before game started.
And ServerGameModule handles others.]]

local FSM = require 'Utils.FSM'
setmetatable(Server, { __index = FSM })

local Config = require 'Config'
local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[SRV]')

local Utils = require 'Utils.Utils'

local Time = require 'Utils.Time'

local Unity = require 'unity.Unity'
local MsgPack = require 'Game.MsgPack'
local Chan = csharp.checked_import('Networking.Chan') 
local ChanBreakReason = Chan[{csharp.p_nested_type(), 'BreakReason'}]
local Reason_ChanModule = ChanBreakReason.ChanModule

local Delegate = require 'Utils.Delegate'

local _OnConnected
local _OnRecv
local _OnProxyConnected
local _OnProxyRecv
local _SendProxy
local _TickServer

local _LoginToProxy
local _StartGame
local _BroadcastPlayerReady

local _HandleProxyInstantMessage -- uses _HandleIncomingMessage and _HandleInstantMessage
local _HandleIncomingMessage -- uses HandleInstantMessage
local _HandleInstantMessage

local _Debug_OnServiceStarted
local _ChanFromSess
local _ChanFromPlayer
local _MakeSession
local _NextUniqueId

local _uniqueId = 101


local _InitDelegates = function(s)
	s.delegates = {
		onGameStarted = Delegate(),
		onGameEnded = Delegate(),
		loadPlayGround = Delegate(),
		onMsgReceived = Delegate(),
		onFrameUpdated = Delegate(),
		onServerTick = Delegate(),
	}
end

function Server:Awake()

	FSM.Awake(self)

	local Native = csharp.checked_import('Server')
	self.native = assert(self:GetComponent(Native))

	-- init
	self.time = Time.New('server', 'fixed')

	self.sessions = {}

	self.proxy = {
		addr = false,
		chan = false,
		chanEstablished = false,
		chanEncryptedModule = false,
		stackedPacks = {}
	}

	self.messages = {}
	self.nextServerTickTime = 0

	self.sessId2Player = {}
	self.playerId2Sess = {}

	self.players = {}
	self.sessId2PlayerInst = {}
	self.playerId2PlayerInst = {}

	self.gameStarted = false

	_InitDelegates(self)
end


function Server:Serve(port, proxy, serverId, config)

	self.config = config or Config.testServerConfig
	self.port = port
	self.serverId = serverId
	self.networkIdStart = Config.maxNetworkInstancePerClient 
	self.serverNetworkId = Config.serverNetworkIdStart
	self.proxy.addr = proxy 
	if proxy.addr ~= 'none' and proxy.addr ~= 'localhost' then
		self.hasProxy = true
		local onProxyConnected = function(chan)
			_OnProxyConnected(self, chan)
			_LoginToProxy(self, tostring(serverId))
		end
		local onProxyRecv = function(data)
			local ok, err = pcall(_OnProxyRecv, self, data)
			if not ok then
				_LogE('ERROR: ' .. err)
			end
		end
		self.native:ConnectProxy(proxy.addr, proxy.port, onProxyConnected, onProxyRecv)
	end

	local onConnected = function(chan)
		return _OnConnected(self, chan)
	end
	local onRecv = function(id, data)
		local ok, err = pcall(_OnRecv, self, id, data)
		if not ok then
			_LogE('ERROR: ' .. err)
		end
	end

	self.native:Serve(port, onConnected, onRecv)

	self.delegates.loadPlayGround()
	
	_Debug_OnServiceStarted(self)
end

function Server:SendGameMsgByPid(playerId, msg)

end

function Server:SendGameMsgBySid(sessId, msg)

end


function Server:BroadcastGameMsg(name, msg)
	for _, player in ipairs(self.players) do
		local bytes = MsgPack.Pack('game', name, msg, player.id, self.serverId)
		_SendProxy(self, bytes, player.sessId)
	end
end


function Server:GetPlayer(pid)
	local idx = assert(self.playerId2PlayerInst[pid])
	return assert(self.players[idx])
end

local _Broadcast = function(s, proto, name, msg)
	for _, player in ipairs(s.players) do
		local bytes = MsgPack.Pack(proto, name, msg, player.id, s.serverId)
		_SendProxy(s, bytes, player.sessId)	
	end
end

_LoginToProxy = function(s, token)
	_LogT('LoginToProxy ' .. token)
	local bytes = MsgPack.Pack('relay', 'LoginRequest', {token = token})
	_SendProxy(s, bytes)
end

_StartGame = function(s)
	_LogD('StartGame')
	s.gameStarted = true
	_Broadcast(s, 'game', 'StartGame')
	s.delegates.onGameStarted()
end

_EndGame = function(s)
	_LogD('EndGame')
	s.gameStarted = false
	_Broadcast(s, 'game', 'EndGame')
	s.delegates.onGameEnded()
end

_BroadcastPlayerReady = function(s)
	_LogD('_BroadcastPlayerReady')
	local msg = { playerIds = {} }
	for _, p in ipairs(s.players) do
		table.insert(msg.playerIds, p.id)
	end
	s:BroadcastGameMsg('PlayerReady', msg)
end

local Profiler = Unity.Profiling.Profiler
function Server:Update()
	--Profiler.BeginSample('Server.Update')
	if self.gameStarted then
		self.delegates.onFrameUpdated()
		local time = Time.RS() 
		if time > self.nextServerTickTime then
			self.nextServerTickTime = time + Config.serverTickDur 
			_TickServer(self)
		end
	end
	--Profiler.EndSample()
end


_TickServer = function(s)
	--Profiler.BeginSample('_TickServer')
	local msgs = s.messages
	s.messages = {}
	for _, bundle in ipairs(msgs) do
		local gameOp, msg, from = unpack(bundle)
		s.delegates.onMsgReceived(gameOp, msg, from)
	end
	s.delegates.onServerTick()
	--Profiler.EndSample()
end


-- FSM

function Server:FSM_OnOnePlayerReadyToGo()
	if #self.players == self.config.allowedPlayer then
		_StartGame(self)
		self:SendFsmEvent('CE_StartGame')
	end
end

-- connect & recv

----------------------------
-- Proxy
local _FlushProxyStackedPacks = function(s)
	if s.proxy.stackedPacks and #s.proxy.stackedPacks > 0 then
		for _, b in ipairs(s.proxy.stackedPacks) do
			s.proxy.chan:Send(b)
		end
	end
	s.proxy.stackedPacks = false
end

_OnProxyConnected = function(s, chan)

	_LogT('_OnProxyConnected')
	chan.name = 'proxy'
	if Config.useEncryptedChan then 
		_LogT('proxy client using encrypted chan')
		local EncryptedChanModule = require 'Game.EncryptedChanModule'
		local cm = EncryptedChanModule.New()
		cm.onEstablished = function()
			_LogT('encrypted chan established')
			s.proxy.chanEstablished = true
			_FlushProxyStackedPacks(s)
		end
		s.proxy.chanEncryptedModule = cm
		chan:SetChanModule(cm.native)
	else
		s.proxy.chanEstablished = true
	end
	s.proxy.chan = chan
end

_OnProxyRecv = function(s, data)
	--_LogT('_OnProxyRecv ' .. #data .. ' bytes:\n' .. csharp.hex_dump(data))
	local op = MsgPack.Peek(data)

	if op == 'PikeSeedRequest' then
		if not s.proxy.chanEncryptedModule then
			s.proxy.chan:Break(Reason_ChanModule)
			return
		end
		s.proxy.chanEncryptedModule:CheckInitReply(data)
	elseif op == 'SendRequest' then
		-- redirect to server
		local gameOp, msg, from, to = MsgPack.Unpack(data)
		_LogD(tostring(from) .. ' -> ' .. gameOp .. ':' .. tostring(msg))
		assert(to == s.serverId)
		local bundle = {gameOp, msg, from, to}
		_HandleProxyInstantMessage(s, bundle)
	end
end

_SendProxy = function(s, bytes, sessId)
	local chan
	if not sessId then
		chan = s.proxy.chan
	else
		chan = _ChanFromSess(s, sessId)
	end
	if chan == s.proxy.chan then
		if s.proxy.chanEstablished then
			_FlushProxyStackedPacks(s)
			s.proxy.chan:Send(bytes)
		else
			table.insert(s.proxy.stackedPacks, bytes)
		end
	else
		-- local client
		s.sessions[sessId].chan:Send(bytes)
	end
end

----------------------------
_NextUniqueId = function()
	local id = _uniqueId
	_uniqueId = _uniqueId + 1
	return id
end

_OnConnected = function(s, chan)
	_LogT('_OnConnected')
	local chanEncryptedModule
	
	local sessId = _NextUniqueId()

	chan.name = 'serverplayer'..sessId
	
	if Config.useEncryptedChan then
		_LogI('using encrypted chan')
		local EncryptedChanModule = require 'Game.EncryptedChanModule'
		local cm = EncryptedChanModule.New('passive')	
		chanEncryptedModule = cm 
		chan:SetChanModule(cm.native)
	end
	
	local sess = { 
		id = sessId,
		chan = chan,
		chanEncryptedModule = chanEncryptedModule,
	}
	s.sessions[sessId] = sess 
	return sessId
end

_MakeSession = function(s, chan) 
	local sessId = _NextUniqueId()
	local sess = {
		id = sessId,
		chan = chan,
		chanEncryptedModule = false,
	}
	s.sessions[sessId] = sess
	return sessId 
end

_OnRecv = function(s, sessId, data)

	--_LogT('_OnRecv from ' .. tostring(id) .. ' ' .. #data .. ' bytes:\n'..csharp.hex_dump(data))

	local sess = s.sessions[sessId]
	if not sess then 
		_LogE('session ' .. sessId .. ' not found, ignore packet')
		return
	end

	local op = MsgPack.Peek(data)

	if op == 'PikeSeedRequest' then
		if not sess.chanEncryptedModule then
			sess.chan:Break(Reason_ChanModule)
			return
		end
		sess.chanEncryptedModule:CheckInitRequest(sess.chan, data)
	elseif op == 'LoginRequest' then
		-- must be local client connected
		local _, msg = MsgPack.Unpack(data)
		_LogD('LoginRequest' .. _ToString(msg))
		-- simply discard 
	elseif op == 'SendRequest' then
		local gameOp, msg, from, to = MsgPack.Unpack(data)
		assert(gameOp) -- no proxy so there should be no SendReply
		_LogD(tostring(from) .. ' -> ' .. gameOp .. ':' .. _ToString(msg))
		assert(to == s.serverId)
		local bundle = {gameOp, msg, from, to}
		_HandleIncomingMessage(s, sessId, bundle)
	end
end

_HandleProxyInstantMessage = function(s, bundle)
	local gameOp, msg, from, to = unpack(bundle)
	if gameOp == 'Ready' then
		if not s.playerId2Sess[from] then
			local sessId = _MakeSession(s, s.proxy.chan)
			return _HandleInstantMessage(s, sessId, bundle)
		else
			_LogE('player ' .. from .. ' ready twice?')
			-- ignore this message
			return true
		end
	else
		local sessId = assert(s.playerId2Sess[from], 'player ' .. from .. ' not ready?')
		_HandleIncomingMessage(s, sessId, bundle)
	end
end

local _GetPlayerTeam = function(s, pid)
	for name, team in pairs(s.config.team) do
		if Utils.Contains(team, pid) then
			return name
		end
	end
end


_HandleInstantMessage = function(s, sessId, bundle)
	local gameOp, msg, from, to = unpack(bundle)
	if gameOp == 'SyncTime' then
		local bytes = MsgPack.Pack('game', 'SyncTimeAck', {ts = msg.ts, srv_ts = s.time:TS()}, from, s.serverId)
		_SendProxy(s, bytes, sessId)
		return true
	elseif gameOp == 'Ready' then
		s.sessId2Player[sessId] = from
		s.playerId2Sess[from] = sessId
		local networkIdStart = s.networkIdStart + (#s.players + 1) * Config.maxNetworkInstancePerClient
		local player = {
			id = from, 
			sessId = sessId, 
			networkIdStart = networkIdStart,
			team = assert(_GetPlayerTeam(s, from)), -- cached here
		}
		table.insert(s.players, player)
		local index = #s.players
		s.sessId2PlayerInst[sessId] = index
		s.playerId2PlayerInst[from] = index
		local bytes = MsgPack.Pack(
			'game', 'ReadyAck', 
			{ 
				scene = s.config.scene,
				networkId = player.networkIdStart,
			}, 
			from, s.serverId)
		_SendProxy(s, bytes, sessId)
		_BroadcastPlayerReady(s)
		return true
	elseif gameOp == 'ReadyToGo' then
		s:SendFsmEvent('CE_OnePlayerReadyToGo')
	end
end

_HandleIncomingMessage = function(s, sessId, bundle)
	local ate = _HandleInstantMessage(s, sessId, bundle)
	if not ate then
		if s.gameStarted then
			table.insert(s.messages, bundle)
		else
			local gameOp = bundle[1]
			_LogW('game not started, drop ' .. gameOp)
		end
	end
end


_ChanFromPlayer = function(s, playerId)
	local sessId = assert(s.playerId2Sess[playerId])
	return _ChanFromSess(s, sessId)
end

_ChanFromSess = function(s, sessId)
	local sess = assert(s.sessions[sessId])
	return sess.chan
end




------------------
local _ExecuteCommand = function(s, cmd)
	_LogD('execute cmd: ' .. cmd)
	local chunk, errmsg = load('return function(s)\n' .. cmd .. '\nend\n')
	if not chunk then
		return errmsg
	end
	local f = chunk()
	local _, ret =  pcall(f, s)
	return ret
end

_Debug_OnServiceStarted = function(s)
	if _UNITY['EDITOR'] then
		FSDBG = csharp.checked_import('FullScreenDebugable')
		FSDBG.instance:Editor_AddToolbarButton(
			'server',
			function()
				s.native:Editor_ToggleGUI()
			end
		)
		
		local title = ':'..s.port .. ' <-> '
		if s.hasProxy then
			title = title .. s.proxy.addr.addr .. ':' .. s.proxy.addr.port
		else
			title = title .. ' no proxy'
		end
		s.native:Editor_SetTitle(title)
		local Screen = Unity.Screen
		local x = Screen.width / 4
		local y = Screen.height / 4
		local width = Screen.width / 2
		local height = Screen.height / 2
		s.native:Editor_SetArea(x, y, width, height)
		s.native:Editor_SetCmdHandler(
			function(cmd)
				local r = _ExecuteCommand(s, cmd)
				FSDBG.instance:Editor_PopUp('server> '..tostring(r)..'\n')
			end
		)
	end
end


return Server
