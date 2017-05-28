local Part = {}
local Global = require 'Game/Global'
local UnityEngine = require 'UnityEngine'
local Debug = require 'Debug'
local PartType = require 'Game/PartType'
local T = require 'Text'
local Prop = require 'Game/UI/Prop'

function Part:Awake()
	self.var = {}
	self.subparts = {}
	self.props = {}
	self.data = {}
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

	if self.script then
		if self.script.Stop then
			self.script.Stop(self)
		end
		if self.script.Detach then
			self.script.Detach(self)
		end
	end

	self.data.name = self.data.name or type.name

	self.props = {}
	self.props.name = Prop.New { 
		get = function()
			return self.data.name
		end,
		set = function(value)
			self.data.name = value
		end,
		inspector = {
			name = 'Input',
			title = T('PartName'),
			placeholder = self.data.name,
			content_type = 'Alphanumeric'
		}
	}
	
	self.props.type = Prop.New {
		get = function()
			return self.data.value
		end,
		set = function(value)
			self.data.type = value
		end,
		inspector = {
			name = 'DropDown',
			title = 'Type',
			list = PartType,
			selected = self.data.type.name
		}
	}
	
	
	
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
