local Proto = {}
local Config = require 'Config'
local _R = require 'Utils.ResMgr'

local pb = require 'pb'
pb.clear()

local game_pb_bytes = _R('bytes', 'pb/game')
local relay_pb_bytes = _R('bytes', 'pb/relay')
pb.load(game_pb_bytes)
pb.load(relay_pb_bytes)


local _BuildProto = function(package)
	local api = pb.findtype(package .. '.Api')
	assert(api:isenum())
	api = api:to_enums()
	local protoToName = {}
	local nameToProto = {}
	for k, v in pairs(api) do
		local name = string.match(k, '^E_(%w+)')
		if name then
			assert(pb.exist(package..'.'..name), 'cannot find message body for id ' .. k .. ' = ' .. v)
			nameToProto[name] = v
			protoToName[v] = name
		end
	end
	return protoToName, nameToProto
end


local protoToName, nameToProto = _BuildProto('relay')
local gameProtoToName, gameNameToProto = _BuildProto('game')

Proto.protoToName = protoToName 
for k, v in pairs(gameProtoToName) do
	Proto.protoToName[k] = v
end

Proto.nameToProto = nameToProto
for k, v in pairs(gameNameToProto) do
	Proto.nameToProto[k] = v
end

function Proto.Encode(name, body)
	return pb.encode(name, body)
end

local emptyMessage = {}
function Proto.Decode(name, data)
	return data and pb.decode(name, data) or emptyMessage 
end


return Proto
