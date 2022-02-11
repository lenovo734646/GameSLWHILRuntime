--以下是由.xml自动生成的代码
local CS = CS
local tostring = tostring
local QWebRequset = CS.QWebRequset
local NetController = CS.NetController
local jsdecode = json.decode
local WaitLuaRequest = CS.UnityHelper.WaitLuaRequest
local yield = coroutine.yield
local clock = os.clock
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local WaitForSeconds = CS.UnityEngine.WaitForSeconds
local _G = _G
_ENV = moduledef { seenamespace = CS }
local timeoutSetting = 10
function SetTimeoutSetting(time)
    timeoutSetting = time
end

local function PostReqAsync(apiname, header, parameters,code,rspname)
    local req = QWebRequset(apiname, header, parameters)
    local creq = WaitLuaRequest(req)
    local time = clock()
    while creq.keepWaiting do
        yield()
        if clock()-time > timeoutSetting then
            local msg = _G._STR_"请求超时!错误代码:"..code
            local rsp = {msg = msg, code = -1001}
            return rsp
        end
    end
    local t = jsdecode(creq.body)
    local errRsp = t.error_response
    local rsp = t['client_'..rspname..'_response']
    return errRsp, rsp
end

--Request:
--zone_id 区服Id
--Response:
--ip ip地址
--port 端口
function GetGateConnectionAsync(zone_id)

    local header = {}
    local parameters = {
        "zone_id",tostring(zone_id),
    }
    local apiname = "client.get.gate.connection"
    return PostReqAsync(apiname,header,parameters,"GetGateConnection","get_gate_connection")
end



return _ENV
