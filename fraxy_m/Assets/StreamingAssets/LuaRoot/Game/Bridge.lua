local Bridge = {}
local LuaBridge = csharp.checked_import('LuaBridge')
local LuaBehaviour = csharp.checked_import('lua.LuaBehaviour')
local Input = require('Input')
local Timer = require('Timer')
local Debug = require('Debug')

local UpdateInputPerSecond

function Bridge:Awake()
	self.bridgeToNative = LuaBridge.current
	UpdateInputPerSecond = function()
		Input:DetectController(self)
		Timer.After(1, UpdateInputPerSecond)	
	end
	UpdateInputPerSecond()
	Bridge.current = self
end


function Bridge:OnJoystickConnected(name, state)
	Debug.Log("Bridge - Joystick connected " .. name)
end

function Bridge:OnJoystickDisconnected(name, state)
	Debug.Log("Bridge - Joystick disconnected " .. name)
end

function Bridge:Update()
	Timer.Update()
end

function Bridge.LoadSprite(spriteName)
	local c = Bridge.current
	if not c then return nil end
	return c.bridgeToNative:LoadSprite(spriteName)
end

function Bridge.GetLBT(lbObj)
	return lbObj:GetComponent(LuaBehaviour):GetBehaviourTable()
end

function Bridge.FindLBT(lbObj, name)
	return Bridge.GetLBT(lbObj:FindGameObject(name))
end

function Bridge.AddScript(obj, scriptName)
	local lb = obj:AddComponent(LuaBehaviour)
	lb:LoadScript(scriptName)
	return lb:GetBehaviourTable()
end

return Bridge