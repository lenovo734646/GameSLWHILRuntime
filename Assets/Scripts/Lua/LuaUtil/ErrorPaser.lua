local tostring = tostring
--想要方便测试，就在这里加上转换表
_ENV = {}
local convertTable = {
}
Paser = g_Env and g_Env.GetServerErrorMsg or function(errCode, ackname)
    local errstr = convertTable[ackname] and convertTable[ackname][errCode] or nil
    return errstr or ('服务器返回错误errCode='..tostring(errCode)..' ackname='..tostring(ackname))
end
return _ENV