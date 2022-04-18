local GS = GS
local GF = GF
local protoc = require "protobuffer.protoc"
local pb = require "pb"
local pbencode = pb.encode
local pbdecode = pb.decode

local assert, debug, print, require, io, tostring = assert, debug, print, require, io, tostring
local tinsert = table.insert
local tremove = table.remove
local Config = require 'Config'
local LogW_,log,tostring
    = LogW,Log,tostring
_ENV = {}

-- local function LogE(str)
--     logError('[PBHelper]'..str..'\n'..debug.traceback())
-- end

local function LogW(str)
    LogW_('[PBHelper]' .. str .. '\n' .. debug.traceback())
end

local function Log(str)
    log('[PBHelper]' .. str .. '\n' .. debug.traceback())
end

local netComponent
local comSendFunc
local ackcallbackmap = {}
local listenermap = {}
local listenercheckmap = {}

local defautpkgnamewithpoint = ''

local function netFunc(name, bytes)
    comSendFunc(netComponent, name, bytes)
end

function Init(defautpbpackagename_)
    if not netComponent then
        local NetInstance = GS.NetController.Instance
        netComponent = NetInstance.netComponent
        comSendFunc = netComponent.Send
        assert(netComponent)
        assert(comSendFunc)
    end
    defautpkgnamewithpoint = defautpbpackagename_ .. '.'
    protoc:load(Config:LoadPBString(defautpbpackagename_), defautpbpackagename_)
end
function Reset()
    netComponent = GS.NetController.Instance.netComponent
    comSendFunc = netComponent.Send
end

function AddPbPkg(pbpackagename_)
    protoc:load(Config:LoadPBString(pbpackagename_), pbpackagename_)
end

function Send(name, dataT)
    local bytes = pbencode(name, dataT)
    netFunc(name, bytes)
    -- print('Send ' .. name)
end

function AsyncRequest(name, dataT, ackname, callback)
    assert(dataT)
    -- print('AsyncRequest '.. name)
    local bytes = pbencode(name, dataT)
    -- print('AsyncRequest name：' .. name .. " bytes:" .. tostring(bytes))
    netFunc(name, bytes)
    local list = ackcallbackmap[ackname]
    if not list then
        list = {}
        ackcallbackmap[ackname] = list
    end
    tinsert(list, callback)
end

function AddListener(name, callback, self)
    -- Log('AddListener name:'..name)
    if not GF.string.Contains(name, '.') then
        name = defautpkgnamewithpoint .. name
    end

    if listenercheckmap[callback] then
        LogW('事件注册重复!')
        return
    end
    listenercheckmap[callback] = true
    local list = listenermap[name]
    if not list then
        list = {}
        listenermap[name] = list
    end
    if self then
        local classMemberFunc = callback
        callback = function(data)
            classMemberFunc(self, data)
        end
        tinsert(list, {
            callback = callback,
            classMemberFunc = classMemberFunc
        })
    else
        tinsert(list, {
            callback = callback
        })
    end

end

function RemoveListener(name, callback, self)
    if not GF.string.Contains(name, '.') then
        name = defautpkgnamewithpoint .. name
    end
    if listenercheckmap[callback] then
        listenercheckmap[callback] = nil
        local list = listenermap[name]
        assert(list)
        for i = 1, #list do
            if self then
                if list[i].classMemberFunc == callback then
                    tremove(list, i)
                    break
                end
            elseif list[i].callback == callback then
                tremove(list, i)
                break
            end
        end
    end
end

function RemoveAllListenerByName(name)
    if not GF.string.Contains(name, '.') then
        name = defautpkgnamewithpoint .. name
    end
    local list = listenermap[name]
    if list then
        local len = #list
        for i = 1, len do
            listenercheckmap[list[i]] = nil
        end
        listenermap[name] = nil
    end
end

function RemoveAllListener()
    listenermap = {}
    listenercheckmap = {}
end

function OnReceiveNetData(data, packName)
    -- if packName ~= 'CLGT.KeepAliveAck' then
    --     Log('OnReceiveNetData ' .. packName)
    -- end
    --print("packName = ", packName)
    local pbdata = data.pbdata
    local cblist = ackcallbackmap[packName]
    local decodeddata
    if cblist then
        local cb = cblist[1]
        decodeddata = pbdecode(packName, pbdata)
        cb(decodeddata)
        tremove(cblist, 1)
        if #cblist == 0 then
            ackcallbackmap[packName] = nil
        end
    end
    local list = listenermap[packName]
    -- print('packname:'..packName.." 消息队列是不是空："..tostring(list==nil))
    if list then
        local data = decodeddata or pbdecode(packName, pbdata)
        for i = 1, #list do
            list[i].callback(data)
        end
    end
end

return _ENV
