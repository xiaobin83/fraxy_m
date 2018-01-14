local Unity = require 'unity.Unity'
local Math = require 'unity.Math'

local Input = {}

local NI = Unity.Input 

local names = {}
local controllers = {}
local toRemove = {}

function Input:GetFirstAvailableController()

end

function Input:DetectController(delegate)

	local joysticks = NI.GetJoystickNames()
	local len = joysticks.Length
	local connectedJoySticks = {}
	for _, state in pairs(names) do
		state.shouldDisconnect = true	
	end
	if len > 0 then
		for i = 1, len do
			local n = joysticks[i-1] -- c# array
			if n and #n > 0 then 
				local state = names[n]
				if not state then
					local newState = { shouldDisconnect = false }
					names[n] = newState
					delegate:OnJoystickConnected(n, newState)
				else
					state.shouldDisconnect = false
				end
			end
		end
	end
	
	local hasDisconnectedJoystick = false
	for n, state in pairs(names) do
		if state.shouldDisconnect then
			delegate:OnJoystickDisconnected(n, state)
			toRemove[#toRemove + 1] = n
			hasDisconnectedJoystick = true
		end
	end
	if hasDisconnectedJoystick then
		for _, n in ipairs(toRemove) do
			names[n] = nil
		end
		toRemove = {}
	end

end


function Input.Dir()
	return Math.Vector2(NI.GetAxis('Horizontal'), NI.GetAxis('Vertical'))
end

function Input.Aim()
	return Math.Vector2(NI.GetAxis('Horizontal2'), NI.GetAxis('Vertical2'))
end

function Input.LT()
	return NI.GetAxis('LT')
end

function Input.RT()
	return NI.GetAxis('RT')
end

return Input