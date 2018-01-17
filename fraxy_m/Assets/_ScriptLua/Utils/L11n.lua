local _R = require 'Utils.ResMgr'

local lang = 'EN'
local pack

local texts = {}
index = -10000 -- make texts a map, not array

local tostring = tostring
local _T = function(uri, obj, ...)
	if not pack then
		local json = require 'json'
		pack = json.decode(_R('text', 'Bin_unenc/text_'..lang))
	end
	if uri == ':setlang' then
		assert(type(obj) == 'string')
		if obj and lang ~= obj then
			pack = json.decode(_R('text', 'Bin_unenc/text_'..obj))
			lang = obj
			for _, t in pairs(texts) do
				t:UpdateText()
			end
		end
	elseif uri == ':register' then
		assert(type(obj) == 'table' and obj.UpdateText)
		texts[index] = obj
		obj.__l11n_index = index
		index = index + 1
		obj:UpdateText()
	elseif uri == ':unregister' then
		assert(type(obj) == 'table' and obj.__l11n_index)
		texts[obj.__l11n_index] = nil
	elseif uri == ':getlang' then
		return lang
	else
		if type(pack) ~= 'table' then
			return 'xxx-'..tostring(lang)..'-'..uri
		end
		return pack[uri] or 'xxx-'..tostring(lang)..'-'..uri		
	end
end

return _T
