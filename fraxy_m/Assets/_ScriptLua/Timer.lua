
-- https://blog.acolyer.org/2015/11/23/hashed-and-hierarchical-timing-wheels/
-- Scheme 6

local Timer = {}

local kMaxIntervalShift = 4  --> 1 << kMaxIntervalShift seconds
local kMaxSlots = 1 << kMaxIntervalShift
local kSlotsMask = kMaxSlots - 1
local origin = os.clock()
local pointer = 0
local round = 0
local slots = {}
for i = 1, kMaxSlots do
	slots[i] = {}
end

local toArrange = {}

function Timer.After(seconds, event)
	toArrange[#toArrange + 1] = {os.clock() + seconds, event}
end

function Timer.Update()
	local cur = os.clock()
	if #toArrange > 0 then
		for _, a in ipairs(toArrange) do
			local expire, evt = unpack(a)
			local s = math.floor(expire - origin)
			if s < 0 then s = 0 end
			local slot = (pointer + s) & kSlotsMask
			local events = slots[slot+1]
			events[#events + 1] = {expire, evt}
		end
		toArrange = {}
	end
	local advance = math.floor(cur - origin)
	for i = 0, advance do
		local slot = (pointer + i) & kSlotsMask
		local events = slots[slot + 1]
		if #events > 0 then 
			local eventsNotFired = {}
			for _, evt in ipairs(events) do
				if cur + i >= evt[1] then
					evt[2]()
				else
					-- not fired
					eventsNotFired[#eventsNotFired + 1] = evt
				end
			end
			slots[slot + 1] = eventsNotFired
		end
	end
	origin = origin + advance
	pointer = pointer + advance
end

return Timer
