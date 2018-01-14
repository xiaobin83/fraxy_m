t = dofile('Timer.lua')
function Repeat()
	print(os.clock())
	t.After(1, Repeat)		
end
t.After(1, Repeat)

while true do
	t.Update()
end
