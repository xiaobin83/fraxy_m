local UnityEngine = require 'UnityEngine'
local Bridge = require 'Game/Bridge'

local UI_Insp_DropDown = {}
local GameObject = UnityEngine.GameObject

function UI_Insp_DropDown:Awake()
	self.prefabEntry = self:FindGameObject('PrefabEntry')
	self.textName = self:FindGameObject('TextName'):GetComponent(UnityEngine.UI.Text)
	self.dropDownList = self:FindGameObject('DropDownList')
	self.content = self:FindGameObject('Content')
	self.textSelected = self:FindGameObject('TextSelected'):GetComponent(UnityEngine.UI.Text)
	self.event = self:FindEvent('event')

	self.dropDownList:SetActive(false)
	self.textSelected.text = ''
end 

function UI_Insp_DropDown:OnDropDownButtonClicked()
	self.dropDownList:SetActive(not self.dropDownList.activeSelf)
end

function UI_Insp_DropDown:SetLabel(title)
	self.textName.text = title
end

function UI_Insp_DropDown:SetContent(content, selectedIndex)
	for i, item in ipairs(content) do
		local go = GameObject.Instantiate(self.prefabEntry)
		go.transform:SetParent(self.content.transform, false)
		local lbt = Bridge.GetLBT(go)
		if lbt.OnItemCreated then
			local label
			if type(item) == 'table' then
				label = item.label or tostring(i)
			else
				label = tostring(i)
			end
			lbt:OnItemCreated({label = label, onClick = function() self:OnItemSelected(item, i) end})
		end
	end
	local i = selectedIndex or 1
	self:OnItemSelected(content[i], i)
end


function UI_Insp_DropDown:OnItemSelected(item, atIndex)
	local previous = self.selectedIndex
	self.selectedIndex = atIndex
	self.textSelected.text = item.label
	self.dropDownList:SetActive(false)
	if self.event then
		if previous ~= atIndex then
			self.event:Invoke('onValueChanged', atIndex)
		end
	end
end

function UI_Insp_DropDown:AddListener(func)
	if self.event then
		self.event:AddListener(func)
	end
end

return UI_Insp_DropDown
