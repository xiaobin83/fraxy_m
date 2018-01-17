local Packet = {}

-- packet.data is a binary string
-- packet.pos is position of current reading pos


local str = string
local packetMeta = { __index = Packet, __len = function(p) return #p.data end }

function Packet.New(inData)
	local tbl = { data = inData or '', pos = 1 }
	setmetatable(tbl, packetMeta)
	return tbl
end

function Packet.SetPos(packet, pos)
	packet.pos = pos or 1
end

-- readers
local ReadInternal = function(packet, fmt)
	local r, newPos = str.unpack(fmt, packet.data, packet.pos)
	packet.pos = newPos
	return r
end

function Packet.Read(packet, fmt)
	return pcall(ReadInternal, packet, fmt)
end

function Packet.ReadBool(packet)
	local ok, ret = Packet.ReadByte(packet)
	return ok, ok and (ret == 1 and true or false)
end

function Packet.ReadByte(packet)
	return Packet.Read(packet, 'B')
end

function Packet.ReadBytes(packet, size)
	local data = packet.data
	local pos = packet.pos
	if pos + size - 1 > #data then return false end

	local bytes, newPos = str.unpack('c'..size, data, pos)
	packet.pos = newPos

	return true, bytes
end

function Packet.ReadString(packet)
	return Packet.Read(packet, '>s2')
end

function Packet.ReadU16(packet)
	return Packet.Read(packet, '>H')
end

function Packet.ReadS16(packet)
	return Packet.Read(packet, '>h')
end

function Packet.ReadU24(packet)
	return Packet.Read(packet, '>I3')
end

function Packet.ReadS24(packet)
	return Packet.Read(packet, '>i3')
end

function Packet.ReadU32(packet)
	return Packet.Read(packet, '>I4')
end

function Packet.ReadS32(packet)
	return Packet.Read(packet, '>i4')
end

function Packet.ReadU64(packet)
	return Packet.Read(packet, '>I8')
end

function Packet.ReadS64(packet)
	return Packet.Read(packet, '>i8')
end

function Packet.ReadFloat32(packet)
	return Packet.Read(packet, '>f')
end

function Packet.ReadFloat64(packet)
	return Packet.Read(packet, '>d')
end


-- writers
local AppendInternal = function(packet, d, index, fmt)
	local data = packet.data
	if index ~= nil then
		if index < #data then
			local firstPart = str.sub(data, 1, index - 1)
			if type(d) == 'string' then
				local endPart = ''
				d = fmt and str.pack(fmt, d) or d
				if index + #d < #data then
					endPart = str.sub(data, index + #d)
				end
				data = firstPart .. d .. endPart
			else
				local insertingPart = str.pack(fmt, d)
				data = firstPart .. insertingPart .. str.sub(data, index + #insertingPart)
			end
		else
			local sep = str.rep(str.char(0), index - #data)
			if type(d) == 'string' then
				data = data .. sep .. (fmt and str.pack(fmt, d) or d)
			else
				data = data .. sep .. str.pack(fmt, d)
			end
		end
	else
		if type(d) == 'string' then	
			data = data .. (fmt and str.pack(fmt, d) or d)
		else
			data = data .. str.pack(fmt, d)
		end
	end
	packet.data = data
	packet.pos = #data
end

function Packet.Append(packet, d, index, fmt)
	return pcall(AppendInternal, packet, d, index, fmt)
end	

function Packet.WriteByte(packet, b)
	Packet.Append(packet, b, nil, 'B')
end

function Packet.WriteBytes(packet, b, index)
	Packet.Append(packet, b, index)
end

function Packet.WriteBool(packet, b)
	Packet.WriteByte(packet, b and 1 or 0)
end


function Packet.WriteString(packet, s)
	Packet.Append(packet, s, nil, '>s2')
end

function Packet.WriteU16(packet, n)
	Packet.Append(packet, n, nil, '>H')
end

function Packet.WriteS16(packet, n)
	Packet.Append(packet, n, nil, '>h')
end

function Packet.WriteU24(packet, n)
	Packet.Append(packet, n, nil, '>I3')
end

function Packet.WriteS24(packet, n)
	Packet.Append(packet, n, nil, '>i3')
end

function Packet.WriteU32(packet, n, index)
	Packet.Append(packet, n, index, '>I4')
end

function Packet.WriteS32(packet, n)
	Packet.Append(packet, n, nil, '>i4')
end

function Packet.WriteU64(packet, n)
	Packet.Append(packet, n, nil, '>I8')
end

function Packet.WriteS64(packet, n)
	Packet.Append(packet, n, nil, '>i8')
end

function Packet.WriteFloat32(packet, n)
	Packet.Append(packet, n, nil, '>f')
end

function Packet.WriteFloat64(packet, n)
	Packet.Append(packet, n, nil, '>d')
end

function Packet.RestPacket(packet)
	return Packet.New(str.sub(packet.data, packet.pos, #packet))
end

return Packet
