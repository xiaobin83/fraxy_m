local UnityEngine = require 'UnityEngine'
local Bridge = require 'Game/Bridge'
local Debug = require 'Debug'

local Inspector = {}

local GameObject = UnityEngine.GameObject

function Inspector:Awake()
	self.prefabInput = self:FindGameObject('PrefabInput')
	self.prefabDropDown = self:FindGameObject('PrefabDropDown')
end

function Inspector:Inspect(part)
	if self.target ~= part then
		self:Clear()
	end
	self.target = part
end



function Inspector:Start()
	local go = GameObject.Instantiate(self.prefabDropDown)
	go.transform:SetParent(self.transform, false)

	local lbt = Bridge.GetLBT(go)
	lbt:SetTitle('MyDropDown')
	lbt:AddListener(
		function(event, object)
			if event == 'onValueChanged' then
				Debug.Log(event .. ': ' .. object.title)
			end
		end
	)
	lbt:SetContent(
		{{title = 'aaaa'},{title = 'bbbb'}}
	)
end

return Inspector
