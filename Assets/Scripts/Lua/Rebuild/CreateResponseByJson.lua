local _G = _G
local g_Env = g_Env
local print, tostring, package,SysDefines, typeof, pcall, LogE,string,type,TraceErr =
      print, tostring, package,SysDefines, typeof, pcall, LogE,string,type,TraceErr

local print, tostring, require,pairs, ipairs, getmetatable, assert,coroutine,rawset=
      print, tostring, require,pairs, ipairs, getmetatable, assert,coroutine,rawset

local tinset = table.insert
local json  = require'LuaUtil.dkjson'
local _CS = CS

_ENV = moduledef { seenamespace = CS }

local tset = function (t,k,v)
      t[k]=v
end

local function firstToUpper(str)
      return (str:gsub("^%l", string.upper))
  end
local function convertStr(str)
      str = str:gsub("_(%l)", string.upper)
      return firstToUpper(str)
end
--目前在C#里面被调用
function CreateResponseByJson(jsonstr)
      local jt = json.decode(jsonstr)
      for k, v in pairs(jt)do
            local typename = convertStr(k)
            local Type = QL.Protocol[typename]
            local rsp = Type()
            rsp.Body = jsonstr
            for kk, vv in pairs(v)do
                  local kk = convertStr(kk)
                  local status, err = pcall(tset,rsp,kk,vv)
                --  print(kk,vv)
                  if not status then
                      print('------------------',err, typename, kk, vv)
                  end
            end
            return rsp
      end
      assert(false)
end

return _ENV