local Unity = require 'unity.Unity'
local Input = require 'Input'
local Timer = require 'Timer'
local Debug = require 'unity.Debug'
local GameObject = Unity.GameObject

local Bridge = {}

local UpdateInputPerSecond

function Bridge:Awake()
	UpdateInputPerSecond = function()
		Input:DetectController(self)
		Timer.After(1, UpdateInputPerSecond)	
	end
	UpdateInputPerSecond()
end


function Bridge:OnJoystickConnected(name, state)
	_LogD("Bridge - Joystick connected " .. name)
end

function Bridge:OnJoystickDisconnected(name, state)
	_LogD("Bridge - Joystick disconnected " .. name)
end

function Bridge:Update()
	Timer.Update()
end



return Bridge