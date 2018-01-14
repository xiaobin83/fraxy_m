local Bridge = require 'Game.Bridge'
local Unity = require 'unity.Unity'
local GameObject = Unity.GameObject

local ListView = {}

function ListView:Awake()
	local go = self:FindGameObject("Content")
	if go then
		self.content = go.transform
	else
		self.content = self.transform
	end

	self.prefabItem = self:FindGameObject('PrefabItem')
end

function ListView:SetConent(list)
	for i, v in ipairs(list) do
		local go = GameObject.Instantiate(self.prefabItem)
		go.transform:SetParent(self.content, false)
		local t = Bridge.GetLBT(go)
		if t.OnItemCreated then
			t:OnItemCreated(v)
		end
	end
end

function ListView:Add(item)
	local go = GameObject.Instantiate(self.prefabItem)
	go.transform:SetParent(self.content, false)
	local t = Bridge.GetLBT(go)
	if t.OnItemCreated then
		t:OnItemCreated(item)
	end
end

return ListView
