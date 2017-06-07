local Math = require 'Math/Math'
local T = require 'Text'
local ControlledCore = require 'Game/Parts/ControlledCore'
local Core = require 'Game/Parts/Core'
local Boost = require 'Game/Parts/Boost'
local Deco = require 'Game/Parts/Deco'


local PartType = {}

PartType.ControlledCore = {
	internalName = 'ControlledCore',
	name = T('ControlledCore'),
	sprite = 'Parts/p_core_01',
	script = ControlledCore,

	attr = {
		boost = 0.1,
		turn = 60,
		drag = 0.2,
	}
}


PartType.Core_01 = {
	internalName = 'Core 01',
	name = T('Core_01'),
	sprite = 'Parts/p_core_01',
	script = Core,

	attr = {
		turn = 60,
		mass = 0.2,
		aim = 0.2, -- aim target
	}
}


PartType.BoostType = {}
PartType.BoostType.normal = 1
PartType.BoostType.left_assist = 2
PartType.BoostType.right_assist = 3
PartType.BoostType.auto_assist = 4

PartType.Boost_01 = {
	internalName = 'Boost 01',
	sprite = 'Parts/p_boost_01',
	script = Boost,

	-- constant part, update from somewhere
	attr = {
		power = 0.5,
		type = PartType.BoostType.normal
	},
	
	-- serializable part
	serializable = {
		name = T('Boost_01'),
		offset = Math.Vector3.zero,
		angular = 0,
		localAngular = 0
	}
}



PartType.Deco_01 = {
	internalName = 'Deco 01',
	sprite = 'Parts/p_deco_01',
	script = Deco,

	attr = {

	},

	serializable = {
		name = T('Deco_01'),
		offset = Math.Vector3.zero,
		angular = 0,
		localAngular = 0,
	}
}



return PartType