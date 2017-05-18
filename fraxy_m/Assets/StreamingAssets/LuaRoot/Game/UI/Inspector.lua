local Inspector = {}

function Inspector:Awake()
	self.prefabInput = self:FindGameObject('PrefabInput')
end

function Inspector:Inspect(part)
	if self.target ~= part then
		self:Clear()
	end
	self.target = part
	
	
end

return Inspector
