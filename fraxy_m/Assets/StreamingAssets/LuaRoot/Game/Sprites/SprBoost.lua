local Global = require 'Game/Global'
local SprBoost = {}

function SprBoost:Awake()
	self.boostAnimator = self:GetComponentInChildren(Global.Animator)
end

function SprBoost:OnStatusUpdated(part)
	self.boostAnimator:SetFloat('power', part.var.power)
end

return SprBoost
