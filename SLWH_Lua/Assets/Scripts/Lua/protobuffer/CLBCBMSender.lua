--以下是由.proto自动生成的代码
local print = print
local debug = debug
local logError,logWarning,log = logError,logWarning,log
local clock = os.clock
local yield = coroutine.yield
local PBHelper = require'protobuffer.PBHelper'
local ErrorPaser = require'LuaUtil.ErrorPaser'.Paser
_ENV = {}

local timeoutSetting = 10

function SetTimeoutSetting(time)
    timeoutSetting = time
end

local Send = PBHelper.Send
local AsyncRequest = PBHelper.AsyncRequest
    
local function LogE(str)
    logError('[CLBCBMSender]'..str..'\n'..debug.traceback())
end

local function LogW(str)
    logWarning('[CLBCBMSender]'..str..'\n'..debug.traceback())
end

local function Log(str)
    log('[CLBCBMSender]'..str..'\n'..debug.traceback())
end

PBHelper.AddPbPkg("CLBCBM")

--返回的表内容(协程方法Async同样适用):
-- errcode                      0成功 1已经在房间中 2房间人数已满 3系统错误
-- bet_config_array    筹码配置数组
-- state                        1押注中 2开奖中
-- left_time                    当前阶段剩余秒数
-- last_bet_id                  上次的押注选择
-- normal_show_time                在不出鲨鱼的情况下，服务器约定的显示结果时间
-- shark_more_show_time            在出鲨鱼的情况下，服务器约定的显示结果时间
-- self_score                       玩家当前的分数
-- online_player_count              在线玩家数量
-- self_bet_list       我自己已下注数组
-- self_user_id                self UserID
-- self_user_name              玩家昵称
-- self_user_Head                玩家头像
-- self_user_HeadFrame           玩家头像框
-- bankerInfo 
function Send_EnterRoomReq(callback)
    local senddata = {}
    AsyncRequest('CLBCBM.EnterRoomReq',senddata,'CLBCBM.EnterRoomAck',callback)
end

function Send_EnterRoomReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.EnterRoomReq',senddata,'CLBCBM.EnterRoomAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.EnterRoomReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.EnterRoomAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功 1你不在房间中
function Send_ExitRoomReq(callback)
    local senddata = {}
    AsyncRequest('CLBCBM.ExitRoomReq',senddata,'CLBCBM.ExitRoomAck',callback)
end

function Send_ExitRoomReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.ExitRoomReq',senddata,'CLBCBM.ExitRoomAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.ExitRoomReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.ExitRoomAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功 1你不在房间中 2阶段不对 3筹码不合法 4押注项不合法 5金币不足 6超过下注最大上限 7庄家不可以下注
-- self_score                       玩家当前的分数
-- self_bet_info      自己下注信息
function Send_SetBetReq(callback, animal_id, bet_id)
    local senddata = {animal_id = animal_id, bet_id = bet_id, }
    AsyncRequest('CLBCBM.SetBetReq',senddata,'CLBCBM.SetBetAck',callback)
end

function Send_SetBetReq_Async(animal_id, bet_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {animal_id = animal_id, bet_id = bet_id, }
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.SetBetReq',senddata,'CLBCBM.SetBetAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.SetBetReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.SetBetAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- icon_list    历史记录列表
function Send_HistoryReq(callback)
    local senddata = {}
    AsyncRequest('CLBCBM.HistoryReq',senddata,'CLBCBM.HistoryAck',callback)
end

function Send_HistoryReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.HistoryReq',senddata,'CLBCBM.HistoryAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.HistoryReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.HistoryAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功 1不在房间中, 2分数不足 3vip等级不够
-- errcode              0成功 1已经是庄家，本局结束自动下庄
function Send_ApplyBankerReq(callback, user_id)
    local senddata = {user_id = user_id, }
    AsyncRequest('CLBCBM.ApplyBankerReq',senddata,'CLBCBM.ApplyBankerAck',callback)
end

function Send_ApplyBankerReq_Async(user_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {user_id = user_id, }
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.ApplyBankerReq',senddata,'CLBCBM.ApplyBankerAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.ApplyBankerReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.ApplyBankerAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功 1已经是庄家，本局结束自动下庄
function Send_CancelApplyBankerReq(callback, user_id)
    local senddata = {user_id = user_id, }
    AsyncRequest('CLBCBM.CancelApplyBankerReq',senddata,'CLBCBM.CancelApplyBankerAck',callback)
end

function Send_CancelApplyBankerReq_Async(user_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {user_id = user_id, }
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLBCBM.CancelApplyBankerReq',senddata,'CLBCBM.CancelApplyBankerAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLBCBM.CancelApplyBankerReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLBCBM.CancelApplyBankerAck')
        end
        return nil,data.errcode
    end
    return data
end


return _ENV
