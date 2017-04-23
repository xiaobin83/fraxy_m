local Global = require 'Game/Global'

local import = csharp.checked_import
local GameObject = import('UnityEngine.GameObject')
local LuaBehaviour = import('lua.LuaBehaviour')
local Resources = import('UnityEngine.Resources')

local R = {}

function R:Awake()
	Global.RunningField = self
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
	local lb = go:AddComponent(LuaBehaviour)
	lb:LoadScript(script)
	local t = lb:GetBehaviourTable()
	t.Destroy = DestroyGameObject
	return t
end

function R:NewPart(name)
	return NewGameObject(name, 'Game/PartBehaviour')
end

function R:NewSprite(spriteName)
	local go = Global.Bridge:LoadSprite(spriteName)
	local lb = go:AddComponent(LuaBehaviour)
	lb:LoadScript('Game/SpriteBehaviour')
	local t = lb:GetBehaviourTable()
	t.Destroy = DestroyGameObject
	return t
end

function R:SetDroid(droid)
	if self.droid then
		self.droid:Destroy()
	end
	if droid then
		self.droid = droid
		droid.transform:SetParent(self.transform)
		droid:Reset()
	end
end


return R