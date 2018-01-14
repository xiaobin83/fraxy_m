local Time = require 'Time'
local Math = require 'unity.Math'
local Camera = {}

function Camera:SetTarget(t)
	self.target = t
end

function Camera:FixedUpdate()
	if not self.target then return end
	local pos = Math.Vector3.FromUnity(self.transform.position)
	local target = Math.Vector3.FromUnity(self.target.transform.position)
	target.z = pos.z
	pos = Math.Lerp(pos, target, Time.GetFixedDeltaTime())
	self.transform.position = Math.Vector3.ToUnity(pos)
end


return Camera
