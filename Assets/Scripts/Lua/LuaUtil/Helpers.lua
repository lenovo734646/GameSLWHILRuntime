local string, tostring, math, pairs, typeof, type, print, table, tonumber, SysDefines = string, tostring, math, pairs,
    typeof, type, print, table, tonumber, SysDefines
local LuaInitHelper = CS.LuaInitHelper
-- local EventSystems = CS.UnityEngine.EventSystems
-- local PointerEventData = EventSystems.PointerEventData
-- local EventSystem = EventSystems.EventSystem
-- local Input = CS.UnityEngine.Input
-- local Vector2 = CS.UnityEngine.Vector2
-- local UnityHelper = CS.UnityHelper
-- local List_RaycastResult = CS.System.Collections.Generic.List(EventSystems.RaycastResult)


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
-- -- 获取当前鼠标停留的GameObject 层级为由下到上
-- function GetMouseOverGameObjects(graphicRaycaster)
--     local pointerEventData = PointerEventData(EventSystem.current)
--     local v3 = Input.mousePosition
--     pointerEventData.position = Vector2(v3.x, v3.y)

--     local results = List_RaycastResult()
--     graphicRaycaster:Raycast(pointerEventData, results)
--     print("results = ", results, results.Count)
--     return results -- 这里类型是 c# List
-- end
-- -- 判断鼠标是否停留在target上
-- function IsMouseCorveredTarget(target, graphicRaycaster)
--     print("graphicRaycaster = ", graphicRaycaster)
--     local objs = GetMouseOverGameObjects(graphicRaycaster)
--     if objs == nil or objs.Count <= 0 then
--         return false
--     end
--     for key, value in pairs(objs) do
--         print("对比:", target.name, value.gameObject.name)
--         if value.gameObject == target then
--             return true
--         end
--     end
--     return false
-- end

-- 下载
local UnityWebRequest = CS.UnityEngine.Networking.UnityWebRequest
function WebRequestGet(url, timeout)
    local request = UnityWebRequest.Get(url)
    --request.certificateHandler = CS.CertHandler()
    if timeout then
        request.timeout = timeout
    end
    return request
end
-- 上传
function WebRequestPut(url, data, timeout)
    local request = UnityWebRequest.Put(url, data)
    --request.certificateHandler = CS.CertHandler()
    if timeout then
        request.timeout = timeout
    end
    return request
end



return _ENV
