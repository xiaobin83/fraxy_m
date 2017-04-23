local _Debug = csharp.checked_import('UnityEngine.Debug, UnityEngine')

local Debug = {}

function Debug.Log(msg)
	_Debug.Log(msg)
end

function Debug.LogWarning(msg)
	_Debug.LogWarning(msg)
end

function Debug.LogError(msg)
	_Debug.LogError(msg)
end

function Debug.Asset(cond, msg)
	if not cond then
		error(msg)
	end
end

return Debug
