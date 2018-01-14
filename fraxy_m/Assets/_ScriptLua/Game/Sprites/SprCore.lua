local Unity = require 'unity.Unity'

local SprCore = {}

function SprCore:Awake()
	self.boostAnimator = self:GetComponentInChildren(Unity.Animator)
end

function SprCore:OnStatusUpdated(part)
	-- self.boostAnimator:SetFloat('power', part.var.accel)
end

return SprCore
