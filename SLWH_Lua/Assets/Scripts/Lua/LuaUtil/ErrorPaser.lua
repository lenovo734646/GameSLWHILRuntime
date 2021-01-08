local _G = _G
local g_Env,class = g_Env,class
local print, tostring, SysDefines, typeof, debug, LogE,LogW,string, assert =
      print, tostring, SysDefines, typeof, debug, LogE,LogW,string, assert

local BuildStr = require'LuaUtil.Helpers'.BuildStr

_ENV = {}

function Paser(errCode, ackname)
    local str = BuildStr('错误',errCode, ackname)
    LogW('TODO 通用的错误解析器 '..tostring(str))
    return str
end

return _ENV