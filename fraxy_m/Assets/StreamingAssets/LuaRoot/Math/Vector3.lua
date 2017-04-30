
local module = {}

local mt = {}
mt.__unm = function(rhs)
	return module.Vector3D(-rhs.x, -rhs.y, -rhs.z)
end
	
mt.__add = function(lhs, rhs)
	return module.Vector3D(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
end

mt.__sub = function(lhs, rhs)
	return module.Vector3D(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
end

mt.__mul = function(lhs, rhs)
	if type(rhs) == 'number' then
		return module.Vector3D(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
	elseif type(lhs) == 'number' then
		return module.Vector3D(lhs * rhs.x, lhs * rhs.x, lhs * rhs.z)
	else
		return module.Vector3D(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
	end
end

mt.__div = function(lhs, rhs)
	if type(rhs) == 'number' then
		return module.Vector3D(lhs.x / rhs, lhs.y / rhs, lhs.z / rhs)
	elseif type(lhs) == 'number' then
		return module.Vector3D(lhs / rhs.x, lhs / rhs.y)
	else
		return module.Vector3D(lhs.x / rhs.x, lhs.x / rhs.x, lhs.z / rhs.z)
	end
end

mt.__tostring = function(v)
	return "[(X:".. v.x .."),(Y:".. v.y .."),(Z:".. v.z ..")]"
end

mt.__eq = function(lhs, rhs)
	return (lhs.x == rhs.x) and (lhs.y == rhs.y) and (lhs.z == rhs.z)
end


module.Vector3D = function (ix, iy, iz)
	local v = {}
	v.x = ix or 0
	v.y = iy or 0
	v.z = iz or 0
	
	function v:dup() 
		return module.Vector3D(self.x, self.y, self.z)
	end

	function v:getLength() --Return the length of the vector (i.e. the distance from (0,0), see README.md for examples of using this)
		return math.sqrt(self.x^2 + self.y^2 + self.z^2)
	end

	function v:getSquaredLength()
		return self.x^2 + self.y^2 + self.z^2
	end
	
	setmetatable(v, mt)

	return v
end

return module
