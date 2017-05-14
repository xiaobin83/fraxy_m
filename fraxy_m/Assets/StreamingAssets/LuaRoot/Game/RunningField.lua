local Global = require 'Game/Global'

local import = csharp.checked_import
local Camera = import('UnityEngine.Camera')
local GameObject = Global.GameObject
local Resources = import('UnityEngine.Resources')
local Droid = require 'Game/Droid'
local Bridge = require 'Game/Bridge'


local R = {}

function R:Awake()
	self.mainCamera = Bridge.FindLBT(self, 'MainCamera')
	self.UI = Bridge.FindLBT(self, 'UI')
	Global.RunningField = self
end

function R:Start()
	self.UI:AddFunc(
		"New Part",
		function()
			if not self.droid then
				local part = Droid:NewPart('ControlledCore')
				self:SetDroid(part)
			else
				local node = self.UI:GetSelectedPartNode()
				if node then
					local part = Droid:NewPart('Deco_01')
					self:Attach(part, node)
				else
					-- select a part
				end
			end
		end)
end



function R:NewSprite(spriteName)
	local go = Bridge.LoadSprite(spriteName)
	local t = Bridge.GetLBT(go)
	t.Destroy = DestroyGameObject
	return t
end

function R:SetDroid(part)
	if self.droid then
		self.droid:Destroy()
	end
	if part then
		self.droid = part
		self.mainCamera:SetTarget(part)
		part.transform:SetParent(self.transform)
		part:Reset()
		self.UI:SetRootPart(part)
	end
end

function R:Attach(part, node)
	local parent = node.item
	part.gameObject.transform:SetParent(parent.gameObject.transform, false)
	parent.subparts[#parent.subparts+1] = part
	self.UI:AttachPart(part, node)
end

function R:Reset()
	if self.droid then
		self.droid:Reset()
	end
end


return R