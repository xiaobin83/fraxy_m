local Unity = require 'unity.Unity'
local UI_Insp_DropDown_Entry = {}

function UI_Insp_DropDown_Entry:Awake()
	self.text = self:GetComponentInChildren(Unity.UI.Text)
	self.btn = self:GetComponentInChildren(Unity.UI.Button)
end

function UI_Insp_DropDown_Entry:OnItemCreated(item)
	self.text.text = item.label
	self.btn.onClick:AddListener(item.onClick)
end

return UI_Insp_DropDown_Entry
