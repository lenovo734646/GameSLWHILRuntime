local _G = _G

local protoc = require "protobuffer.protoc"
local pb = require "pb"
local pbencode = pb.encode
local pbdecode = pb.decode
local netComponent = CS.NetController.Instance.netComponent
local assert,debug,print,require,io =
assert,debug,print,require,io
local tinsert = table.insert
local tremove = table.remove
local logError,logWarning,log = logError,logWarning,log
local json = json
local Config = require'GameConfig'
_ENV = {}

-- local function LogE(str)
--     logError('[PBHelper]'..str..'\n'..debug.traceback())
-- end

local function LogW(str)
    logWarning('[PBHelper]'..str..'\n'..debug.traceback())
end

local function Log(str)
    log('[PBHelper]'..str..'\n'..debug.traceback())
end

local comSendFunc = netComponent.Send

local ackcallbackmap = {}
local listenermap = {}
local listenercheckmap = {}

local defautpkgnamewithpoint = ''

local function netFunc(name, bytes)
    comSendFunc(netComponent, name, bytes)
end



function Init(defautpbpackagename_)
    defautpkgnamewithpoint = defautpbpackagename_..'.'
    protoc:load(Config:LoadPBString(defautpbpackagename_), defautpbpackagename_)
end

function AddPbPkg(pbpackagename_)
    protoc:load(Config:LoadPBString(pbpackagename_), pbpackagename_)
end

function Send(name, dataT)
    local bytes = pbencode(name, dataT)
    netFunc(name, bytes)
    print('Send '.. name)
end

function AsyncRequest(name, dataT, ackname, callback)
    assert(dataT)
    local bytes = pbencode(name, dataT)
    netFunc(name, bytes)
    local list = ackcallbackmap[ackname]
    if not list then
        list = {}
        ackcallbackmap[ackname] = list
    end
    tinsert(list, callback)
    --print('AsyncRequest '.. name)
end


function AddListener(name, callback, self)
    Log('AddListener name:'..name)
    if not name:Contains('.') then
        name = defautpkgnamewithpoint..name
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
        callback = function (data)
            classMemberFunc(self,data)
        end
        tinsert(list, {callback=callback,classMemberFunc=classMemberFunc})
    else
        tinsert(list, {callback=callback})
    end

end

function RemoveListener(name, callback, self)
    name = defautpkgnamewithpoint..name
    if listenercheckmap[callback] then
        listenercheckmap[callback] = nil
        local list = listenermap[name]
        assert(list)
        for i = 1, #list do
            if self then
                if list[i].classMemberFunc==callback then
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
    name = defautpkgnamewithpoint..name
    local list = listenermap[name]
    if list then
        local len = #list
        for i=1,len do
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
    -- if packName~='CLGT.KeepAliveAck' then
    --     Log('OnReceiveNetData '..packName)
    -- end

    local cblist = ackcallbackmap[packName]
    local decodeddata
    if cblist then
        local cb = cblist[1]
        decodeddata = pbdecode(packName, data.pbdata)
        cb(decodeddata)
        tremove(cblist, 1)
        if #cblist==0 then
            ackcallbackmap[packName] = nil
        end
    end
    local list = listenermap[packName]
    if list then
        local data = decodeddata or pbdecode(packName, data.pbdata)
        for i=1,#list do
            list[i].callback(data)
        end
    end
end



return _ENV