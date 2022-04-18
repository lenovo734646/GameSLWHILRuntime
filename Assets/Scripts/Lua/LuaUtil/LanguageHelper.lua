local Class = class()

function Class.GetServerErrorMsg(code, msgName)
    msgName = msgName:Replace('.', '')
    local key = msgName ..'_' ..code
    Log('GetServerErrorMsg',key)
    local _,rt = GF.table.findKV(GG.LanguageErrcode, function(k, v)
        return v.key == key
    end)
    local curLanguage = GS.SysDefines.curLanguage
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

function Class.GetDisconnectTips(ntf)
    local code = ntf.code
    local curLanguage = GS.SysDefines.curLanguage
    local tiplang = 'Tips'
    if curLanguage~='CN' then
        tiplang = 'Tips_'..curLanguage
    end

    if code==9 then
        return ntf.errmessage
    end

    local tips = GF.table.FindBy(GG.DisconnectTips, function(v)
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

function Class.GetLanguageT(key)
    local tt = GF.table.FindBy(GG.Language, function(t)
        return t.key == key
    end)
    return tt[GS.SysDefines.curLanguage] or tt.CN
end

SEnv.GetLanguageT = SEnv.GetLanguageT or Class.GetLanguageT
SEnv.ConvertByLang = SEnv.ConvertByLang or function (prefabName)
    return prefabName:Replace('.prefab','_'..GS.SysDefines.curLanguage..'.prefab')
end

-- local constantStringConvertor = {}

-- _G._STR_ = _G._STR_ or function (str)
--     local t = constantStringConvertor[str]
--     if not t then
--         return str
--     end
--     return t[GS.SysDefines.curLanguage] or str
-- end


return Class