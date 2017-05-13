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
			if not self.dorid then
				local part = Droid:NewPart('controlledCore')
				self:SetDroid(Droid:Build({part}))
			end
		end)
end

local function DestroyGameObject(bt, delay)
	if delay then
		GameObject.Destroy(tbl.gameObject, delay)
	else
		GameObject.Destroy(tbl.gameObject)
	end
end

local function NewGameObject(name, script)
	local go = GameObject(name or 'GameObject')
	local t = Bridge.AddScript(go, script)
	t.Destroy = DestroyGameObject
	return t
end

function R:NewPart(name)
	return NewGameObject(name, 'Game/PartBehaviour')
end

function R:NewSprite(spriteName)
	local go = Bridge.LoadSprite(spriteName)
	local t = Bridge.GetLBT(go)
	t.Destroy = DestroyGameObject
	return t
end

function R:SetDroid(droid)
	if self.droid then
		self.droid:Destroy()
	end
	if droid then
		self.droid = droid
		self.mainCamera:SetTarget(droid)
		droid.transform:SetParent(self.transform)
		droid:Reset()
	end
end

function R:Reset()
	if self.droid then
		self.droid:Reset()
	end
end


return R