
function TraceErr(str)
    str = str or ''
    logError(str..'\n'..debug.traceback())
end

function LogE (str)
    return TraceErr('[Lua]'..str)
end

function LogW(str)
    logWarning('[Lua]'..str..'\n'..debug.traceback())
end

function LogTrace(str)
    str = str or ''
    print(str..' in '..debug.traceback())
end

