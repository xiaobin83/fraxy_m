local UnityEngine = require 'UnityEngine'

local UI_Insp_Input = {}

function UI_Insp_Input:Awake()
	self.textName = self:FindGameObject('Name'):GetComponent(UnityEngine.UI.Text)
	self.inputField = self:FindGameObject('InputField'):GetComponent(UnityEngine.UI.InputField)
end

function UI_Insp_Input:SetContent(name, type, placeholder, text, onValueChanged)

end



return UI_Insp_Input
