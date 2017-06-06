local Bridge = require 'Game/Bridge'
local Debug = require 'Debug'

local TestInspector = {}


function TestInspector:Start()
	local go = self:FindGameObject('Inspector')
	self.inspector = Bridge.GetLBT(go)
	self.testString = 'kkk'
	self.inspector:Inspect(self)
end

function TestInspector:OnInspectorGUI(inspector)
	self.testString = inspector:InputField('Name', self.testString)
	Debug.Log(self.testString)
end

return TestInspector