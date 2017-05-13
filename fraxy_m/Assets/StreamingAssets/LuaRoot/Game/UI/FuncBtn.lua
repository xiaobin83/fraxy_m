
local Global = require 'Game/Global'
local FuncBtn = {}


function FuncBtn:Awake()
	self.text = self:FindGameObject('Text'):GetComponent(Global.UI.Text)
	local btn = self:GetComponent(Global.UI.Button)
	btn.onClick:AddListener(function()
		self:OnClick()
	end)
end

function FuncBtn:OnItemCreated(item)
	self.item = item
	self.text.text = item[1]
	self.func = item[2]
end

function FuncBtn:OnClick()
	if self.func then
		self.func()
	end
end



return FuncBtn
