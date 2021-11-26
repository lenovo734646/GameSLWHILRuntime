--以下是由.proto自动生成的代码,生成工具版本1.2
local g_Env,_STR_ = g_Env,_STR_
local logw = LogW
local clock = os.clock
local yield = coroutine.yield
local NetController = CS.NetController
local PBHelper = require'protobuffer.PBHelper'
local ErrorPaser = g_Env and g_Env.ErrorPaser or require'LuaUtil.ErrorPaser'.Paser
_ENV = {}
local timeoutSetting = 10
function SetTimeoutSetting(time)
    timeoutSetting = time
end
local Send = PBHelper.Send
local AsyncRequest = PBHelper.AsyncRequest

local function LogW(...)
    logw('[CLSLWHSender]',...)
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

PBHelper.AddPbPkg("CLSLWH")

--返回的表内容(协程方法Async同样适用):
-- errcode                       0成功 1已经在房间中 2房间人数已满 3系统错误
-- bet_config_array     筹码配置数组
-- state                         1押注中 2开奖中
-- left_time                     当前阶段剩余秒数
-- last_bet_id                   上次的押注选择
-- normal_show_time                 在不出鲨鱼的情况下，服务器约定的显示结果时间
-- shark_more_show_time             在出鲨鱼的情况下，服务器约定的显示结果时间
-- self_score                        玩家当前的分数
-- online_player_count               在线玩家数量
-- room_total_bet_info_list 房间总下注信息
-- self_bet_info_list        我自己已下注数组
-- self_user_id                 self UserID
-- self_user_name               玩家昵称
-- self_user_Head                 玩家头像
-- self_user_HeadFrame            玩家头像框
-- last_color_index              上局中奖颜色下标
-- last_animal_index             上局中奖动物下标
function Send_EnterRoomReq(callback)
    local senddata = {}
   return AsyncRequest('CLSLWH.EnterRoomReq',senddata,'CLSLWH.EnterRoomAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.EnterRoomAck')
        return callback(ack)
    end)
end

function Send_EnterRoomReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.EnterRoomReq',senddata,'CLSLWH.EnterRoomAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.EnterRoomReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.EnterRoomAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功 1你不在房间中
function Send_ExitRoomReq(callback)
    local senddata = {}
   return AsyncRequest('CLSLWH.ExitRoomReq',senddata,'CLSLWH.ExitRoomAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.ExitRoomAck')
        return callback(ack)
    end)
end

function Send_ExitRoomReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.ExitRoomReq',senddata,'CLSLWH.ExitRoomAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.ExitRoomReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.ExitRoomAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功
-- left_time             此状态的剩余时间 2开奖状态时间应该是不固定的
-- state                 游戏状态：1、下注 2、开奖 3、空闲
-- color_array                   颜色列表1-24
-- ratio_array                   倍率列表1-12动物 13-15庄和闲
-- anim_result_list   开奖结果列表（RunItem起始点和结束点）
-- enjoy_game_ret                         庄闲和开奖结果
-- ex_ret                                 额外中奖结果（彩金，送灯，闪电翻倍）
-- caijin_ratio                           彩金倍数
-- shandian_ratio                          闪电翻倍倍数
-- self_score            玩家自己的分数
-- room_total_bet_info_list   房间总下注信息
-- self_bet_info_list              我自己已下注数组
-- time_stamp            消息时间戳
function Send_GetServerDataReq(callback)
    local senddata = {}
   return AsyncRequest('CLSLWH.GetServerDataReq',senddata,'CLSLWH.GetServerDataAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.GetServerDataAck')
        return callback(ack)
    end)
end

function Send_GetServerDataReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.GetServerDataReq',senddata,'CLSLWH.GetServerDataAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.GetServerDataReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.GetServerDataAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功 1你不在房间中 2阶段不对 3筹码不合法 4押注项不合法 5金币不足 6超过个人下注最大上限 7超过房间下注最大上限  8庄家不可以下注
-- self_score            玩家当前的分数
-- self_bet_info       自己下注信息
-- errParam              错误参数：比如下注上限等
-- room_total_bet_info_list 房间总下注信息
function Send_SetBetReq(callback, index_id, bet_id)
    local senddata = {index_id = index_id, bet_id = bet_id, }
   return AsyncRequest('CLSLWH.SetBetReq',senddata,'CLSLWH.SetBetAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.SetBetAck')
        return callback(ack)
    end)
end

function Send_SetBetReq_Async(index_id, bet_id, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {index_id = index_id, bet_id = bet_id, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.SetBetReq',senddata,'CLSLWH.SetBetAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.SetBetReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.SetBetAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功
-- record_list     历史记录列表
function Send_HistoryReq(callback)
    local senddata = {}
   return AsyncRequest('CLSLWH.HistoryReq',senddata,'CLSLWH.HistoryAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.HistoryAck')
        return callback(ack)
    end)
end

function Send_HistoryReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.HistoryReq',senddata,'CLSLWH.HistoryAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.HistoryReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.HistoryAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode                   0成功 1你不在房间内
-- total_amount              房间总人数
-- players     玩家信息数组
function Send_QueryPlayerListReq(callback, page_index, page_count)
    local senddata = {page_index = page_index, page_count = page_count, }
   return AsyncRequest('CLSLWH.QueryPlayerListReq',senddata,'CLSLWH.QueryPlayerListAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLSLWH.QueryPlayerListAck')
        return callback(ack)
    end)
end

function Send_QueryPlayerListReq_Async(page_index, page_count, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {page_index = page_index, page_count = page_count, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLSLWH.QueryPlayerListReq',senddata,'CLSLWH.QueryPlayerListAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLSLWH.QueryPlayerListReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLSLWH.QueryPlayerListAck')
        end
        return nil,data.errcode
    end
    return data
end


return _ENV
