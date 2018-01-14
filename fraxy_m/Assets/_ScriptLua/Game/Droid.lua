local PartType = require 'Game.PartType'
local Bridge = require 'Game.Bridge'

local Droid = {}

function Droid:NewPart(partType)
	local type = PartType[partType]
	local p = Bridge.NewGameObject(type.internalName, 'Game.PartBehaviour')
	p:SetType(type)
	return p
end


return Droid