local Global = require 'Game/Global'
local PartType = require 'Game/PartType'
local Droid = {}

function Droid:NewPart(partType)
	local R = Global.RunningField
	local type = PartType[partType]
	local p = R:NewPart(type.internalName)
	p:SetType(type)
	return p
end

function Droid:Build( parts )
	return parts[1]
end

return Droid