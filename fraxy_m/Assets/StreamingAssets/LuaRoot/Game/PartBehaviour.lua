local Part = {}

local G = require("Game/Global")

function Part:Awake()
	self.var = {}
end

function Part:CreateSprite()
	if self.sprite then
		self.sprite:Destroy()
		self.sprite = nil
	end
	local spr = G.RunningField:NewSprite(self.type.sprite)
	spr.transform:SetParent(self.transform)
	self.sprite = spr
end

function Part:CreateScript()
	local script = self.type.script
	self.func_attach = script.Attach
	self.func_detach = script.Detach
	self.func_start = script.Start
	self.func_stop = script.Stop
	self.func_step = script.Step
	self.func_reset = script.Reset
end

function Part:SetType(type)
	if self.func_stop then
		self:func_stop()
		self:func_detach()
	end
	self.type = type
	self:CreateSprite()
	self:CreateScript()
	self:func_attach()
	self:func_start()
end

function Part:Update()
	self:func_step()
	self.sprite:OnStatusUpdated(self)
end

function Part:Reset()
	self:func_reset()
end

return Part
