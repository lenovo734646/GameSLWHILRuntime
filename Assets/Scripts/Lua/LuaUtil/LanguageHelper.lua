local _G = _G
local SEnv, class = SEnv, class
local table, print, tostring, SysDefines, typeof, LogW, LogE, string, assert, pairs = table, print, tostring,
    SysDefines, typeof, LogW, LogE, string, assert, pairs

local LanguageErrcode = require 'Table.LanguageErrcode'
local DisconnectTips = require 'Table.DisconnectTips'
local LanguageT = require 'Table.Language'
local os=os
local SysDefines = SysDefines

_ENV = moduledef {
    seenamespace = CS
}

function GetServerErrorMsg(code, msgName)
    msgName = msgName:Replace('.', '')
    local key = msgName ..'_' ..code
    print('GetServerErrorMsg',key)
    local _,rt = table.findKV(LanguageErrcode, function(k, v)
        return v.key == key
    end)
    local curLanguage = SysDefines.curLanguage
    if rt then
        local err = rt[curLanguage]
        if err then
            return err
        end
    end

    if curLanguage == 'CN' then
        return '未知错误!代码:' .. msgName .. code
    else
        return 'Unknown Error! code:' .. msgName .. code
    end
end

function GetDisconnectTips(ntf)
    local code = ntf.code
    local curLanguage = SysDefines.curLanguage
    local tiplang = 'Tips'
    if curLanguage~='CN' then
        tiplang = 'Tips_'..curLanguage
    end

    if code==9 then
        return ntf.errmessage
    end

    local tips = table.findBy(DisconnectTips, function(v)
        return v.Code == code
    end)[tiplang]
    if tips then
        return tips
    end
    if curLanguage == 'CN' then
        return '未知错误!代码:' .. code
    else
        return 'Unknown Error! code:' .. code
    end
end

function GetLanguageT(key)
    local tt = table.findBy(LanguageT, function(t)
        return t.key == key
    end)
    return tt[SysDefines.curLanguage] or tt.CN
end

SEnv.GetLanguageT = SEnv.GetLanguageT or GetLanguageT
SEnv.ConvertByLang = SEnv.ConvertByLang or function (prefabName)
    return prefabName:Replace('.prefab','_'..SysDefines.curLanguage..'.prefab')
end

local constantStringConvertor = {}

_G._STR_ = _G._STR_ or function (str)
    local t = constantStringConvertor[str]
    if not t then
        return str
    end
    return t[SysDefines.curLanguage] or str
end

function string.FormatDate(month,day,year)
    year = year or 2019
    if SysDefines.curLanguage=='CN' then
        os.setlocale("chs")
        return os.date("%Y%b%d日",os.time{year=year,month=month,day=day})
    else
        os.setlocale("eng")
        return os.date("%b/%d/%Y",os.time{year=year,month=month,day=day})
    end    
end

return _ENV