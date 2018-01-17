local WebClient = {}

local Device = csharp.checked_import('common.Device')
local WebRequest = csharp.checked_import('WebRequest2_Lua')
local Application = csharp.checked_import('UnityEngine.Application')
local Fed_Lua = csharp.checked_import('Fed_Lua')
local json = require 'json'

WebClient.inited = false
WebClient.loginSuccess = false

local GetSrvUrl = function()
    return Fed_Lua.srvUrl
end

local gameId
local GetGameId = function()
    if not gameId then
        local clientId = Fed_Lua.clientId
        gameId = assert(string.match(clientId, '^(%w+):'), '')
    end
    return gameId
end

local GetUuid = function()
    return Device.uuid
end

WebClient.uid = false
WebClient.token = false

local GeneratePassword = function(key)
    local utils = csharp.checked_import('common.Utils')
    return utils.Md5Sum(key)
end

function WebClient.CheckNetwork()
    return Application.internetReachability ~= 0
end

function WebClient.Init()
    Fed_Lua.InitFed()
end

function WebClient.CheckInited()
    return Fed_Lua.CheckInited()
end

function WebClient.Login(complete)
    local params = {}
    params['game'] = GetGameId()
    local uuid = GetUuid()
    params['bindid'] = uuid 
    params['passwd'] = GeneratePassword(uuid)
    WebRequest.Post_Lua(GetSrvUrl(), 'account/login', params,
        function(success, payload)
            if success then
                local data = json.decode(payload)
                if not data.code then
                    WebClient.loginSuccess = true
                    WebClient.uid = tonumber(data.id)
                    WebClient.token = data.token
                    if complete then
                        complete()
                    end
                end
            end
        end
    )
end


function WebClient.Post(func, params, complete)
    params['token'] = WebClient.token
    params['game'] = GetGameId()
    params['id'] = WebClient.uid
    WebRequest.Post_Lua(
        GetSrvUrl(), func, params, 
        function(suc, payload)
            if complete then
                if suc then
                    local p = json.decode(payload) 
                    if not p.code then
                        complete(true, p)
                        return
                    end
                end
                complete(false)
            end
        end)
end

function WebClient.GetPlayerToken(complete)
    local params = {}
    params['game'] = GetGameId()
    params['id'] = WebClient.uid
    params['passwd'] = GeneratePassword(GetUuid())
    params['refreshToken'] = token
    WebRequest.Post_Lua(GetSrvUrl(), 'account/getToken', params,
        function(success, payload)
            if success then
                local data = json.decode(payload)
                if not data.code then
                    WebClient.token = data.token
                    if complete then
                        complete()
                    end
                end
            end
        end
    )
end

function WebClient.GetPlayerProfile()
    local params = {}
    params['token'] = WebClient.token
    params['game'] = GetGameId()
    params['id'] = WebClient.uid
    WebRequest.Post_Lua(GetSrvUrl(), 'profile/get', params,
        function(success, payload)
            if success then
                local data = json.decode(payload)
                if not data.code then

                end
            end
        end
    )
end

return WebClient