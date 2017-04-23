local Debug = require 'Debug'
local Global = require 'Game/Global'
local Droid = require 'Game/Droid'

local UI_C = {}


function UI_C:AddPart()
	Debug.Log('AddPart')
	local R = Global.RunningField
	if not R then
		Debug.LogError('Running field not loaded')
		return
	end

	if not R.droid then
		local part = Droid:NewPart('controlledCore')
		R:SetDroid(Droid:Build({ part }))
	end
	
end


return UI_C