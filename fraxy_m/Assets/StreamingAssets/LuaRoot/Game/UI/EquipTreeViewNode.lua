local Global = require 'Game/Global'

local EquipTreeViewNode = {}

function EquipTreeViewNode:Awake()
	self.selectedBG = self:FindGameObject('SelectedBG')
	self.icon = self:FindGameObject('Icon'):GetComponent(Global.UI.Image)
	self.text = self:FindGameObject('Text'):GetComponent(Global.UI.Text)
end

function EquipTreeViewNode:OnItemCreated(node)
	self.node = node
end

function EquipTreeViewNode:OnItemSelected()

end

function EquipTreeViewNode:OnItemDeselected()

end


return EquipTreeViewNode
