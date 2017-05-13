local EquipTreeView = {}

function EquipTreeView:Awake()
	EquipTreeView.current = self
end

function EquipTreeView:OnDestroy()
	EquipTreeView.current = nil
end


local function get_c()
	local c = EquipTreeView.current
	if not c then error('EquipTreeView.current is nil') end
	return c
end

function EquipTreeView.Add(part, parent)
	local c = get_c()
	part.node = c:Add(part.name, part, parent)
end

function EquipTreeView.Remove(part)
	local c = get_c()
	c:Remove(part.node)
	part.node = nil
end

return EquipTreeView