local LuaTreeView = csharp.checked_import('LuaTreeView')

local EquipTreeView = {}

function EquipTreeView:Awake()
	self.treeView = self:GetComponent(LuaTreeView)
end

function EquipTreeView:AddNode(part, parent)
	part.node = self.treeView:Add(part.name, part, parent)
end

function EquipTreeView:RemoveNode(part)
	local c = get_c()
	self.treeView:Remove(part.node)
	part.node = nil
end

function EquipTreeView:GetSelectedNode()
	return self.treeView.selected
end

return EquipTreeView