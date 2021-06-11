--以下是由.proto自动生成的代码
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
    logError('[CLCHATROOMSender]'..str..'\n'..debug.traceback())
end

local function LogW(str)
    logWarning('[CLCHATROOMSender]'..str..'\n'..debug.traceback())
end

local function Log(str)
    log('[CLCHATROOMSender]'..str..'\n'..debug.traceback())
end

PBHelper.AddPbPkg("CLCHATROOM")

--返回的表内容(协程方法Async同样适用):
-- errcode                  0成功 1你不在聊天室
-- total_amount             聊天室总人数
-- players    玩家信息数组
function Send_QueryPlayerListReq(callback, page_index, page_count)
    local senddata = {page_index = page_index, page_count = page_count, }
    AsyncRequest('CLCHATROOM.QueryPlayerListReq',senddata,'CLCHATROOM.QueryPlayerListAck',callback)
end

function Send_QueryPlayerListReq_Async(page_index, page_count, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {page_index = page_index, page_count = page_count, }
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLCHATROOM.QueryPlayerListReq',senddata,'CLCHATROOM.QueryPlayerListAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLCHATROOM.QueryPlayerListReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.QueryPlayerListAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功
-- upload_url          上传链接
-- download_url        上传完成后的下载地址（当上传成功后发送语音消息时需要回传到服务器）
function Send_QueryUploadUrlReq(callback)
    local senddata = {}
    AsyncRequest('CLCHATROOM.QueryUploadUrlReq',senddata,'CLCHATROOM.QueryUploadUrlAck',callback)
end

function Send_QueryUploadUrlReq_Async(err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {}
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLCHATROOM.QueryUploadUrlReq',senddata,'CLCHATROOM.QueryUploadUrlAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLCHATROOM.QueryUploadUrlReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.QueryUploadUrlAck')
        end
        return nil,data.errcode
    end
    return data
end

--返回的表内容(协程方法Async同样适用):
-- errcode              0成功 1你不在聊天室 2发送内容太长 3不支持的消息类型
function Send_SendChatMessageReq(callback, message_type, content, metadata)
    local senddata = {message_type = message_type, content = content, metadata = metadata, }
    AsyncRequest('CLCHATROOM.SendChatMessageReq',senddata,'CLCHATROOM.SendChatMessageAck',callback)
end

function Send_SendChatMessageReq_Async(message_type, content, metadata, err_paser)
    err_paser = err_paser or ErrorPaser
    local senddata = {message_type = message_type, content = content, metadata = metadata, }
    local data
    local callback = function(data_) data = data_ end
    AsyncRequest('CLCHATROOM.SendChatMessageReq',senddata,'CLCHATROOM.SendChatMessageAck',callback)
    local time = clock()
    while not data do
        yield()
        if clock()-time > timeoutSetting then
            local msg = "请求超时!错误代码'CLCHATROOM.SendChatMessageReq'"
            LogW(msg)
            return nil,msg
        end
    end
    if data.errcode ~= 0 then
        if err_paser then
            return nil,err_paser(data.errcode,'CLCHATROOM.SendChatMessageAck')
        end
        return nil,data.errcode
    end
    return data
end


return _ENV
