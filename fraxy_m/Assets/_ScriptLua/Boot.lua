local Boot = {}

local Unity = require 'unity.Unity'


local debuggee_poll

local _StartDebug = function()
	local d = require 'Debuggee'
	debuggee_poll = d.start()
end

function Boot:Awake()
	if _UNITY['EDITOR'] then
		_StartDebug()
	end
	--------
	local lb = self.gameObject:AddComponent(Unity.lua.LuaBehaviour)
	lb:LoadScript('Game.Main')
end

function Boot:LateUpdate()
	if debuggee_poll then
		debuggee_poll()
	end
end

return Boot
