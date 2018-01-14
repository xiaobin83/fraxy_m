local UI_Insp_Slider = {}


function UI_Insp_Slider:SetRange(min, max)
	
end

function UI_Insp_Slider:SetValue(value)

end

function UI_Insp_Slider:OnValueChanged()
	if self.event then
		self.event:Invoke('onValueChanged', self.value)
	end
end

return UI_Insp_Slider