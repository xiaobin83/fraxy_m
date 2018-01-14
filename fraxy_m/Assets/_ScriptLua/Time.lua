local Time = {}
local Unity = require 'unity.Unity'
local NT = Unity.Time

local fixedDeltaTime
function Time.GetFixedDeltaTime()
	if not fixedDeltaTime then
		fixedDeltaTime = NT.fixedDeltaTime
	end
	return fixedDeltaTime
end

return Time