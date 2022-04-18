-- 全局函数采用GF前缀管理
if not GF then
    print("初始化GF全局函数")
    GF = {}

    local meta_GF = {}
    local meta_table = {}
    local meta_string = {}
    local meta_functional = {}
    local meta_math = {}
    local meta_io = {}

    -- Debug.Log
    meta_GF.log = GS.UnityEngine.Debug.Log
    meta_GF.logWarning = GS.UnityEngine.Debug.LogWarning
    meta_GF.logError = GS.UnityEngine.Debug.LogError

    function __TRACKBACK__(errorMsg)
        local track_text = debug.traceback(tostring(errorMsg))
        meta_GF.logError(track_text)
        return false;
    end

    --import function
    -- function import(moduleName, currentModuleName)
    --     local currentModuleNameParts
    --     local moduleFullName = moduleName
    --     local offset = 1
        
    --     while true do
    --         if string.byte(moduleName, offset) ~= 46 then -- .
    --             moduleFullName = string.sub(moduleName, offset)
    --             if currentModuleNameParts and #currentModuleNameParts > 0 then
    --                 moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
    --             end
    --             break
    --         end
    --         offset = offset + 1
            
    --         if not currentModuleNameParts then
    --             if not currentModuleName then
    --                 local n, v = debug.getlocal(3, 1)
    --                 currentModuleName = v
    --             end
                
    --             currentModuleNameParts = string.split(currentModuleName, ".")
    --         end
    --         table.remove(currentModuleNameParts, #currentModuleNameParts)
    --     end
        
    --     return require(moduleFullName)
    -- end

    -- 将表src拷贝到dest
    meta_table.copy = function(src, dest)
        for k, v in pairs(src) do
            if type(v) == "table" then
                dest[k] = {}
                meta_table.copy(v, dest[k])
            else
                dest[k] = v
            end
        end
    end

    -- 获取打印table字符串
    meta_table.Log = function(t, isprint)
        local strn = ""
        if isprint then
            strn = "\n"
        end
        local str = "{" .. strn
        for k, v in pairs(t) do
            if type(v) == 'table' then
                str = str .. tostring(k) .. ":"
                str = str .. meta_table.Log(v, isprint)
            else
                str = str .. tostring(k) .. ":" .. tostring(v) .. "," .. strn
            end
        end
        str = str .. "}" .. strn
        return str
    end

    -- 打印table
    meta_table.printtable = function(t)
        Log(meta_table.Log(t, true))
    end

    -- 获取table最大的key
    meta_table.maxn = function(tbl)
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

    -- 判断table是否存在value，并返回对应key
    meta_table.contains = function(tbl, value)
        for k, v in pairs(tbl) do
            if v == value then
                return k
            end
        end
    end

    --  通过key获取到table中的元素
    meta_table.trygetvalue = function(tbl, key)
        local value = nil
        for k, v in pairs(tbl) do
            if k == key then
                value = v
                return value
            end
        end
        return nil
    end

    -- 删除table中value，并返回删除的数量
    meta_table.removebyvalue = function(array, value, removeall)
        local c, i, max = 0, 1, #array
        while i <= max do
            if array[i] == value then
                table.remove(array, i)
                if not removeall then
                    return c+1
                end
                c = c + 1
                i = i - 1
                max = max - 1
            end
            i = i + 1
        end
        return c
    end

    -- 删除func(value)为true的值，并返回删除的数量
    meta_table.removebyfunc = function(array, func, removeall)
        local c, i, max = 0, 1, #array
        while i <= max do
            if func(array[i]) then
                table.remove(array, i)
                if not removeall then
                    return c + 1
                end
                c = c + 1
                i = i - 1
                max = max - 1
            end
            i = i + 1
        end
        return c
    end

    -- 交集
    meta_table.intersect = function(tblA, tblB)
        local tblT = {}
        for k, v in ipairs(tblA) do
            if meta_table.contains(tblB, v) then
                table.insert(tblT, v)
            end
        end
        return tblT
    end

    -- 差集 tblA对tblB取差集
    meta_table.except = function(tblA, tblB)
        local tblT = {}
        meta_table.copy(tblA, tblT)
        for k, v in pairs(tblA) do
            if meta_table.contains(tblB, v) then
                table.remove(tblT, meta_table.findKey(tblT, function(a)
                    return v == a
                end))
            end
        end
        return tblT
    end

    -- 返回func(value)为true的value
    meta_table.FindBy = function(tbl, func)
        for _, v in pairs(tbl) do
            if func(v) then
                return v
            end
        end
    end

    -- 返回func(value,key)为true的value,key
    meta_table.Find = function(tbl, func)
        for k, v in pairs(tbl) do
            if func(v, k) then
                return v, k
            end
        end
    end

    -- 返回func(value)为true的value的array
    meta_table.findArray = function(tbl, func)
        local tblR = {}
        for k, v in pairs(tbl) do
            if func(v) then
                table.insert(tblR, v)
            end
        end
        return tblR
    end

    -- 返回func(value)为true的key
    meta_table.findKey = function(tbl, func)
        local key = nil
        for k, v in pairs(tbl) do
            if func(v) then
                key = k
                break
            end
        end
        return key
    end

    -- 返回func(key,value)为true的key,value
    meta_table.findKV = function(tbl, func)
        for k, v in pairs(tbl) do
            if func(k, v) then
                return k, v
            end
        end
    end

    -- 返回func(value)为true的key,value的array
    meta_table.findMap = function(tbl, func)
        local tblR = {}
        for k, v in ipairs(tbl) do
            if func(v) then
                tblR[k] = v
            end
        end
        return tblR
    end

    -- 统计table中的key，不在表withoutKeysList存在的数量
    meta_table.countWithoutKeys = function(tbl, withoutKeysList)
        local count = 0
        local withoutKeysCache = {}
        for _, value in ipairs(withoutKeysList) do
            withoutKeysCache[value] = true
        end
        for k, _ in pairs(tbl) do
            if not withoutKeysCache[k] then
                count = count + 1
            end
        end
        return count
    end

    -- 倒序table的value
    meta_table.reverse = function(tbl)
        local tmp = {}
        meta_table.copy(tbl, tmp)
        for k, v in ipairs(tbl) do
            tbl[k] = tmp[#tmp + 1 - k]
        end
        return tbl
    end

    -- table执行func(value)函数
    meta_table.foreach = function(tbl, func)
        for k, v in pairs(tbl) do
            func(v)
        end
    end

    -- 单独取出table中所有元素中的某个字段
    meta_table.select = function(tbl, selector)
        local tmp = {}
        for k, v in pairs(tbl) do
            if selector(v) ~= nil then
                table.insert(tmp, selector(v))
            end
        end
        return tmp
    end

    -- 返回table的数量
    meta_table.nums = function(t)
        local count = 0
        for k, v in pairs(t) do
            count = count + 1
        end
        return count
    end

    -- 获取table的key的array
    meta_table.keys = function(hashtable)
        local keys = {}
        for k, v in pairs(hashtable) do
            keys[#keys + 1] = k
        end
        return keys
    end

    -- 获取table的value的array
    meta_table.values = function(hashtable)
        local values = {}
        for k, v in pairs(hashtable) do
            values[#values + 1] = v
        end
        return values
    end

    meta_table.merge = function(dest, ...)
        local params = {...}
        local startIndex = #dest
        for i = 1, #params do
            local param = params[i]
            for j = 1, #param do
                dest[startIndex + j] = param[j]
            end
            startIndex = startIndex + #param
        end
    end

    -- meta_table.insertto = function(dest, src, begin)
    --     begin = checkint(begin)
    --     if begin <= 0 then
    --         begin = #dest + 1
    --     end

    --     local len = #src
    --     for i = 0, len - 1 do
    --         dest[i + begin] = src[i + 1]
    --     end
    -- end

    meta_table.indexof = function(array, value, begin)
        for i = begin or 1, #array do
            if array[i] == value then
                return i
            end
        end
        return false
    end

    meta_table.keyof = function(hashtable, value)
        for k, v in pairs(hashtable) do
            if v == value then
                return k
            end
        end
        return nil
    end

    meta_table.map = function(t, fn)
        for k, v in pairs(t) do
            t[k] = fn(v, k)
        end
    end

    meta_table.walk = function(t, fn)
        for k, v in pairs(t) do
            fn(v, k)
        end
    end

    meta_table.filter = function(t, fn)
        for k, v in pairs(t) do
            if not fn(v, k) then
                t[k] = nil
            end
        end
    end

    -- 过滤表中重复数据
    meta_table.unique = function(t, bArray)
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

    meta_string.split = function(input, delimiter)
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

    meta_string.IsNullOrEmpty = function(str)
        return not str or str == ""
    end

    meta_string.indexof = function(str, searchStr)
        local startIndex = string.find(str, searchStr, 1, true)
        return startIndex
    end

    -- 判断字符串是否包含子串
    meta_string.Contains = function(str, searchStr)
        return string.find(str, searchStr, 1, true) ~= nil
    end

    meta_string.lastindexof = function(str, searchStr)
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

    -- 以某个字符串开始
    meta_string.startswith = function(target_string, start_pattern, plain)
        plain = plain or true
        local find_pos_begin, find_pos_end = string.find(target_string, start_pattern, 1, plain)
        return find_pos_begin == 1
    end

    -- 以某个字符串结尾
    meta_string.endswith = function(target_string, start_pattern, plain)
        plain = plain or true
        local find_pos_begin, find_pos_end = string.find(target_string, start_pattern, -#start_pattern, plain)
        return find_pos_end == #target_string
    end

    meta_string.replace = function(s, pattern, repl)
        local i, j = string.find(s, pattern, 1, true)
        if i and j then
            local ret = {}
            local start = 1
            while i and j do
                table.insert(ret, string.sub(s, start, i - 1))
                table.insert(ret, repl)
                start = j + 1
                i, j = string.find(s, pattern, start, true)
            end
            table.insert(ret, string.sub(s, start))
            return table.concat(ret)
        end
        return s
    end

    meta_string.Find = function(s, pattern)
        return string.find(s, pattern, 1, true)
    end

    meta_string._htmlspecialchars_set = {}
    meta_string._htmlspecialchars_set["&"] = "&amp;"
    meta_string._htmlspecialchars_set["\""] = "&quot;"
    meta_string._htmlspecialchars_set["'"] = "&#039;"
    meta_string._htmlspecialchars_set["<"] = "&lt;"
    meta_string._htmlspecialchars_set[">"] = "&gt;"

    meta_string.htmlspecialchars = function(input)
        for k, v in pairs(meta_string._htmlspecialchars_set) do
            input = string.gsub(input, k, v)
        end
        return input
    end

    meta_string.restorehtmlspecialchars = function(input)
        for k, v in pairs(meta_string._htmlspecialchars_set) do
            input = string.gsub(input, v, k)
        end
        return input
    end

    meta_string.nl2br = function(input)
        return string.gsub(input, "\n", "<br />")
    end

    meta_string.text2html = function(input)
        input = string.gsub(input, "\t", "    ")
        input = meta_string.htmlspecialchars(input)
        input = string.gsub(input, " ", "&nbsp;")
        input = meta_string.nl2br(input)
        return input
    end

    meta_string.ltrim = function(input)
        return string.gsub(input, "^[ \t\n\r]+", "")
    end

    meta_string.rtrim = function(input)
        return string.gsub(input, "[ \t\n\r]+$", "")
    end

    meta_string.trim = function(input)
        input = string.gsub(input, "^[ \t\n\r]+", "")
        return string.gsub(input, "[ \t\n\r]+$", "")
    end

    meta_string.ucfirst = function(input)
        return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
    end

    local function urlencodechar(char)
        return "%" .. string.format("%02X", string.byte(char))
    end
    meta_string.urlencode = function(input)
        -- convert line endings
        input = string.gsub(tostring(input), "\n", "\r\n")
        -- escape all characters but alphanumeric, '.' and '-'
        input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
        -- convert spaces to "+" symbols
        return string.gsub(input, " ", "+")
    end

    -- meta_string.urldecode = function(input)
    --     input = string.gsub(input, "+", " ")
    --     input = string.gsub(input, "%%(%x%x)", function(h)
    --         return string.char(checknumber(h, 16))
    --     end)
    --     input = string.gsub(input, "\r\n", "\n")
    --     return input
    -- end

    meta_string.utf8len = function(input)
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

    -- meta_string.formatnumberthousands = function(num)
    --     local formatted = tostring(checknumber(num))
    --     local k
    --     while true do
    --         formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    --         if k == 0 then
    --             break
    --         end
    --     end
    --     return formatted
    -- end

    -- 类似C#的格式化，但是下标从1开始
    meta_string.Format2 = function(fmt, ...)
        assert(fmt ~= nil, "Format error:Invalid Format String")
        local parms = {...}
        local function search(k)
            k = tonumber(k)
            return tostring(parms[k])
        end
        return (string.gsub(fmt, "{(%d)}", search))
    end

    meta_string.SubUTF8String = function(s, n)
        local dropping = string.byte(s, n + 1)
        if not dropping then
            return s
        end
        if dropping >= 128 and dropping < 192 then
            return meta_string.SubUTF8String(s, n - 1)
        end
        return string.sub(s, 1, n)
    end

    meta_string.Clamp = function(str, len)
        if #str > len then
            str = meta_string.SubUTF8String(str, len)
            return str .. '...'
        end
        return str
    end

    meta_string.FormatDate = function(month,day,year)
        year = year or 2019
        if GS.SysDefines.curLanguage=='CN' then
            os.setlocale("chs")
            return os.date("%Y年%m月%d日",os.time{year=year,month=month,day=day})
        else
            os.setlocale("eng")
            return os.date("%b/%d/%Y",os.time{year=year,month=month,day=day})
        end    
    end

    meta_math.newrandomseed = function()
        local ok, socket = pcall(function()
            return require("socket")
        end)

        if ok then
            math.randomseed(socket.gettime() * 1000)
        else
            math.randomseed(os.time())
        end
        local random1 = math.random()
        random1 = math.random()
        random1 = math.random()
        random1 = math.random()
    end

    meta_math.round = function(value)
        return math.floor(value + 0.5)
    end

    local pi_div_180 = math.pi / 180
    meta_math.angle2radian = function(angle)
        return angle * pi_div_180
    end

    local pi_mul_180 = math.pi * 180
    meta_math.radian2angle = function(radian)
        return radian / pi_mul_180
    end

    meta_math.floor2 = function(value)
        value = value * 100
        value = math.floor(value)
        return value / 100
    end

    meta_io.exists = function(path)
        local file = io.open(path, "r")
        if file then
            io.close(file)
            return true
        end
        return false
    end

    meta_io.readfile = function(path)
        local file = io.open(path, "r")
        if file then
            local content = file:read("*a")
            io.close(file)
            return content
        end
        return nil
    end

    meta_io.writefile = function(path, content, mode)
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

    meta_io.pathinfo = function(path)
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

    meta_io.filesize = function(path)
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

    meta_functional.bind = function(func, count, ...)
        local args_origin = {...}
        return function(...)
            local args = {...}
            local num = meta_table.maxn(args)
            for i = num, 1, -1 do
                args[i + count] = args[i]
            end
            for i = 1, count do
                args[i] = args_origin[i]
            end
            return func(table.unpack(args))
        end
    end

    -- 绑定自身的函数并将自身传参
    meta_functional.bindself = function(self, fname)
        return meta_functional.bind1(self[fname], self)
    end

    -- 绑定函数和一个参数
    meta_functional.bind1 = function(func, obj1)
        return function(...)
            return func(obj1, ...)
        end
    end

    -- 绑定函数和两个参数
    meta_functional.bind2 = function(func, obj1, obj2)
        return function(...)
            return func(obj1, obj2, ...)
        end
    end

    -- 重新导入模块
    meta_GF.ReloadModule = function (name)
        local status, err = xpcall(function()
            package.loaded[name] = nil
            require(name)
            Log('reloadmodule ' .. name)
        end, debug.traceback)
        if status then
            return err
        else
            LogE(err)
        end
    end

    -- 卸载模块
    meta_GF.UnLoadModule = function(name)
        package.loaded[name] = nil
        Log('UnLoadModule ' .. name)
    end

    meta_GF.PrintDataDumper = function(t)
        Log(DataDumper(t))
    end

    local function dump_value_(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    meta_GF.Dump = function(value, desciption, nesting)
        if type(nesting) ~= "number" then
            nesting = 3
        end

        local lookupTable = {}
        local result = {}

        local traceback = meta_string.split(debug.traceback("", 2), "\n")
        Log("dump from: " .. meta_string.trim(traceback[3]))

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
            Log(line)
        end
    end

    local function _callp(func, params1, len1, params2, len2)
        local ap = {}
        for i=1,len1 do
            ap[i] = params1[i]
        end
        for i=1,len2 do
            ap[len1 + i] = params2[i]
        end
        return func((table.unpack)(ap, 1, len1 + len2))
    end
    
    meta_GF.Handler = function(callback, ...)
        local params1 = {...}
        local len1 = select("#", ...)
        return function(...)
            local len2 = select("#", ...)
            return _callp(callback, params1, len1, {...}, len2)
        end
    end
    
    
    meta_GF.RandomInt = function(min,max)
        return GS.UnityHelper.RandomInt(min,max+1)
    end
    
    meta_GF.WaitForSeconds = function(time)
        return coroutine.yield(GS.UnityEngine.WaitForSeconds(time))
    end
    
    meta_GF.SafeDestroy = function(unityObj,isImmediate)
        if GS.UnityHelper.IsUnityObjectValid(unityObj) then
            if isImmediate then
                GS.DestroyImmediate(unityObj)
            else
                GS.Destroy(unityObj)
            end
        end
    end

    -- ==================设置GF表为只读表==================
    local setonlyreadtable = function(tab, metatab)
        setmetatable(tab, {
            __index = function(t, k)
                return metatab[k]
            end,
            __newindex = function(t, k, v)
                LogE('table GF is only read', k)
            end
        })
    end

    local t_table = {}
    local t_string = {}
    local t_functional = {}
    local t_math = {}
    local t_io = {}

    setonlyreadtable(t_table, meta_table)
    setonlyreadtable(t_string, meta_string)
    setonlyreadtable(t_functional, meta_functional)
    setonlyreadtable(t_math, meta_math)
    setonlyreadtable(t_io, meta_io)

    meta_GF.table = t_table
    meta_GF.string = t_string
    meta_GF.functional = t_functional
    meta_GF.math = t_math
    meta_GF.io = t_io

    setonlyreadtable(GF, meta_GF)

end
