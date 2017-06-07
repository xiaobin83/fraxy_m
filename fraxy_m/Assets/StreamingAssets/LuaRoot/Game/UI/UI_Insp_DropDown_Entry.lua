local UnityEngine = require 'UnityEngine'
local UI_Insp_DropDown_Entry = {}

function UI_Insp_DropDown_Entry:Awake()
	self.text = self:GetComponentInChildren(UnityEngine.UI.Text)
	self.btn = self:GetComponentInChildren(UnityEngine.UI.Button)
end

function UI_Insp_DropDown_Entry:OnItemCreated(item)
	self.text.text = item.label
	self.btn.onClick:AddListener(item.onClick)
end

return UI_Insp_DropDown_Entry
