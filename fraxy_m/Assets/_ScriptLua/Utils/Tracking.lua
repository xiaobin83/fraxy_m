local Tracking = csharp.checked_import('tracking.Tracking').instance
local json = require 'json'
local _Tracking = {}

function _Tracking.SendEvent(id, parameters)
    parameters = json.encode(parameters)
    Tracking:SendEvent(id, parameters)
end

return _Tracking