local module = {}

local mt = {}
mt.__unm = function(rhs)
	return module.Vector2D(-rhs.x, -rhs.y)
end
	
mt.__add = function(lhs, rhs)
	return module.Vector2D(lhs.x + rhs.x, lhs.y + rhs.y)
end

mt.__sub = function(lhs, rhs)
	return module.Vector2D(lhs.x - rhs.x, lhs.y - rhs.y)
end

mt.__mul = function(lhs, rhs)
	if type(rhs) == 'number' then
		return module.Vector2D(lhs.x * rhs, lhs.y * rhs)
	elseif type(lhs) == 'number' then
		return module.Vector2D(lhs * rhs.x, lhs * rhs.y)
	else
		return module.Vector2D(lhs.x * rhs.x, lhs.y * rhs.y)
	end
end

mt.__div = function(lhs, rhs)
	if type(rhs) == 'number' then
		return module.Vector2D(lhs.x / rhs, lhs.y / rhs)
	elseif type(lhs) == 'number' then
		return module.Vector2D(lhs / rhs.x, lhs / rhs.y)
	else
		return module.Vector2D(lhs.x / rhs.x, lhs.y / rhs.y)
	end
end

mt.__tostring = function(v)
	--tostring handler for Vector2D
	return "[(X:".. v.x .."),(Y:".. v.y ..")]"
end

--Comparisons

mt.__eq = function(lhs, rhs)
	--Equal To operator for vector2Ds
	return (lhs.x == rhs.x) and (lhs.y == rhs.y)
end


module.Vector2D = function (ix, iy)
	local v = {}
	v.x = ix or 0
	v.y = iy or 0
	
	function v:dup() 
		return module.Vector2D(self.x, self.y)
	end

	function v:getAngle() --Return the 2D angle of the vector IN RADIANS!.
		return math.atan2(self.x, self.y)
	end
	
	function v:getLength() --Return the length of the vector (i.e. the distance from (0,0), see README.md for examples of using this)
		return math.sqrt(self.x^2 + self.y^2)
	end

	function v:getSquaredLength()
		return self.x^2 + self.y^2
	end
	
	setmetatable(v, mt)

	return v
end

return module
