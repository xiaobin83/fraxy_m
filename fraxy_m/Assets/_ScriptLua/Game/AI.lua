local AI = {}

local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[AI]')

local Unity = require 'Unity'
local Config = require 'Config'
local Utils = require 'Utils.Utils'
local Field = require 'Game.Field'
local Math = require 'Math.Math'
local FU = Math.Vector3.FromUnity
local TU = Math.Vector3.ToUnity
local Time = require 'Utils.Time'
local Profiler = Unity.Profiling.Profiler


local allTeams = {'a', 'b'}
local allLayers = {}
for _, name in ipairs(allTeams) do
	local n = 'Actor_'..name
	allLayers[n] = Unity.LayerMask.NameToLayer(n)
	n = 'Projectile_'..name
	allLayers[n] = Unity.LayerMask.NameToLayer(n)
end

local agents = {}
local agentTicks = {}
local agentNo = 1
local needAddedTick = {}
local team2agentNos = {}

local teamMainBase = {}
local paused  = true

AI.frame = 1
AI.updateFrame = 1
AI.frameDuration = 0
AI.ticksThisFrame = 0
AI.exeTimeExceedsThisFrame = 0
AI.averageTimePerTick = 0.0
AI.totalTimeForTicks = 0.0
AI.totalTicks = 0

-- sub modules
AI.groupping = require 'Game.Groupping'
AI.groupping.ref.AI = AI

function AI.SetUp(config)
	AI.groupping.SetUp(config.groupping)
end

function AI.New(agent)

	agent._agentNo = agentNo
	agent._startFrame = AI.frame
	agentNo = agentNo + 1
	agents[agent._agentNo] = agent
	needAddedTick[agent._agentNo] = { agent, agent.Tick, false ,0}

	local team = agent.team
	local t = team2agentNos[team]
	if not t then
		t = {}
		team2agentNos[team] = t
	end
	t[#t + 1] = agent._agentNo

	if agent.isMainBase then
		teamMainBase[team] = agent._agentNo
	end

	if agent.data and agent.data.isGroupping then
		AI.groupping.Add(agent)
	end

	if not agent.skillName then
		Field.Add(agent)
	end
end

local RemoveAgentInTeam = function(agent)
	local t = team2agentNos[agent.team]
	if t then
		local idx
		for _idx,_agentNo in pairs(t) do
			if(_agentNo == agent._agentNo) then
				idx = _idx
				break
			end
		end
		if idx then
			table.remove(t,idx)
		end
	end
end

function AI.Remove(agent)
	Field.Remove(agent)
	if agent.data and agent.data.isGroupping then	
		if agent._groupLeader then
			agent:ResetTargets()
		end

		AI.groupping.UpdateTeamLeaderTargets(agent)
	end

	agents[agent._agentNo] = nil
	RemoveAgentInTeam(agent)

	if not agentTicks[agent._agentNo] then
		needAddedTick[agent._agentNo][3] = true
		--Unity.Debug.LogError('removing ' .. tostring(agent._agentNo) .. ', but nil found')
	else
		agentTicks[agent._agentNo][3] = true  -- mark to remove
	end
	

	if agent.data and agent.data.isGroupping then
		AI.groupping.Remove(agent)
	end
end

function AI.GetActorLayer(name)
	local n = 'Actor_'..name
	return allLayers[n]
end

function AI.GetProjectileLayer(name)
	local n = 'Projectile_'..name
	return allLayers[n]
end

local nextFrameTag = {}
local TickIterator = function()
	while true do	
		local toRemove = {}
		for agentNo, agentTick in pairs(agentTicks) do
			if agentTick[4] == AI.updateFrame then
				coroutine.yield(nextFrameTag)
			end
			local tick, removed = agentTick[2], agentTick[3]
			if not removed then
				if tick then
					coroutine.yield(agentTick)
				end
			else
				toRemove[#toRemove + 1] = agentNo
			end
		end
		for _,agentNo in ipairs(toRemove) do
			agentTicks[agentNo] = nil
		end
		for _No,tick in pairs(needAddedTick) do
			if not tick[3] then
				agentTicks[_No] = tick
			end
		end
		needAddedTick = {}
		AI.frame = AI.frame + 1

		local cur = Time.RS()
		if AI.lastTickTime then
			AI.frameDuration = cur - AI.lastTickTime 
		end
		AI.lastTickTime = cur
		
		if #agentTicks == 0 then
			coroutine.yield(nextFrameTag)
		end
	end
end

function AI.Pause()
	paused = true
	for _, agent in pairs(agents) do
		agent:PausePathFinding()
	end
end

function AI.Resume()
	paused = false
	AI.totalTimeForTicks = 0.0
	AI.totalTicks = 0
	for _, agent in pairs(agents) do
		agent:ResumePathFinding()
	end
end

function AI.IsPaused()
	return paused
end

local tickIterator
function AI.Tick()
	if not tickIterator then
		tickIterator = coroutine.create(TickIterator)
	end

	local executeTime = 0
	local ticks = 0
	repeat
		local t0 = Time.RS()
		local suc, agentTick = coroutine.resume(tickIterator)
		if suc then
			if agentTick == nextFrameTag then
				local dur = Time.RS() - t0
				executeTime = executeTime + dur
				break
			end
			if agentTick then
				ticks = ticks + 1
				local agent, tick = agentTick[1], agentTick[2]
				local s, err = pcall(tick, agent)
				if not s then
					_LogE('agent ' .. agent._agentNo .. ' raise error: ' .. err)
				else
					agentTick[4] = AI.updateFrame
				end
			end
		else
			_LogE('TickIterator, ' .. agentTick)
		end
		local dur = Time.RS() - t0
		executeTime = executeTime + dur 
	until executeTime + AI.averageTimePerTick > Config.AI_AllowedTimePerFrame
	AI.exeTimeExceedsThisFrame = executeTime - Config.AI_AllowedTimePerFrame
	AI.ticksThisFrame = ticks 
	AI.updateFrame = AI.updateFrame + 1
	AI.totalTimeForTicks = AI.totalTimeForTicks + executeTime 
	AI.totalTicks = AI.totalTicks + ticks
	AI.averageTimePerTick = AI.totalTimeForTicks / AI.totalTicks
end

function AI.GetProfString()
	return string.format([[
frame	AI.frame	AI.dur	ticks	totalTicks	totalTime	avgTime	delta
%d	%d	%.3f	%d	%d	%.3f	%.3f	%.3f
]], 
AI.updateFrame, AI.frame, AI.frameDuration, AI.ticksThisFrame, #agentTicks,
AI.totalTimeForTicks, AI.averageTimePerTick, AI.exeTimeExceedsThisFrame)
end


function AI.NotThisTeam(team)
	local t = {}	
	for _, t_ in ipairs(allTeams) do
		if team ~= t_ then
			t[#t + 1] = t_
		end
	end
	return t
end

function AI.HasAgents(team)
	if team == 'a' then
		return #team2agentNos['b'] > 0
	else
		return #team2agentNos['a'] > 0
	end
end

function AI.GetTeamAgents(team)
	return team2agentNos[team]
end

function AI.GetAgents(teams, types, subTypes, pred)
	local t = {}
	local Containsi = Utils.Containsi
	if teams then
		for _, agentNo in ipairs(teams) do
			local agent = AI.GetAgent(agentNo)
			if agent then
				if not types or Containsi(types, agent.type) then
					if not subTypes or Containsi(subTypes, agent.subType) then
						if not pred or pred(agent) then
							t[#t + 1] = agentNo
						end
					end
				end
			end
		end
	end
	return t
end

function AI.GetAgent(agentNo)
	if agentNo > 0 then
		return agents[agentNo]
	end
end

function AI.GetAgentByTransform(transform)
	for agentNo, agent in pairs(agents) do
		if agent.gameObject.transform == transform then
			return agent;
		end 
	end
	return nil
end

function AI.GetTeamMainBase(team)
	if teamMainBase then
		return AI.GetAgent(teamMainBase[team])
	end
end

function AI.ByDistance(thisAgent, a, b)
	local agentA = agents[a]
	local agentB = agents[b]
	local distA = thisAgent:GetSquaredDistanceTo(agentA)
	local distB = thisAgent:GetSquaredDistanceTo(agentB)
	return distA < distB
end

function AI.SortAgents(thisAgent, agents, cmp)
	cmp = cmp or AI.ByDistance
	table.sort(
		agents,
		function(a, b) return cmp(thisAgent, a, b) end)
end

function AI.GetAgentsCenter(team)
	local ret = Math.Vector3.zero
	if #agents < 2 then
		return nil
	end
	local count = 0
	for _,agent in pairs(agents) do
		if agent.data and agent.data.isGroupping and agent.team == team then
			count = count + 1
			ret = ret + agent:GetPosition()
		end
	end
	if count > 0 then
		ret = ret / count
	end
	return ret
end

function AI.GetEnemyAgentsInCircle(agentNo,team,targetPos,radius)
	local targets = {}
	local agent = AI.GetAgent(agentNo)
	local pos = targetPos
	pos.y = 0
	for _,other in pairs(agents) do
		if other ~= agent  and other.team ~= team then 
			local otherPos = other:GetPosition()
			otherPos.y = 0
			local len = (pos - otherPos):GetLength()
			if len < radius then
				targets[#targets+1] = other._agentNo
			end
		end
	end
	return targets
end


return AI
