local Part = {}
local Global = require("Game/Global")
local Debug = require 'Debug'

function Part:Awake()
	self.var = {}
	self.subparts = {}
end

function Part:CreateSprite()
	if self.sprite then
		self.sprite:Destroy()
		self.sprite = nil
	end
	local spr = Global.RunningField:NewSprite(self.type.sprite)
	spr.transform:SetParent(self.transform)
	self.sprite = spr
end

function Part:CreateScript()
	self.script = self.type.script
end

function Part:SetType(type)
	if self.func_stop then
		self:func_stop()
		self:func_detach()
	end
	self.type = type
	self.script = type.script
	self:CreateSprite()
	if self.script.Attach then
		self.script.Attach(self)
	end
	if self.script.Start then
		self.script.Start(self)
	end
end

function Part:Update()
	local f = self.script.Step
	if f then f(self) end
	if self.sprite.OnStatusUpdated then
		self.sprite:OnStatusUpdated(self)
	end
end

function Part:Reset()
	local f = self.script.Reset
	if f then f(self) end
end

function Part:Event_PointerClick(evtData)
	Debug.Log('OnPointerClick ' .. self.type.internalName)
end

return Part
