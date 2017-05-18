local UnityEngine = require 'UnityEngine'
local UI = require 'Game/UI/UI'

local EquipTreeViewNode = {}

function EquipTreeViewNode:Awake()
	self.selectedBG = self:FindGameObject('SelectedBG')
	self.icon = self:FindGameObject('Icon'):GetComponent(UnityEngine.UI.Image)
	self.text = self:FindGameObject('Text'):GetComponent(UnityEngine.UI.Text)
	self.layoutGroup = self:GetComponent(UnityEngine.UI.HorizontalLayoutGroup)
end

function EquipTreeViewNode:OnItemCreated(node)
	self.node = node
	local item = node.item
	-- self.icon.overrideSprite = item:GetIcon()
	self.text.text = item.type.name
	self.layoutGroup.padding.left = node.indent
end

function EquipTreeViewNode:OnItemSelected()
	UI.Inspect(self.node.item)
	self.selectedBG:SetActive(true)
end

function EquipTreeViewNode:OnItemDeselected()
	self.selectedBG:SetActive(false)
end


return EquipTreeViewNode
