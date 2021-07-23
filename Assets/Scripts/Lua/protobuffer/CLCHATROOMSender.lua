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
    logw('[CLCHATROOMSender]',...)
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

PBHelper.AddPbPkg("CLCHATROOM")

--返回的表内容(协程方法Async同样适用):
-- errcode                   0成功 1你不在聊天室
-- total_amount              聊天室总人数
-- players     玩家信息数组
function Send_QueryPlayerListReq(callback, page_index, page_count)
    local senddata = {page_index = page_index, page_count = page_count, }
   return AsyncRequest('CLCHATROOM.QueryPlayerListReq',senddata,'CLCHATROOM.QueryPlayerListAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLCHATROOM.QueryPlayerListAck')
        return callback(ack)
    end)
end

function Send_QueryPlayerListReq_Async(page_index, page_count, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {page_index = page_index, page_count = page_count, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLCHATROOM.QueryPlayerListReq',senddata,'CLCHATROOM.QueryPlayerListAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLCHATROOM.QueryPlayerListReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.QueryPlayerListAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode                   0成功 1你不在聊天室
-- total_amount              聊天室总人数
function Send_QueryPlayerAmountReq(callback)
    local senddata = {}
   return AsyncRequest('CLCHATROOM.QueryPlayerAmountReq',senddata,'CLCHATROOM.QueryPlayerAmountAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLCHATROOM.QueryPlayerAmountAck')
        return callback(ack)
    end)
end

function Send_QueryPlayerAmountReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLCHATROOM.QueryPlayerAmountReq',senddata,'CLCHATROOM.QueryPlayerAmountAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLCHATROOM.QueryPlayerAmountReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.QueryPlayerAmountAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功
-- upload_url           上传链接
-- download_url         上传完成后的下载地址（当上传成功后发送语音消息时需要回传到服务器）
function Send_QueryUploadUrlReq(callback)
    local senddata = {}
   return AsyncRequest('CLCHATROOM.QueryUploadUrlReq',senddata,'CLCHATROOM.QueryUploadUrlAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLCHATROOM.QueryUploadUrlAck')
        return callback(ack)
    end)
end

function Send_QueryUploadUrlReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLCHATROOM.QueryUploadUrlReq',senddata,'CLCHATROOM.QueryUploadUrlAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLCHATROOM.QueryUploadUrlReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.QueryUploadUrlAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode               0成功 1你不在聊天室 2发送内容太长 3不支持的消息类型
function Send_SendChatMessageReq(callback, message_type, content, metadata)
    local senddata = {message_type = message_type, content = content, metadata = metadata, }
   return AsyncRequest('CLCHATROOM.SendChatMessageReq',senddata,'CLCHATROOM.SendChatMessageAck',function (ack)
        ack._errmessage = handleAckError(ack,'CLCHATROOM.SendChatMessageAck')
        return callback(ack)
    end)
end

function Send_SendChatMessageReq_Async(message_type, content, metadata, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {message_type = message_type, content = content, metadata = metadata, }
    local data
    local dataCheck={}
    local callback = function(data_) data = data_;dataCheck.ok=true end
    AsyncRequest('CLCHATROOM.SendChatMessageReq',senddata,'CLCHATROOM.SendChatMessageAck',callback)
    local haserror,msg = WaitForResultOrTimeOut(dataCheck,'CLCHATROOM.SendChatMessageReq')
    if haserror then return nil,msg end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.SendChatMessageAck')
        end
        return nil,data.errcode
    end
    return data
end


return _ENV
