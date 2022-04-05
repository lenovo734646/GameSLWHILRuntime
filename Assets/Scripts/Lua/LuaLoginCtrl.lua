local GS = GS
local GF = GF
local _G = _G
local class = class
local print, tostring, type, debug, pairs, string, assert
    = print, tostring, type, debug, pairs, string, assert

local LogW = LogW
local json = json
local CLGTSender = require 'protobuffer.CLGTSender'
local GamePlayer = require 'Module.GamePlayer'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local GetGateConnectionAsync = require'WebRequest'.GetGateConnectionAsync
local SEnv = SEnv

local yield = coroutine.yield

_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end

function Class:AutoLoginAsync()

    local errRsp, rsp = GetGateConnectionAsync(1)
    if errRsp then
        return false,errRsp.msg
    end
    local Ip, Port = rsp.ip, _G.tonumber(rsp.port)
    SEnv.ipinfo = {
        Ip = Ip,
        Port = Port,
    }
    print('Ip', Ip, 'Port',Port)

    if (GF.string.IsNullOrEmpty(SEnv.ipinfo.Ip)) then
        SEnv.gamectrl.GetIpPort(true)
        return false, _G._STR_"连接服务器出了点问题，请稍后再试！"
    end
    local loginType = 1

    print('正在登录...')

    local req = GS.NetController.WaitForConnect(SEnv.ipinfo.Ip, SEnv.ipinfo.Port)
    yield(req)
    local state = req.state
    if state ~= 'Established' then
        if state == 'Disconnect' then
            return false, _G._STR_"与服务器连接中断！"
        elseif state == 'Error' then
            return false, _G._STR_"连接服务器失败，请稍后再试！"
        else
            assert(false, 'NET_CONNECT state:' .. tostring(state))
        end
    end

    -- 登录配置
    local deviceUniqueIdentifier = GS.UnityEngine.SystemInfo.deviceUniqueIdentifier
    local rsp, err = CLGTSender.Send_HandReq_Async(GS.UnityHelper.GetPlatformInt(), 1, 1, deviceUniqueIdentifier,
                         SEnv.channel, "ZH-CN", "CN")

    if err then
        return false, err
    end
    print(json.encode(rsp))
    GS.NetController.Instance:SetKey(rsp.session_guid, rsp.random_key_arr)
    SEnv.isNetConnected = true
    SEnv.LoginType = loginType
    local token
    if loginType == 1 then -- 游客登录
        token = deviceUniqueIdentifier
    elseif loginType == 2 then -- 账号登录
        token = SEnv.loginInfo.LoginToken
        assert(token)
    else
        token = ','
        LogW('TODO需要连接第三方登录id字符串')
    end

    local rsp, err = CLGTSender.Send_LoginReq_Async(loginType, token)
    if err then
        return false, err
    end
    print('玩家账号信息：', json.encode(rsp))
    SEnv.gamePlayer = GamePlayer(rsp)
    self:StartAliveCor()
    SEnv.curLoginState = true
    -- 注册Module

    local serverName = GS.LuaEntry.Instance.gameName
    print('登录',serverName)
    local data, errmsg = CLGTSender.Send_AccessServiceReq_Async(serverName,1,'')
    if errmsg then
        if self.co then
            CoroutineHelper.StopCoroutine(self.co)
        end
        return false, errmsg
    end
    local game_data = data.game_data --game_data目前还没什么用
    return true
end

function Class:StartAliveCor()
    self.co = CoroutineHelper.StartCoroutine(function()
        while true do
            yield(GS.UnityEngine.WaitForSeconds(9))
            CLGTSender.Send_KeepAliveReq_Async()
        end
    end)
end

return _ENV
