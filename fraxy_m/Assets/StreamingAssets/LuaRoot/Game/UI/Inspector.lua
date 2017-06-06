local UnityEngine = require 'UnityEngine'
local Bridge = require 'Game/Bridge'
local Debug = require 'Debug'

local Inspector = {}

local GameObject = UnityEngine.GameObject

function Inspector:Awake()
	self.prefabInput = self:FindGameObject('PrefabInput')
	self.prefabDropDown = self:FindGameObject('PrefabDropDown')

	self.items = {}
	self.index = 1
end

function Inspector:Clear()
	if self.items then
		for _, item in ipairs(self.items) do
			GameObject.Destroy(item.gameObject)
		end
	end
	self.items = {}
	self.index = 1
end

function Inspector:Inspect(what)
	if self.target ~= what then
		self:Clear()
	end
	self.target = what
	self:OnInspectorGUI()
end

function Inspector:OnInspectorGUI()
	if not self.target then return end
	self.index = 1 -- reset index
	if self.target.OnInspectorGUI then
		self.target:OnInspectorGUI(self)
	end
end

function Inspector:InputField(label, text, type)
	local item = self.items[self.index]
	if not item then
		item = {}
		local go = GameObject.Instantiate(self.prefabInput)
		go.transform:SetParent(self.transform, false)
		local lbt = Bridge.GetLBT(go)
		lbt:SetLabel(label)
		lbt:SetContentType(type or 'alphanumeric')
		lbt:AddListener(
			function(event, object)
				if event == 'onValueChanged' then
					item.value = object
					self:Repaint()
				end
			end)
		item.value = text
		self.items[self.index] = item
		lbt:SetContent(text)
	end
	self.index = self.index + 1
	return item.value
end

function Inspector:DropDown(label, items, selectedIndex)
	local item = self.items[self.index]
	if not item then

	end
end

function Inspector:Repaint()
	self.shouldRepaint = true
end

function Inspector:LateUpdate()
	if self.shouldRepaint then
		self.shouldRepaint = false
		self:OnInspectorGUI()
	end
end


function Inspector:Start()
--[[
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
--]]
end

return Inspector
