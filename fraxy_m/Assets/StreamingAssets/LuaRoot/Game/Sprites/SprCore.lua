local UnityEngine = require 'UnityEngine'

local SprCore = {}

function SprCore:Awake()
	self.boostAnimator = self:GetComponentInChildren(UnityEngine.Animator)
end

function SprCore:OnStatusUpdated(part)
	-- self.boostAnimator:SetFloat('power', part.var.accel)
end

return SprCore
