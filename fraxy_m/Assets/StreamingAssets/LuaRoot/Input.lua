local Input = {}

local NI = csharp.checked_import('UnityEngine.Input')

local names = {}

function Input:DetectContrroller(delegate)
	local joysticks = NI.GetJoystickNames()
	local len = joysticks.Length
	local connectedJoySticks = {}
	for _, state in pairs(names) do
		state.shouldDisconnect = true	
	end
	if len > 0 then
		for i = 1, len do
			local n = joysticks[i-1] -- c# array
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
	local newNames = {}
	for n, state in pairs(names) do
		if not state.shouldDisconnect then
			newNames[n] = state
		else
			delegate:OnJoystickDisconnected(n, state)
		end
	end
	names = newNames
end

return Input