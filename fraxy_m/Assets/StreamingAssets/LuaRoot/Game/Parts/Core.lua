local Boost = require 'Game/Parts/Boost'
local Core = {}


function Core:Attach(part)
end

function Core:Start(part)
	local boostParts = {}
	part:Traverse(function(p)
		local isBoost, type = Boost.Check(p)
		if isBoost then
			boostParts[type] = p
		end
	end)
end

return Core