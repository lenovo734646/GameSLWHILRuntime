
local string, tostring, math, pairs, typeof, type, print, table, tonumber, SysDefines = string, tostring, math, pairs,
typeof, type, print, table, tonumber, CS.SysDefines

local DestroyImmediate = DestroyImmediate
local CS = CS
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

--自动加上空格
function BuildStr(...)
    local t = {...}
    local s = ''
    for i = 1, #t do
        local v = t[i]
        s = s..' '..tostring(v)
    end
    return s
end

function GetFileNameFromPath(path)
	path=path:replace('\\','/')
    return path:match("^.+/(.+)$") or ''
end

function Enum(t, start)
	local enStart = start or 1

	local args = t
	local enum = {}
	for i=1,#args do
		enum[args[i]] = enStart
		enStart = enStart + 1
	end

	return enum
end

-- Array转table
function ArrayToTab(rspArr)
    local arr = rspArr
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


return _ENV