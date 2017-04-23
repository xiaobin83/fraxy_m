local PartType = {}

local T = require 'Text'

local ControlledCore = require 'Game/Parts/ControlledCore'
local Core = require 'Game/Parts/Core'

PartType.controlledCore = {
	internalName = 'ControlledCore',
	name = T('Core'),
	sprite = 'Parts/p_spr_core',
	script = ControlledCore
}


PartType.core = {
	internalName = 'Core',
	name = T('Core'),
	sprite = 'Parts/spr_core',
	script = Core
}

return PartType