local MsgPack = {}

local Unity = require 'unity.Unity'
local Config = require 'Config'
local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[MSG]')

local Proto = require 'Game.Proto'
local Packet = require 'Utils.Packet'

local emptyMsg = {}

local Profiler = Unity.Profiling.Profiler

function MsgPack.Pack(proto, name, msg, to, from)

	msg = msg or emptyMsg

	if proto == 'game' then
		local protoNo = Proto.nameToProto[name] -- assert(Proto[name], 'cannot find proto number ' .. name)
		local messageName = proto..'.'..name
		Profiler.BeginSample('PB.Encode')
		local innerData = Proto.Encode(messageName, msg)
		Profiler.EndSample()
		return MsgPack.Pack(
			'relay', 'SendRequest',
			{
				target = assert(to),
				from = assert(from),
				msgId = protoNo,
				data = innerData
			})
	elseif proto == 'relay' then
		local protoNo = Proto.nameToProto[name] -- assert(Proto[name], 'cannot find proto number ' .. name)
		local messageName = proto..'.'..name
		Profiler.BeginSample('PB.Encode')
		local data = Proto.Encode(messageName, msg)
		Profiler.EndSample()
		local packet = Packet.New()
		packet:WriteU32(0)
		packet:WriteByte(protoNo)
		packet:WriteBytes(data)
		packet:WriteU32(#packet - 4, 1)
		return csharp.as_bytes(packet.data)

	end
	assert(false, 'unknown proto ' .. proto)
end


function MsgPack.Peek(data)
	local reader = Packet.New(data)
	local ok, length = assert(reader:ReadU32())
	local ok, op = assert(reader:ReadByte())
	local name = assert(Proto.protoToName[op], 'unknown op ' .. op)
	return name, length
end

function MsgPack.Unpack(data)
	local reader = Packet.New(data)
	local ok, length = assert(reader:ReadU32())
	local ok, op = assert(reader:ReadByte())
	local ok, data = assert(reader:ReadBytes(length - 1))
	local protoToName = Proto.protoToName
	local opName = protoToName[op] --assert(protoToName[op], 'unknown op ' .. op)
	Profiler.BeginSample('PB.Decode')
	local msg = Proto.Decode('relay.'..opName, data)
	Profiler.EndSample()
	local to, from
	if opName == 'SendRequest' then
		to = msg.target
		from = msg.from
		data = msg.data
		opName = protoToName[msg.msgId]
		Profiler.BeginSample('PB.Decode')
		msg = Proto.Decode('game.'..opName, data)
		Profiler.EndSample()
	end
	return opName, msg, from, to
end

return MsgPack
