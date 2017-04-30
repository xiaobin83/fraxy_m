local Debug = true

local Bridge = {}
local Global = require('Game/Global')
local LuaBridge = csharp.checked_import('LuaBridge')
local Input = require('Input')
local Timer = require('Timer')
local Debug = require('Debug')

local UpdateInputPerSecond

function Bridge:Awake()
	if Debug then
		local debuggee = require 'vscode-debuggee'
		local json = require 'json'
		local result, type = debuggee.start(json, {})
		Debug.Log('start debug '.. type .. ' ' .. tostring(result))
		self.debuggeePoll = debuggee.poll
	end
	self.bridge = LuaBridge.current
	Global.Bridge = self
	UpdateInputPerSecond = function()
		Input:DetectController(self)
		Timer.After(1, UpdateInputPerSecond)	
	end
	UpdateInputPerSecond()
end

function Bridge:LoadSprite(spriteName)
	return self.bridge:LoadSprite(spriteName)
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

return Bridge