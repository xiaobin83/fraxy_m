local ResMgr = csharp.checked_import("ResMgr")
local Unity = require 'unity.Unity'

local cache = {}

local _R

_R = function(t, uri, ...)
	if t == ':clearcache' then
		cache = {}	
		return nil
	elseif t == ':unloadunused' then
		ResMgr.UnloadUnused()
	end

	if t == "gameobject" then
		local obj = _R('object', uri)
		return Unity.GameObject.Instantiate(obj, ...)
	end

	local c = cache[t]
	if not c then
		c = {}
		cache[t] = c
	end

	uri = string.lower(uri)	
	local r = c[uri]
	if r then
		return r
	end
	
	if t == "sprite" then
		r = ResMgr.LoadSprite(uri)
	elseif t == 'bytes' then
		r = ResMgr.LoadBytes(uri)
	elseif t == 'text' then
		r = ResMgr.LoadString(uri)
	elseif t == 'object' then
		r = ResMgr.LoadObject(uri)
	end

	c[uri] = r

	return r
end

return _R
