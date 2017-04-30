local Animator = csharp.checked_import('UnityEngine.Animator')

local SprCore = {}


function SprCore:Awake()
	self.boostAnimator = self:FindGameObject('boost'):GetComponent(Animator)
end

function SprCore:OnStatusUpdated(part)
	self.boostAnimator:SetFloat('accel', part.var.accel)
end

return SprCore
