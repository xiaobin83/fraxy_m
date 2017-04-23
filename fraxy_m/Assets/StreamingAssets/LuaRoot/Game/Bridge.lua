local Bridge = {}
local Global = require('Game/Global')
local LuaBridge = csharp.checked_import('LuaBridge')
local Input = require('Input')
local Timer = require('Timer')
local Debug = require('Debug')

local function UpdateInputPerSecond()
	Input:DetectController(self)
	Timer:After(1, UpdateInputPerSecond)
end

function Bridge:Awake()
	self.bridge = LuaBridge.current
	Global.Bridge = self
	UpdateInputPerSecond()
end

function Bridge:LoadSprite(spriteName)
	return self.bridge:LoadSprite(spriteName)
end

function Bridge:OnJoystickConnected(name, state)
	Debug.Log("Joystick connected " .. name)
end

function Bridge:OnJoystickDisconnected(name, state)
	Debug.Log("Joystick disconnected " .. name)
end

function Bridge:Update()
	Timer:Update()
end

return Bridge