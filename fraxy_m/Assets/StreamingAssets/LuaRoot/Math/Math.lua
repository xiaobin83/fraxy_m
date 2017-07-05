local v2d = require 'Math/Vector2'
local v3d = require 'Math/Vector3'
local UnityVector2 = csharp.checked_import('UnityEngine.Vector2')
local UnityVector3 = csharp.checked_import('UnityEngine.Vector3')
local Math = {}

Math.Vector2 = {}
Math.Vector2.zero = v2d.Vector2D(0, 0)
setmetatable(
	Math.Vector2, 
	{ 
		__call = function(t, x, y)
			return v2d.Vector2D(x, y)
		end
	})

function Math.Vector2.ToUnity(v)
	return UnityVector2(v.x, v.y)
end

function Math.Vector2.FromUnity(v)
	return Math.Vector2(v.x, v.y)
end

---------------------

Math.Vector3 = {}
Math.Vector3.zero = v3d.Vector3D(0, 0, 0)
setmetatable(
	Math.Vector3,
	{
		__call = function(t, x, y, z)
			return v3d.Vector3D(x, y, z)
		end
	})

function Math.Vector3.ToUnity(v)
	return UnityVector3(v.x, v.y, v.z)
end

function Math.Vector3.FromUnity(v)
	return Math.Vector3(v.x, v.y, v.z)
end


------------------------

function Math.Lerp(a, b, t)
	return a - (a - b)*t
end


return Math