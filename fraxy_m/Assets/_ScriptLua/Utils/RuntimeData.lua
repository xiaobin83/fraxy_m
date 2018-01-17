local RuntimeData = {}
local Unity = require 'unity.Unity'
local Utils = require 'Utils.Utils'
local WatchDog = require 'Utils.WatchDog'
local Json = require 'json'


local all = {}

function RuntimeData.CreateOrObtainMonitored(name)
	local d = all[name]
	if not d then
		d = WatchDog.WatchTable({ __mode = 'watched'})
		all[name] = d
	end
	return d
end

function RuntimeData.CreateOrObtain(name)
	local d = all[name]
	if not d then
		d = { __mode = 'bare' }
		all[name] = d
	end
	return d
end

function RuntimeData.CreateOrObtainSaved(name)
	local d = all[name]
	if not d then
		d = WatchDog.WatchTable({ __mode = 'watched_and_saved' })
		-- read from playerprefs
		local savename = '_rd_'..name
		local s = Unity.PlayerPrefs.GetString(savename, '{}')
		local restored = Json.decode(s)
		for k, v in pairs(restored) do
			d[k] = v
		end
		d.onValueChanged = d.onValueChanged + function()
			Unity.PlayerPrefs.SetString(savename, Json.encode(d.__value))
		end
		all[name] = d
	end
	return d
end


return RuntimeData
