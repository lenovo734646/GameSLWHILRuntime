
function moduledef(paramT)
    local t = paramT.t
    local name = paramT.name
    local seeall = paramT.seeall
    local seenamespace = paramT.seenamespace
    local _t = t or {}
    if name then
        _G[name] = _t
    end
    if seeall then
        setmetatable(_t, {__index = _G}) 
    end
    if seenamespace then
        setmetatable(_t, {__index = seenamespace}) 
    end
    return _t
end

--FrameWork
_G.json = require "LuaUtil.dkjson"
require "LuaUtil.Functions"
require "LuaUtil.LuaDefines"


--Message
require "Message.MessageCenter"
MsgType = require "Message.MessageType"



--Pool
require "Pool.PoolManager"



