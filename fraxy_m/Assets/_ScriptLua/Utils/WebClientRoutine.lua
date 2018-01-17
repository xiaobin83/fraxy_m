local WebClientRoutine = {}

local Config = require 'Config'
local _LogT, _LogD, _LogI, _LogW, _LogE = require('unity.Debug').GetLogFuncs('[WCR]')

local WC = require 'Utils.WebClient'

local cmds

local _StartCmdCo = function(s, c, i)
	-- cmd loop here
	local co = coroutine.create(
		function()
			while true do 
				local buf = c.buffer
				if not buf then 
					_LogD('cmd coroutine ' .. i .. ' ends')
					return 
				end
				if #buf > 0 then
					c.buffer = {}
					for _, cmd in ipairs(buf) do
						local finished = false
						local func, params, complete = unpack(cm)
						WC.Post(
							func, params, 
							function(suc, payload)
								if complete then
									complete(suc, payload)
								end
								finished = true
							end)
						while not finished do
							coroutine.yield()
						end
					end
				end
				coroutine.yield()
			end
		end)
	s:StartLuaCoroutine(co)
end

local _StartCo = function(s)
	local co = coroutine.create(function()

		while not WC.CheckNetwork() do
			coroutine.yield()
		end

		WC.Init()
		while not WC.CheckInited() do
			coroutine.yield()
		end
		
		WC.Login()
		while not WC.loginSuccess do
			coroutine.yield()
		end

		-- start cmd routine
		for i, c in ipairs(cmds) do
			_LogD('start cmd coroutine ' .. i)
			_StartCmdCo(s, c, i)
		end
	end)
	s:StartLuaCoroutine(co)
end


local _M = {}

function _M:POST(func, params, complete)
	table.insert(self.buffer, {func, params, complete, 'post'})
end

function _M:GET(func, params, complete)
	table.insert(self.buffer, {func, params, complete, 'get'})
end


function WebClientRoutine.Start(luaBehaviour, maxRoutine)
	maxRoutine = maxRoutine or Config.maxNumWebClientRoutine 
	local lb = luaBehaviour
	cmds = {}
	for i = 1, 4 do 
		table.insert(cmds, setmetatable({ buffer = {} }, {__index = _M}))
	end
	_StartCo(luaBehaviour)
end


function WebClientRoutine.POST(func, params, complete)
	-- run at arbitary routine
	local any = WebClientRoutine.Any()
	any.POST(func, params, complete)
end

function WebClientRoutine.GET(func, params, complete)
	-- run at arbitary routine
	local any = WebClientRoutine.Any()
	any.GET(func, params, complete)
end



--[[
	local any = WCR.Any()
	any.Post()
	any.Post()
	-- this ensure that post sended and responded in sequence
	-- like Post -> Responsed -> Post -> Responsed
]]
function WebClientRoutine.Any(mode)
	-- mode: random, empty
	return cmds[math.random(1, #cmds)]
end





return WebClientRoutine

