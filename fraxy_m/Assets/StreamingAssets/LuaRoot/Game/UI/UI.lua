local Bridge = require 'Game/Bridge'

local UI = {}

function UI:Awake()
	self.funcList = Bridge.FindLBT(self, 'FuncList')
end

function UI:AddFunc(title, func)
	self.funcList:Add({title, func})
end

return UI