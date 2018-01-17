local ServerGameModule = {}

local Config = require 'Config'
local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[SGM]')

local Math = require 'Math.Math'
local TU = Math.Vector3.ToUnity
local FU = Math.Vector3.FromUnity
local FU4 = Math.Vector4.FromUnity

local MsgHelper = require 'Game.MsgHelper'
local _MHGV3 = MsgHelper.GetVector3
local _MHGV4 = MsgHelper.GetVector4

local Utils = require 'Utils.Utils'


local PlayGround = require 'Game.PlayGround'


local AI = require 'Game.AI'
local PathFinding = require 'Game.AgentBehaviour.PathFinding'

local Unity = require 'Unity'
local Profiler = Unity.Profiling.Profiler

local _S = {}

function _S:OnGameStarted()
	if _UNITY['EDITOR'] then
		self.ref.server.native:Editor_AddStatsString(
			'AI',
			function()
				return AI.GetProfString()
			end		
		)
	end

	AI.Resume()
end

function _S:LoadPlayGround(complete)
	PlayGround.CreateOrRetain(
		{ role = 'server' },
		function(playGround)
			self.playGround = playGround
		end
	)
end

function _S:OnMsgReceived(op, msg, from)
	_LogD('OnMsgReceived')
	if op == 'RespawnActor' then
		local pos = _MHGV3(msg.pos)
		local nid = msg.nid
		assert(not self.agents[nid])
		assert(not self.stat.agents[nid])
		local player = assert(self.ref.server:GetPlayer(from))
		local agent = self.playGround:RespawnActor(
			player.id, nid, 
			player.team, msg.type, pos,
			self.ref.server.time)
		if agent then
			self.agents[nid] = agent

			self.stat.agents[nid] = {
				dirty = false,
				pos = pos,
			}
			local res = {}
			res.pid = from
			res.nid = msg.nid
			res.type = msg.type
			res.pos = msg.pos
			self.ref.server:BroadcastGameMsg('ActorRespawned', res)
		end
	end

end

function _S:OnServerTick()
	Profiler.BeginSample('SGM.OnServerTick')
	local msg = {}
	local dur = Config.serverTickDur
	msg.ts = self.ref.server.time:TS()
	msg.positions = {}
	for nid, agent in pairs(self.agents) do
		local s = agent:GetSnapshot()
		if s then
			local actorPos = {}	
			actorPos.nid = nid
			actorPos.pos = s.pos
			actorPos.vel = s.vel
			actorPos.rot = s.rot
			table.insert(msg.positions, actorPos)
		end
	end
	if #msg.positions > 0 then
		self.ref.server:BroadcastGameMsg('SyncActors', msg)
	end
	Profiler.EndSample()
end

function _S:OnFrameUpdated()
	Profiler.BeginSample('AI.Tick')
	AI.Tick()
	Profiler.EndSample()
end

function _S:MoveAgent(nid, pos)
	local agent = assert(self.agents[nid])
	PathFinding.SetDestination(agent, pos)
end

function _S:MoveAgentRandomly(nid, radius)
	local agent = assert(self.agents[nid])
	PathFinding.RandomWalk(agent, radius)
end

function _S:MoveAllAgentsRandomly(radius)
	local allNids = self:GetAllAgentNIds()
	for _, nid in ipairs(allNids) do
		self:MoveAgentRandomly(nid, radius)
	end
end

function _S:GetAllAgentNIds()
	local nids = {}
	for nid, _ in pairs(self.agents) do
		table.insert(nids, nid)
	end
	return nids
end

-- called by mutiple agents
local _Approximate3 = Math.Vector3.Approximate
local _Approximate4 = Math.Vector4.Approximate
function _S:OnAgentUpdated(agent)
	Profiler.BeginSample('Server.OnAgentUpdated')	
	local nid = agent.nid
	local trans = agent.trans
	local pos = FU(trans.position)
	local rotVec = FU4(trans.rotation)
	local vel = FU(agent.navAgent.velocity)
	local stat = self.stat.agents[nid]
	if false 
	or not _Approximate3(stat.pos, pos)
	or (stat.rotVec and not _Approximate4(stat.rotVec, rotVec))
	or (stat.vel and not _Approximate3(stat.vel, vel)) then
		stat.pos = pos
		stat.rotVec = rotVec
		stat.vel = vel
		stat.dirty = true 
	end
	Profiler.EndSample()
end



-- console
function _S:ListAllNIds()
	return Utils.StringJoin(',', self:GetAllAgentNIds())
end

-------------------------

function ServerGameModule.SetUp(server)
	local m = setmetatable({
		ref = setmetatable({}, { __mode = 'v' }),
		agents = {}, -- networkId -> agent 
		stat = {
			agents = {} --> networkId to (pos, rot) to sync
		},
	}, { __index = _S })
	m.ref.server = server 
	server._sgm = m

	AI.SetUp {
		groupping = {
			zFar = 8,
			zRear = 2,
			zXYFar = 4,
			xFar = 4, 
			yFar = 4,
			countPerGroup = 4,
			disLimitToGroup = 10,
			disLimitForGroupTarget = 60,
			findTargetCd = 4,
		}
	}
	server.delegates.onGameStarted = server.delegates.onGameStarted
		+ function() m:OnGameStarted() end
	server.delegates.loadPlayGround = server.delegates.loadPlayGround 
		+ function(sceneName, complete) m:LoadPlayGround(sceneName, complete) end
	server.delegates.onMsgReceived = server.delegates.onMsgReceived 
		+ function(op, msg, from) m:OnMsgReceived(op, msg, from) end
	server.delegates.onServerTick = server.delegates.onServerTick 
		+ function() m:OnServerTick() end
	server.delegates.onFrameUpdated = server.delegates.onFrameUpdated 
		+ function() m:OnFrameUpdated() end
end


return ServerGameModule
