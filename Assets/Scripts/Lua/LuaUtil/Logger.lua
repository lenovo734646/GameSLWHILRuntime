local debug = debug
local assert = assert
local BuildStr = require'LuaUtil.Helpers'.BuildStr
local UnityHelper = CS.UnityHelper
local gLuaEntryCom=gLuaEntryCom
local logError=logError
local log = log
local logWarning=logWarning
local print=print

function TraceErr(str)
    str = str or ''
    logError(str .. '\n' .. debug.traceback())
end

function LogE(...)
    return TraceErr('[Lua]' .. BuildStr(...))
end

function LogW(...)
    logWarning('[Lua]' .. BuildStr(...) .. '\n' .. debug.traceback())
end

function Log(...)
    log('[Lua]' .. BuildStr(...) .. '\n' .. debug.traceback())
end

function LogTrace(str)
    str = str or ''
    print(str .. ' in ' .. debug.traceback())
end

function Assert(b, ...)
    if not b then
        assert(b, BuildStr(...))
    end
end

function AssertAndShowError(b,...)
    if not b then
        gLuaEntryCom:ShowError(BuildStr(...)..": "..debug.traceback())
    end
end

function AssertUnityObjValid(obj, ...)
    if not UnityHelper.IsUnityObjectValid(obj) then
        gLuaEntryCom:ShowError("ÎÞÐ§µÄUnityObject: "..BuildStr(...)..": "..debug.traceback())
        -- LogE("AssertUnityObjValid type = ", type(b), b, ...)
    end
    --return assert(UnityHelper.IsUnityObjectValid(b), BuildStr(...))
end
