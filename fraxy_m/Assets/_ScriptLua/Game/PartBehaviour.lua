local Part = {}
local Global = require 'Game.Global'
local Unity = require 'unity.Unity'
local Debug = require 
local PartType = require 'Game.PartType'
local T = require 'Text'
local Prop = require 'Game.UI.Prop'

function Part:Awake()
	self.var = {}
	self.subparts = {}
end

function Part:CreateSprite(sprite)
	if self.sprite then
		self.sprite:Destroy()
		self.sprite = nil
	end
	local spr = Global.RunningField:NewSprite(sprite)
	spr.transform:SetParent(self.transform)
	self.sprite = spr
end

function Part:CreateScript()
	self.script = self.type.script
end

function Part:SetType(type)

	if self.script then
		if self.script.Stop then
			self.script.Stop(self)
		end
		if self.script.Detach then
			self.script.Detach(self)
		end
	end


	self:CreateSprite(type.sprite)
	self:Deserialize(type.serializable)

	self.type = type
	self.script = type.script
	if self.script.Attach then
		self.script.Attach(self)
	end
	if self.script.Start then
		self.script.Start(self)
	end


end

function Part:Deserialize(serializable)
	local s = {} -- from somewhere
	setmetatable(s, { __index = serializable })
	self.s = s
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

function Part:OnInspectorGUI(inspector)
	if self.script.OnInspectorGUI then
		self.script.OnInspectorGUI(self, inspector)
	end
end

function Part:Event_PointerClick(evtData)
	_LogD('OnPointerClick ' .. self.type.internalName)
end

return Part
