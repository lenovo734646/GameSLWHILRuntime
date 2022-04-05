local BuildStr = require'LuaUtil.Helpers'.BuildStr

function TraceErr(str)
    str = str or ''
    GF.logError(str .. '\n' .. debug.traceback())
end

function LogE(...)
    return TraceErr('[Lua]' .. BuildStr(...))
end

function LogW(...)
    GF.logWarning('[Lua]' .. BuildStr(...) .. '\n' .. debug.traceback())
end

function Log(...)
    GF.log('[Lua]' .. BuildStr(...) .. '\n' .. debug.traceback())
end
print = Log

-- function LogTrace(str)
--     str = str or ''
--     print(str .. ' in ' .. debug.traceback())
-- end

function Assert(b, ...)
    if not b then
        LogE("Assert: "..BuildStr(...))
        assert(b, BuildStr(...))
    end
end

function AssertAndShowError(b,...)
    if not b then
        -- gLuaEntryCom:ShowError(BuildStr(...)..": "..debug.traceback())
        g_Env.HandleError(BuildStr(...))
    end
end

function AssertUnityObjValid(obj, ...)
    if not GS.UnityHelper.IsUnityObjectValid(obj) then
        -- g_Env.HandleError("无效的UnityObject: "..BuildStr(...)..": "..debug.traceback())
        LogE("AssertUnityObjValid: 无效的UnityObject: "..BuildStr(...)..": "..debug.traceback())
    end
    return assert(GS.UnityHelper.IsUnityObjectValid(obj), BuildStr(...))
end




