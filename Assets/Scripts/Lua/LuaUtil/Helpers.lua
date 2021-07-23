local string, tostring, math, pairs, typeof, type, print, table, tonumber, SysDefines = string, tostring, math, pairs,
    typeof, type, print, table, tonumber, SysDefines
local LuaInitHelper = CS.LuaInitHelper

local DestroyImmediate = DestroyImmediate
local CS,AssertUnityObjValid = CS,AssertUnityObjValid
local getmetatable = getmetatable
local assert=assert
local select=select
_ENV = {}

--转换成万或者亿
function GameNumberFormat(n)
    local isEn = SysDefines.curLanguage ~= 'CN'
    local unit = ''
    if isEn then
        if n >= 1000000000 then
            n = n / 1000000000
            n = math.floor(n*100)/100
            unit = 'G'
            return n..unit
        end
        if n >= 1000000 then
            n = n / 1000000
            n = math.floor(n*100)/100
            unit = 'M'
            return n..unit
        end
        if n >= 1000 then
            n = n / 1000
            n = math.floor(n*100)/100
            unit = 'K'
            return n..unit
        end
    else
        local unit = ''
        if n >= 100000000 then
            n = n / 100000000
            n = math.floor(n*100)/100
            unit = '亿'
            return n..unit
        end
        if n >= 10000 then
            n = n / 10000
            n = math.floor(n*100)/100
            unit = '万'
            return n..unit
        end
    end
    return n..unit
end

-- 检查手机号码位数是否有效
-- 目前账号手机号格式为：国家码+手机号（如果0开头，则不需要输入0）
function IsPhoneNumValid(phoneStr)
    print("phoneStr = ", phoneStr)
    if string.IsNullOrEmpty(phoneStr) or string.len(phoneStr) < 10 then
        return false
    end
    return true
end

-- 自动加上空格
function BuildStr(...)
    local t = {...}
    --这里使用select函数获取变参列表长度
    --#t获取长度可能会由于数组中某个变量是nil而中断
    local len = select('#', ...)
    local s = ''
    for i = 1, len do
        local v = t[i]
        s = s .. ' ' .. tostring(v)
    end
    return s
end

function GetFileNameFromPath(path)
    path = path:replace('\\', '/')
    return path:match("^.+/(.+)$") or ''
end

function Enum(t, start)
    local enStart = start or 1

    local args = t
    local enum = {}
    for i = 1, #args do
        enum[args[i]] = enStart
        enStart = enStart + 1
    end

    return enum
end

-- Array转table
function ArrayToTab(arr)
    local len = arr.Length
    local table = {}
    for i = 1, len do
        table[i] = arr[i - 1]
    end
    return table
end

-- List转table
function ListToTab(list)
    local table = {}
    for k, v in pairs(list) do
        table[k] = v
    end
    return table
end

-- Dictinary转table
function DicToTab(dic)
    local table = {}
    local iter = dic:GetEnumerator()
    while iter:MoveNext() do
        local value = iter.Current.Value
        local key = iter.Current.Key
        table[key] = value
    end
    return table
end

function GetDicInValue(dic, key)
    local iter = dic:GetEnumerator()
    local value = nil
    while iter:MoveNext() do
        local curKey = iter.Current.Key
        -- print("迭代key：" .. tostring(curKey))
        if key == curKey then
            value = iter.Current.Value
            break
        end
    end
    return value
end

function GetInitHelperWithTable(obj, autoDestroy)
    local t = {}
    if autoDestroy == nil then
        autoDestroy = true
    end
    return obj:GetComponent(typeof(LuaInitHelper)):Init(t, autoDestroy)
end

function PrintTable(t, spacestr)
    spacestr = spacestr or ''
    for key, value in pairs(t) do
        print(spacestr .. 'k:' .. tostring(key) .. ' v:' .. tostring(value))
        if type(value) == "table" then
            PrintTable(value, spacestr .. ' ')
        end
    end
end
-- 数值转换为金额格式
function NumberToMoney(n)
    local numInterval = SysDefines.curLanguage == "CN" and 3 or 4
    local lowLimit = SysDefines.curLanguage == "CN" and 999 or 9999
    if n <= lowLimit then
        return tostring(n)
    else
        local numStr = tostring(n)
        local len = string.len(numStr)
        local spiltCount = math.ceil(len / numInterval)
        local spiltTab = {}
        for i = 1, spiltCount do
            if string.len(numStr) >= numInterval then
                local spiltStr = string.sub(numStr, string.len(numStr) - (numInterval - 1), string.len(numStr))
                table.insert(spiltTab, spiltStr)
                numStr = string.sub(numStr, 1, string.len(numStr) - numInterval)
            else
                table.insert(spiltTab, numStr)
            end
        end
        local moneyStr = ''
        for i = 1, #spiltTab do
            if i ~= #spiltTab then
                moneyStr = "," .. spiltTab[i] .. moneyStr
            else
                moneyStr = spiltTab[i] .. moneyStr
            end
        end
        return moneyStr
    end
end

function MoneyToNumber(str)
    local numStr = string.replace(str, ',', '')
    if numStr ~= '' then
        return tonumber(numStr)
    else
        return 0
    end
end

return _ENV
