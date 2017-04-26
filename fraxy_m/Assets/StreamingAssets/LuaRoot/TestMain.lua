for i = 1, 100 do
	print('d')
end


t = dofile('Timer.lua')



s = os.clock()
t.After(0.1, function()
	print(os.clock() - s)
end)
t.After(0.2, function()
	print(os.clock() - s)
end)
t.After(0.3, function()
	print(os.clock() - s)
end)
t.After(1, function()
	print(os.clock() - s)
end)
t.After(2, function()
	print(os.clock() - s)
	os.exit(0)
end)


while true do
	t.Update()
end
