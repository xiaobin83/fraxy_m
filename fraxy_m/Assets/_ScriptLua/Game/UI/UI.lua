

local UI = {}

function UI:Awake()
	self.funcList = Bridge.FindLBT(self, 'FuncList')
	self.equipTree = Bridge.FindLBT(self, 'EquipTree')
	self.inspector = Bridge.FindLBT(self, 'Inspector')

	UI.current = self
end

function UI:AddFunc(title, func)
	self.funcList:Add({title, func})
end

function UI:SetRootPart(part)
	return self.equipTree:AddNode(part)
end

function UI:AttachPart(part, node)
	self.equipTree:AddNode(part, node)
end

function UI:GetSelectedPartNode()
	return self.equipTree:GetSelectedNode()
end

function UI:OnDestroy()
	UI.current = nil
end


function UI.Inspect(part)
	local c = UI.current
	if not c then return end
	c.inspector:Inspect(part)
end


return UI