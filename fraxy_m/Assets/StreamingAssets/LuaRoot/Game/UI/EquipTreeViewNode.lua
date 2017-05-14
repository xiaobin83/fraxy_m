local Global = require 'Game/Global'

local EquipTreeViewNode = {}

function EquipTreeViewNode:Awake()
	self.selectedBG = self:FindGameObject('SelectedBG')
	self.icon = self:FindGameObject('Icon'):GetComponent(Global.UI.Image)
	self.text = self:FindGameObject('Text'):GetComponent(Global.UI.Text)
end

function EquipTreeViewNode:OnItemCreated(node)
	self.node = node
	local item = node.item
	-- self.icon.overrideSprite = item:GetIcon()
	self.text.text = item.type.name
end

function EquipTreeViewNode:OnItemSelected()
	self.selectedBG:SetActive(true)
end

function EquipTreeViewNode:OnItemDeselected()
	self.selectedBG:SetActive(false)
end


return EquipTreeViewNode
