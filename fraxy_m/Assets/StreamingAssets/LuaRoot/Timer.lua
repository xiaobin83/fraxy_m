
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
for i = 1, kNumBuckets do
	slots[i] = {}
end

function Timer.After(seconds, event)
	local s = math.floor(s)
	local c = s >> kMaxIntervalShift
	local deltaSlot = s - c << kMaxIntervalShift
	local slot = (pointer + deltaSlot) & kSlotsMask
	local delta = seconds - s
	local events = slots[slot]
	events[#events + 1] = { c, delta, event}
end

function Timer.Update()
	local cur = os.clock()
	

end

return Timer