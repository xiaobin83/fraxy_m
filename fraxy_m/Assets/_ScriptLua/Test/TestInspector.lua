

local TestInspector = {}

local items = {
	{label = 'aaa', value = 11},
	{label = 'bbb', value = 22},
	{label = 'ccc', value = 33},
}

function TestInspector:Start()
	local go = self:FindGameObject('Inspector')
	self.inspector = Unity.Lua.GetLBT(go)
	self.testString = 'kkk'
	self.testInteger = 10
	self.itemIndex = 1
	self.inspector:Inspect(self)
end


function TestInspector:OnInspectorGUI(inspector)
	self.testString = inspector:InputField('Name', self.testString)
	self.testInteger = inspector:InputField('Value', self.testInteger, 'float')
	self.itemIndex = inspector:DropDown('Item', items, self.itemIndex)
	
	_LogD(self.testString)
	_LogD(type(self.testInteger) .. tostring(self.testInteger))
	_LogD(items[self.itemIndex].value)
end

return TestInspector