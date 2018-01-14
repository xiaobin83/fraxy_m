local T = {}


local function Translate(k)
	return k
end

setmetatable(T, { __call = function(t, k) return Translate(k) end})

return T
