require 'LuaUtil.dumper'


function __TRACKBACK__(errorMsg)
    local track_text = debug.traceback(tostring(errorMsg))
    logError(track_text)
    return false;
end

local function default_ctor(self, ...)
    local obj = {}
    setmetatable(obj, self)
    if obj.__init then
        obj:__init(...)
    end
    return obj
end

function class(super, cls)
    if not cls then
        cls = {}
    end
    local mt = {}
    if super then
        setmetatable(mt, super)
        cls.super = super
    end
    mt.__index = mt
    mt.__call = function(self, ...)
        if self.New then
            return self:New(...)
        else
            return default_ctor(self, ...)
        end
    end
    setmetatable(cls, mt)
    cls.__index = cls
    return cls
end

-- import function
function import(moduleName, currentModuleName)
    local currentModuleNameParts
    local moduleFullName = moduleName
    local offset = 1

    while true do
        if string.byte(moduleName, offset) ~= 46 then -- .
            moduleFullName = string.sub(moduleName, offset)
            if currentModuleNameParts and #currentModuleNameParts > 0 then
                moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
            end
            break
        end
        offset = offset + 1

        if not currentModuleNameParts then
            if not currentModuleName then
                local n, v = debug.getlocal(3, 1)
                currentModuleName = v
            end

            currentModuleNameParts = string.split(currentModuleName, ".")
        end
        table.remove(currentModuleNameParts, #currentModuleNameParts)
    end

    return require(moduleFullName)
end

functional = {}

function functional.bind(func, count, ...)
    local args_origin = {...}
    return function(...)
        local args = {...}
        local num = table.maxn(args)
        for i = num, 1, -1 do
            args[i + count] = args[i]
        end
        for i = 1, count do
            args[i] = args_origin[i]
        end
        return func(table.unpack(args))
    end
end

function functional.bindself(self, fname)
    return functional.bind1(self[fname], self)
end

function functional.bind1(func, obj1)
    return function(...)
        return func(obj1, ...)
    end
end

function functional.bind2(func, obj1, obj2)
    return function(...)
        return func(obj1, obj2, ...)
    end
end

function table.print(t)
    local str = "["
    for k, v in pairs(t) do
        str = str .. tostring(k) .. ":" .. tostring(v) .. ","
    end
    str = str .. "]"
    return str
end

function table.maxn(tbl)
    local max = nil
    local count = 0
    for k, v in pairs(tbl) do
        if type(k) == "number" then
            if max then
                if k >= 0 and k > max then
                    max = k
                end
            else
                if k >= 0 then
                    max = k
                end
            end
        end
        count = count + 1
    end
    if count == 0 then
        max = 0
    end
    return max
end

function table.contains(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            if not removeall then
                break
            end
            c = c + 1
            i = i - 1
            max = max - 1
        end
        i = i + 1
    end
    return c
end

function table.intersect(tblA, tblB)
    local tblT = {}
    for k, v in ipairs(tblA) do
        if table.contains(tblB, v) then
            table.insert(tblT, v)
        end
    end
    return tblT
end

function table.findBy(tbl, func)
    local ret
    for k, v in ipairs(tbl) do
        if func(v) then
            ret = v
        end
    end
    return ret
end

function table.findArray(tbl, func)
    local tblR = {}
    for k, v in pairs(tbl) do
        if func(v) then
            table.insert(tblR, v)
        end
    end
    return tblR
end

function table.findKey(tbl,func)
    local key = 0
    for k, v in pairs(tbl) do
        if func(v) then
            key = k
            break
        end
    end
    return key
end

function table.findMap(tbl, func)
    local tblR = {}
    for k, v in ipairs(tbl) do
        if func(v) then
            tblR[k] = v
        end
    end
    return tblR
end

function table.count(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count=count+1
    end
    return count
end

function table.keys(tbl)
    local keys = {}
    for k, v in pairs(tbl) do
        -- log("table.keys:"..k)
        table.insert(keys, k)
    end
    return keys
end

function table.values(tbl)
    local values = {}
    for k, v in pairs(tbl) do
        if v ~= nil then
            table.insert(values, v)
        end
    end
    return values
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if delimiter == '' then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

string.Split = string.split

function string.IsNullOrEmpty(str)
    return not str or str == ""
end

function string.indexof(str, searchStr)
    local startIndex = string.find(str, searchStr, 1, true)
    return startIndex
end

function string.Contains(str, searchStr)
    return string.find(str, searchStr, 1, true) ~= nil
end

function string.lastindexof(str, searchStr)
    local lastindex = nil
    local p = string.find(str, searchStr, 1, true)
    lastindex = p
    while p do
        p = string.find(str, searchStr, p + 1, true)
        if p then
            lastindex = p
        end
    end
    return lastindex
end

-- 以tab格式赶回
function THelperTab(THelper)
    local id = 1
    local tab = {}
    local count = THelper.DataMap.Count
    while (id < count or id == count) do
        local v = THelper.GetRow(id)
        if v == nil then
            break
        end
        tab[id] = v
        id = id + 1
    end
    return tab
end

-- 返回发现的第一个对象
function THelperWhere(THelper, wherefunc)
    local id = 1
    while true do
        local v = THelper.GetRow(id)
        if v == nil then
            break
        end
        if wherefunc(v) then
            return v
        end
        id = id + 1
    end
end
-- 返回发现的所有对象
function THelperWhereReturnTab(THelper, wherefunc)
    local i = 1
    local tabIndex = 1
    local tab = {}
    local count = THelper.DataMap.Count
    while (i < count or i == count) do
        local v = THelper.GetRow(i)
        if v == nil then
            break
        end
        if wherefunc(v) then
            tab[tabIndex] = v
            tabIndex = tabIndex + 1
        end
        i = i + 1
    end
    return tab
end

function ReloadModule(name)
    local status, err = xpcall(function()
        package.loaded[name] = nil
        require(name)
        print('reloadmodule ' .. name)
    end, debug.traceback)
    if status then
        return err
    else
        logError(err)
    end
end

function UnLoadModule(name)
    package.loaded[name] = nil
    print('UnLoadModule ' .. name)
end

local sfind = string.find
local ssub = string.sub
local tinsert = table.insert
string.replace = function(s, pattern, repl)
    local i, j = sfind(s, pattern, 1, true)
    if i and j then
        local ret = {}
        local start = 1
        while i and j do
            tinsert(ret, ssub(s, start, i - 1))
            tinsert(ret, repl)
            start = j + 1
            i, j = sfind(s, pattern, start, true)
        end
        tinsert(ret, ssub(s, start))
        return table.concat(ret)
    end
    return s
end

string.Find = function(s, pattern)
    return sfind(s, pattern, 1, true)
end

function PrintTable(str)
    print(DataDumper(str))
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function Dump(value, desciption, nesting)
    if type(nesting) ~= "number" then
        nesting = 3
    end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result + 1] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent .. "    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then
                        keylen = vkl
                    end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end

function math.newrandomseed()
    local ok, socket = pcall(function()
        return require("socket")
    end)

    if ok then
        math.randomseed(socket.gettime() * 1000)
    else
        math.randomseed(os.time())
    end
    math.random()
    math.random()
    math.random()
    math.random()
end

function math.round(value)
    value = checknumber(value)
    return math.floor(value + 0.5)
end

local pi_div_180 = math.pi / 180
function math.angle2radian(angle)
    return angle * pi_div_180
end

local pi_mul_180 = math.pi * 180
function math.radian2angle(radian)
    return radian / pi_mul_180
end

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then
            return i
        end
    end
    return false
end

function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then
            return k
        end
    end
    return nil
end

function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then
                break
            end
        end
        i = i + 1
    end
    return c
end

function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

function table.walk(t, fn)
    for k, v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then
            t[k] = nil
        end
    end
end

function table.unique(t, bArray)
    local check = {}
    local n = {}
    local idx = 1
    for k, v in pairs(t) do
        if not check[v] then
            if bArray then
                n[idx] = v
                idx = idx + 1
            else
                n[k] = v
            end
            check[v] = true
        end
    end
    return n
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end

function string.restorehtmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)
    return input
end

function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.ucfirst(input)
    return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
    return "%" .. string.format("%02X", string.byte(char))
end
function string.urlencode(input)
    -- convert line endings
    input = string.gsub(tostring(input), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
    -- convert spaces to "+" symbols
    return string.gsub(input, " ", "+")
end

function string.urldecode(input)
    input = string.gsub(input, "+", " ")
    input = string.gsub(input, "%%(%x%x)", function(h)
        return string.char(checknumber(h, 16))
    end)
    input = string.gsub(input, "\r\n", "\n")
    return input
end

function string.utf8len(input)
    local len = string.len(input)
    local left = len
    local cnt = 0
    local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(input, -left)
        local i = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end


string.ToLower = string.lower


math.floor2 = function (value)
    value = value*100
    value = math.floor(value)
    return value / 100
end

