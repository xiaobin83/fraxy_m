local FSM = {}

local Unity = require 'unity.Unity'
local Utils = require 'Utils.Utils'

local gLis = {}

function FSM._Init(inst)
	inst.name = 'none'
end

function FSM:Awake()
	if self.name ~= 'none' then
		local comps = self:GetComponents(Unity.PlayMakerFSM)
		for i = 0, comps.Length - 1 do
			local comp = comps[i]
			if comp.FsmName == self.name then
				self.fsm = comp 
				break
			end
		end
	else
		self.fsm = self:GetComponent(Unity.PlayMakerFSM)
	end
	self.lis = {}
end

function FSM:SendFsmEvent(eventName, toAllChildren)
	if toAllChildren then
		local fsms = self:GetComponentsInChildren(Unity.PlayMakerFSM)
		local count = fsms.Length
		for i = 0, count - 1 do
			fsms[i]:SendEvent(eventName)
		end
	else
		self.fsm:SendEvent(eventName)
	end
end

function FSM:OnBtnClicked(evtName)
	self:SendFsmEvent('CE_BtnClicked_'..evtName)
end

function FSM.BroadcastFsmEvent(eventName)
	Unity.PlayMakerFSM.BroadcastEvent(eventName)
end

function FSM:MessageFromFSM(msg)
	local params = Utils.StringSplit(msg, ',')	
	if #params > 0 then
		local li = params[1]
		local func = self.lis[li] or gLis[li]
		if func then
			func(params)
		end
	end
end

function FSM:SetFsmString(name, value)
	local vars = self.fsm.FsmVariables
	local var = vars:FindFsmString(name)
	var.Value = tostring(value)
end

function FSM:SetFsmInt(name, value)
	local vars = self.fsm.FsmVariables
	local var = vars:FindFsmInt(name)
	var.Value = value
end

function FSM:AddListener(msg, func)
	if lis[msg] then return false end
	lis[msg] = func
	return true
end

function FSM:RemoveListener(msg)
	self.lis[msg] = nil
end

function FSM.AddGlobalListener(msg, func)
	if gLis[msg] then return false end
	gLis[msg] = func
	return true
end

function FSM.RemoveGlobalListener(msg)
	gLis[msg] = nil
end

function FSM.ClearAllGlobalListeners()
	gLis = {}
end


return FSM
