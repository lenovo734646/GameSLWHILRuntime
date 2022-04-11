local yield = coroutine.yield

local Class = class()

function Class.Create(...)
    return Class(...)
end

function Class:AutoLoginAsync()

    local errRsp, rsp = GG.WebRequest.GetGateConnectionAsync(1)
    if errRsp then
        return false, errRsp.msg
    end
    local Ip, Port = rsp.ip, _G.tonumber(rsp.port)
    SEnv.ipinfo = {
        Ip = Ip,
        Port = Port
    }
    Log('Ip', Ip, 'Port',Port)

    if (GF.string.IsNullOrEmpty(SEnv.ipinfo.Ip)) then
        SEnv.gamectrl.GetIpPort(true)
        return false, _G._STR_ "连接服务器出了点问题，请稍后再试！"
    end
    local loginType = 1

    Log('正在登录...')

    local req = GS.NetController.WaitForConnect(SEnv.ipinfo.Ip, SEnv.ipinfo.Port)
    yield(req)
    local state = req.state
    if state ~= 'Established' then
        if state == 'Disconnect' then
            return false, _G._STR_ "与服务器连接中断！"
        elseif state == 'Error' then
            return false, _G._STR_ "连接服务器失败，请稍后再试！"
        else
            assert(false, 'NET_CONNECT state:' .. tostring(state))
        end
    end

    -- 登录配置
    local deviceUniqueIdentifier = GS.UnityEngine.SystemInfo.deviceUniqueIdentifier
    local rsp, err = GG.CLGTSender.Send_HandReq_Async(GS.UnityHelper.GetPlatformInt(), 1, 1, deviceUniqueIdentifier,
                         SEnv.channel, "ZH-CN", "CN")

    if err then
        return false, err
    end
    Log(_G.json.encode(rsp))

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

    local rsp, err = GG.CLGTSender.Send_LoginReq_Async(loginType, token)
    if err then
        return false, err
    end

    Log('玩家账号信息：' .. GF.table.Log(rsp))
    SEnv.gamePlayer = GG.GamePlayer(rsp)
    self:StartAliveCor()
    SEnv.curLoginState = true
    -- 注册Module

    local serverName = GS.LuaEntry.Instance.gameName
    Log('登录', serverName)
    local data, errmsg = GG.CLGTSender.Send_AccessServiceReq_Async(serverName, 1, '')
    if errmsg then
        if self.co then
            GG.CoroutineHelper.StopCoroutine(self.co)
        end
        return false, errmsg
    end
    local game_data = data.game_data -- game_data目前还没什么用
    
    return true
end

function Class:StartAliveCor()
    self.co = GG.CoroutineHelper.StartCoroutine(function()
        while true do
            yield(GS.UnityEngine.WaitForSeconds(9))
            GG.CLGTSender.Send_KeepAliveReq_Async()
        end
    end)
end

return Class
