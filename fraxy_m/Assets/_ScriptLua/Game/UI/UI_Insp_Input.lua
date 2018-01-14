local Unity = require 'unity.Unity'
local ContentType = Unity.UI.InputField[{csharp.p_nested_type(), 'ContentType'}]

local UI_Insp_Input = {}

function UI_Insp_Input:Awake()
	self.textName = self:FindGameObject('Name'):GetComponent(Unity.UI.Text)
	self.inputField = self:FindGameObject('InputField'):GetComponent(Unity.UI.InputField)
	self.placeholder = self.inputField.placeholder:GetComponent(Unity.UI.Text)
	self.event = self:FindEvent('event')
end

--[[
function UI_Insp_Input:Start()
	self:SetLabel('Test')
	self:SetPlaceholder('input some string')
	self:SetContentType('integer')
	self:AddListener(
		function(event, object)
			_LogD(event .. ': ' .. tostring(object))
		end)
	self:SetContent('')
end
--]]

function UI_Insp_Input:SetLabel(label)
	self.textName.text = label
end


function UI_Insp_Input:SetPlaceholder(placeholderText)
	self.inputField.placeholder.text = placeholderText
end

function UI_Insp_Input:SetContentType(type)
	if type == 'alphanumeric' then
		self.inputField.contentType = ContentType.Alphanumeric
	elseif type == 'integer' then
		self.inputField.contentType = ContentType.IntegerNumber
	elseif type == 'float' then
		self.inputField.contentType = ContentType.DecimalNumber
	else
		self.inputField.contentType = ContentType.Standard
	end
end

function UI_Insp_Input:SetContent(text)
	self.inputField.text = text or ''
end

function UI_Insp_Input:AddListener(func)
	if self.event then
		self.event:AddListener(func)
	end
end

function UI_Insp_Input:OnValueChanged()
	if self.event then
		self.event:Invoke('onValueChanged', self.inputField.text)
	end
end

function UI_Insp_Input:OnEndEdit()
	if self.event then
		self.event:Invoke('onEndEdit', self.inputField.text)
	end
end


return UI_Insp_Input
