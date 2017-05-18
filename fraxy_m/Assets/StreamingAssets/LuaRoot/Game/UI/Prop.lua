local Prop = {}

local prop_meta = {}

function Prop.New(prop)
	return setmetatable(prop, prop_meta)
end

return Prop
