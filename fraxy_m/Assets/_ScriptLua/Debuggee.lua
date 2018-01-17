require 'unity.Debug'

local debuggee = {}
function debuggee.start(host, port)
	_LogD('start lua debuggee')
	local json = require 'json'
	local d = require 'vscode-debuggee'
	local startResult, startType = d.start(json, {
		controllerHost = host or 'localhost',
		port = port or 56789,
	})
	return d.poll
end
return debuggee
