local Game = {}

local _StartDebugable

function Game._Init(inst)
	inst.addr = 'none'
	inst.port = 12000
end

function Game:Awake()
	_StartDebugable(self)
end

local _ExecuteCommand = function(s, cmd)
	if not cmd then return end
	_LogD('execute cmd: ' .. cmd)
	local chunk, errmsg = load('return function(s)\n' .. cmd .. '\nend\n')
	if not chunk then
		return errmsg
	end
	local f = chunk()
	return pcall(f, s)
end
	
_StartDebugable = function(s)
	local FSDBG = csharp.checked_import('utils.FullScreenDebugable')
	local fsdbg = FSDBG.instance
	fsdbg:Editor_AddToolbarButton('Game', function() fsdbg:Editor_ToggleCmdHandler() end)
	fsdbg:Editor_AddToolbarButton('popup', function() fsdbg:Editor_TogglePopUp() end)
	fsdbg:Editor_SetCmdHandler(
		'Game',
		function(cmd)
			local _, ret = _ExecuteCommand(s, cmd)
			fsdbg:Editor_PopUp('Game> ' .. _ToString(ret)..'\n')
		end
	)
	fsdbg:Editor_AddToolbarButton('Server', function() Main.StartServer(s.address, s.port) end)
end

return Game
