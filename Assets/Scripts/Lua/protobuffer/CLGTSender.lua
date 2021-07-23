--以下是由.proto自动生成的代码,生成工具版本1.2
local SEnv,_STR_ = SEnv,_STR_
local logw = LogW
local clock = os.clock
local yield = coroutine.yield
local NetController = CS.NetController
local PBHelper = require'protobuffer.PBHelper'
local ErrorPaser = SEnv and SEnv.ErrorPaser or require'LuaUtil.ErrorPaser'.Paser
local print = print
_ENV = {}
local timeoutSetting = 10
function SetTimeoutSetting(time)
    timeoutSetting = time
end
local Send = PBHelper.Send
local AsyncRequest = PBHelper.AsyncRequest

local function LogW(...)
    logw('[CLGTSender]',...)
end

local function WaitForResultOrTimeOut(dataCheck,reqname)
    local time = clock()
    yield()
    while not dataCheck.ok do
        yield()
        if clock()-time > timeoutSetting then
            local msg = _STR_("请求超时!错误代码:")..reqname
            LogW(msg)
            return true,msg
        end
        if not NetController.IsNetConnected then
            return true,_STR_'连接意外中断，代码:'..reqname
        end
    end
    return false
end
local function handleAckError(ack,ackname)
    if ack.errcode ~= 0 then
        return ErrorPaser(ack.errcode,ackname)
    end
end

PBHelper.AddPbPkg("CLGT")

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功 1无法识别的平台 2无法识别的产品 3版本太老需强更 4拒绝访问 5你的IP已被封禁 6你的设备已被封禁
-- payload               当前网关负载
-- random_key            随机秘钥数组
-- random_key_arr 
function Send_HandReq(callback, platform, product, version, device, channel, country, language)
    local senddata = {platform = platform, product = product, version = version, device = device, channel = channel, country = country, language = language, }
   return AsyncRequest('CLGT.HandReq',senddata,'CLGT.HandAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLGT.HandAck')
        return callback(ack)
    end)
end

function Send_HandReq_Async(platform, product, version, device, channel, country, language, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {platform = platform, product = product, version = version, device = device, channel = channel, country = country, language = language, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLGT.HandReq',senddata,'CLGT.HandAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLGT.HandReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLGT.HandAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode                       0成功 1平台服务器不可用 2账号被封禁 3系统繁忙 4系统错误 5系统暂未开放
-- user_id                       玩家Id
-- nickname                     昵称
-- nickname_mdf                   昵称是否修改过
-- gender                        性别 0保密 1男 2女
-- head                          头像Id
-- head_frame                    头像框Id
-- level                         玩家等级
-- level_exp                     等级经验
-- vip_level                    vip等级
-- vip_level_exp                vip等级经验
-- phone                       手机号
-- diamond                      钻石
-- currency                     平台货币
-- bind_currency                绑定货币
-- integral                     积分
-- items            物品数组
-- server_timestamp           服务器时间戳
-- has_unread_mail               是否有未读邮件
-- guild_id                     当前已加入的公会Id
-- guild_join_list_state         是否还有未处理的公会申请
-- month_card_expire_time      月卡过期时间戳
-- month_card_has_fetched        月卡当天奖励是否已领取过
-- finish_first_recharge         是否已完成首充礼包
-- relief_finish_count          当天救济金领取次数
-- fetched_first_package         是否领取了新手起航礼包
-- client_config_md5           最新客户端配置表的md5
-- max_gun_value                最大解锁炮倍
-- time_string                 账号解封时间或系统开放时间，空串代表永久
-- bank_password_flag            是否已设置金库密码
-- is_businessman                是否商人
-- agent_level                  全民代理等级 有些服需要根据代理等级决定是否可以推广
-- continuous_reward           持续奖励数组，格式：[购买内容Id,过期时间戳,当日是否已领取1是0否]
-- rank_reward_gold              是否有可领取的金币榜奖励
-- rank_reward_warhead           是否有可领取的弹头榜奖励
-- bank_currency                银行金币数量
-- last_game_appid             最近参与的游戏AppId，用于客户端AccessService的app_id字段
function Send_LoginReq(callback, login_type, token)
    local senddata = {login_type = login_type, token = token, }
   return AsyncRequest('CLGT.LoginReq',senddata,'CLGT.LoginAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLGT.LoginAck')
        return callback(ack)
    end)
end

function Send_LoginReq_Async(login_type, token, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {login_type = login_type, token = token, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLGT.LoginReq',senddata,'CLGT.LoginAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLGT.LoginReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLGT.LoginAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容为空
function Send_AdminLoginReq(callback, user_id)
    local senddata = {user_id = user_id, }
   return AsyncRequest('CLGT.AdminLoginReq',senddata,'CLGT.AdminLoginAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLGT.AdminLoginAck')
        return callback(ack)
    end)
end

function Send_AdminLoginReq_Async(user_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {user_id = user_id, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLGT.AdminLoginReq',senddata,'CLGT.AdminLoginAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLGT.AdminLoginReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLGT.AdminLoginAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功 1服务不存在 2拒绝访问
-- game_data            上次未结束的游戏数据，json格式
function Send_AccessServiceReq(callback, server_name, action, app_id)
    local senddata = {server_name = server_name, action = action, app_id = app_id, }
   return AsyncRequest('CLGT.AccessServiceReq',senddata,'CLGT.AccessServiceAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLGT.AccessServiceAck')
        return callback(ack)
    end)
end

function Send_AccessServiceReq_Async(server_name, action, app_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {server_name = server_name, action = action, app_id = app_id, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLGT.AccessServiceReq',senddata,'CLGT.AccessServiceAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLGT.AccessServiceReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLGT.AccessServiceAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功
function Send_KeepAliveReq(callback)
    local senddata = {}
   return AsyncRequest('CLGT.KeepAliveReq',senddata,'CLGT.KeepAliveAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLGT.KeepAliveAck')
        return callback(ack)
    end)
end

function Send_KeepAliveReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLGT.KeepAliveReq',senddata,'CLGT.KeepAliveAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLGT.KeepAliveReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLGT.KeepAliveAck')
        end
        return nil,data.errcode
    end
    return data
end


return _ENV
