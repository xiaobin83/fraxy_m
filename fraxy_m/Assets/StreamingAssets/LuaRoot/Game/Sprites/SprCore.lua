local Global = require 'Game/Global'

local SprCore = {}

function SprCore:Awake()
	self.boostAnimator = self:GetComponentInChildren(Global.Animator)
end

function SprCore:OnStatusUpdated(part)
	-- self.boostAnimator:SetFloat('power', part.var.accel)
end

return SprCore
