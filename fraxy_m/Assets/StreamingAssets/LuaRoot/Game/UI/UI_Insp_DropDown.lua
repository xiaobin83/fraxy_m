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

function UI_Insp_DropDown:SetTitle(title)
	self.textName.text = title
end

function UI_Insp_DropDown:SetContent(content)
	for _, item in ipairs(content) do
		local go = GameObject.Instantiate(self.prefabEntry)
		go.transform:SetParent(self.content.transform, false)
		local lbt = Bridge.GetLBT(go)
		if lbt.OnItemCreated then
			lbt:OnItemCreated({text = item.title, onClick = function() self:OnItemSelected(item) end})
		end
	end
	self:OnItemSelected(content[1])
end


function UI_Insp_DropDown:OnItemSelected(item)
	local previous = self.selected
	self.selected = item
	self.textSelected.text = item.title
	self.dropDownList:SetActive(false)
	if self.event then
		if previous ~= item then
			self.event:Invoke('onValueChanged', item)
		end
	end
end

function UI_Insp_DropDown:AddListener(func)
	if self.event then
		self.event:AddListener(func)
	end
end

return UI_Insp_DropDown
