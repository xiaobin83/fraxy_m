local ClientGameModule = {}

local Config = require 'Config'
local _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[CGM]')

local ActorType = require 'Game.ActorType'

local _R = require 'Utils.ResMgr'
local PlayGround = require 'Game.PlayGround'
local Scene = require 'Game.Scene'

local MH = require 'Game.MsgHelper'
local _MHGV3 = MH.GetVector3
local _MHGV4 = MH.GetVector4

local Unity = require 'Unity'
local Profiler = Unity.Profiling.Profiler

local Delegate = require 'Utils.Delegate'

local _M = {}

function _M:LoadScene(sceneName, complete)
	Scene.CreateOrRetain(
		sceneName, 
		function(scene)
			self.scene = scene,
			PlayGround.CreateOrRetain(
				{ role = 'client' },
				function(playGround)
					self.playGround = playGround
					complete()
				end
			)
		end
	)
end

function _M:RespawnActor(type, pos)
	local msg = {} 
	local nid = self.ref.client:NextNetworkId()
	msg.nid = nid 
	msg.type = type
	msg.pos = pos
	self.ref.client:SendGameMsg('RespawnActor', msg)
	local agent = self.playGround:RespawnNetworkActor(
		self.ref.client.id, nid, self.ref.client.team, type, pos, self.ref.client.time)
	self.networkAgents[nid] = agent
end

local _FinalizeRespawningActor = function(self, pid, nid, type, pos)
	local agent = self.networkAgents[nid]
	if not agent then
		-- other client's agent
		agent = self.playGround:RespawnNetworkActor(
			pid, nid, self.ref.client:GetTeam(pid), type, pos, self.ref.client.time)
		self.networkAgents[nid] = agent
	end
	agent:Finalize()
end

function _M:Respawn(type, side)
	local point = self.playGround:GetRespawnPoint(self.ref.client.team, side)
	self:RespawnActor(type, point)
end

function _M:TestRespawn(side)
	self:Respawn(ActorType.GetType('goblin'), side)	
end


function _M:OnMsgReceived(op, msg)
	--_LogD('OnMsgReceived')
	Profiler.BeginSample('CGM.OnMsgReceived')
	if op == 'PlayerReady' then
		self.delegates.onPlayerReady(msg)
	elseif op == 'ActorRespawned' then
		_FinalizeRespawningActor(
			self, msg.pid, msg.nid, msg.type,
			_MHGV3(msg.pos))
	elseif op == 'SyncActors' then
		Profiler.BeginSample('CGM.SyncActors')
		local ts = msg.ts -- opt: check if there is big laggy
		local cur = self.ref.client.time:TS()
		local positions = msg.positions
		for _, actorPos in ipairs(positions) do
			local nid = actorPos.nid
			local agent = assert(self.networkAgents[nid])
			agent:SyncPos(cur, ts, actorPos.pos, actorPos.vel, actorPos.rot)
		end
		Profiler.EndSample('CGM.SyncActors')
	end
	Profiler.EndSample()
end


function ClientGameModule.SetUp(client)
	local m = setmetatable({
		ref = setmetatable({}, { __mode = 'v' }),
		delegates = {
			onPlayerReady = Delegate(),
		},
		networkAgents = {},
	}, { __index = _M })
	m.ref.client = client
	client._cgm = m
	m._LoadScene = function(sceneName, complete)
		m:LoadScene(sceneName, complete)
	end
	m._OnMsgReceived = function(op, msg)
		m:OnMsgReceived(op, msg)
	end
	client.delegates.loadScene = client.delegates.loadScene +  m._LoadScene
	client.delegates.onMsgReceived = client.delegates.onMsgReceived + m._OnMsgReceived
	return m
end



return ClientGameModule
