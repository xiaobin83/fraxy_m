local T = {}


local function Translate(t, k)
	return k
end

setmetatable(T, { __call = function(t, k) return Translate(k) end})

return T
