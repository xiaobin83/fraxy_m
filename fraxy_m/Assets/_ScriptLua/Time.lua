local NT = csharp.checked_import('Unity.Time')

local Time = {}

local fixedDeltaTime
function Time.GetFixedDeltaTime()
	if not fixedDeltaTime then
		fixedDeltaTime = NT.fixedDeltaTime
	end
	return fixedDeltaTime
end

return Time