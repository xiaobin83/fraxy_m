
-- https://blog.acolyer.org/2015/11/23/hashed-and-hierarchical-timing-wheels/
-- Scheme 6

local Timer = {}

local kMaxIntervalShift = 8  --> 1 << kMaxIntervalShift seconds
local kMaxSlots = 1 << kMaxIntervalShift
local kSlotsMask = kMaxSlots - 1
local origin = os.clock()
local pointer = 1
local round = 0
local slots = {}
for i = 1, kMaxSlots do
	slots[i] = {}
end

function Timer.After(seconds, event)
	local s = math.floor(seconds)
	local slot = (pointer + s) & kSlotsMask
	local events = slots[slot]
	events[#events + 1] = {os.clock() + seconds, event}
end

function Timer.Update()
	local cur = os.clock()
	local advance = math.floor(cur - origin)
	for i = 0, advance do
		local slot = ((pointer - 1 + i) & kSlotsMask) + 1
		local events = slots[slot]
		if #events > 0 then 
			local eventsNotFired = {}
			for _, evt in ipairs(events) do
				if cur >= evt[1] then
					evt[2]()
				else
					-- not fired
					eventsNotFired[#eventsNotFired + 1] = evt
				end
			end
			slots[slot] = eventsNotFired
		end
	end
	origin = origin + advance
	pointer = pointer + advance
end

return Timer
