local GameObject = csharp.checked_import('UnityEngine.GameObject')
local Console = {}

function Console.AddText(name, updateFunction)
	local e = Console.entries
	e[name] = { what = 'text',  uiCtrl = text, update = updateFunction}
end

function Console.Remove(name)
	local e = Console.entries[name]
	if e.uiCtrl then
		if type(e.uiCtrl) == 'userdata' then
			GameObject.Destroy(e.uiCtrl)
		end
		e.uiCtrl = nil
	end
	Console.entries[name] = nil
end


function Console:Awake()
	Console.current = self
	Console.entries = {}
	self.content = self:FindGameObject('Content')
end

function Console:OnDestroy()
	Console.current = nil
	self:RemoveAllCtrls()
end

function Console:RemoveAllCtrls()
	for _, e in pairs(Console.entries) do
		if type(e.uiCtrl) == 'userdata' then
			GameObject.Destroy(e.uiCtrl)
		end
		e.uiCtrl = nil
	end
end

function Console:CheckOrCreateCtrl(n, e)
	if not e.uiCtrl then
		if not self.content then
			e.uiCtrl = 'no content'
			return 
		end
		local prefab = self:FindGameObject('prefab_' .. e.what)
		if prefab then
			local go = GameObject.Instantiate(prefab)
			if go then
				go.transform:SetParent(self.content.transform, false)
				e.uiCtrl = go
				return
			end
		end
		e.uiCtrl = e.what .. ' not created'
	end
end

function Console:Update()
	for n, e in pairs(Console.entries) do
		self:CheckOrCreateCtrl(n, e)
		e.update(n, e)
	end
end


return Console
