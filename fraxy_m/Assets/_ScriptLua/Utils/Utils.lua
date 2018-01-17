local Utils = {}
local Unity = require 'unity.Unity'
	
local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
function Utils.RandomString(len)
	local s = ''
	for i = 1, len do
		local t = math.random(1, #alphabet)
		s = s .. string.sub(alphabet, t, t)
	end
	return s
end

function Utils.StringTrim(str)
	local a = string.gsub(string.gsub(str, '^%s*', ''), '%s*$', '')
	return a
end

function Utils.StringSplit(str, d, trimWhiteSpace)
	trimWhiteSpace = trimWhiteSpace or true
	local r = {}
	for match in string.gmatch(str..d, '([^'..d..']-)'..d) do
		r[#r+1] = trimWhiteSpace and Utils.StringTrim(match) or match
	end
	return r
end

function Utils.StringJoin(sep, arr)
	local s = ''
	for i, v in ipairs(arr) do
		if i == 1 then
			s = v
		else
			s = s..sep..tostring(v)
		end
	end
	return s
end

function Utils.Contains(tbl, value)
	if tbl and value then
		for k, v in pairs(tbl) do
			if v == value then
				return k
			end
		end
	end
end

function Utils.Containsi(t, elem)
	if t and elem then
		for i, e in ipairs(t) do
			if e == elem then
				return i 
			end
		end
	end
end


return Utils
