
local _G = _G
local g_Env = g_Env
local print, tostring, package,SysDefines, typeof, pcall, LogE,string,type,TraceErr,logError =
      print, tostring, package,SysDefines, typeof, pcall, LogE,string,type,TraceErr,logError

local print, tostring, require,pairs, ipairs, getmetatable, assert,coroutine,rawset=
      print, tostring, require,pairs, ipairs, getmetatable, assert,coroutine,rawset

local tinset = table.insert

local json  = require'LuaUtil.dkjson'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local List_Object= CS.System.Collections.Generic.List(CS.System.Object)
local _CS = CS

local helperList = (require'Rebuild.LuaTableLoadConfig').helperList

local UnityEngine = CS.UnityEngine

local yield = coroutine.yield

_ENV = moduledef { seenamespace = CS }
----------------------------
local MemoryStream = System.IO.MemoryStream
local BinaryReader = System.IO.BinaryReader
-- local SeekOrigin = System.IO.SeekOrigin
local File = System.IO.File

local LocalPackageFileName = "config.pkg"
local LocalJsonDirectory = "Table/"
-- local localPackageMd5_
local tableMd5Cache_ = {}



local _loadJsonImpl
local _parsePackageContent
-- local _processGZipDecode


-- local downloadProgress = 0.0

local configFilePath = UnityEngine.Application.persistentDataPath.."/"..LocalPackageFileName

local loadFromBytes

function LoadFromNet(url, md5, callback)
    if (File.Exists(configFilePath))then
        local content = File.ReadAllBytes(configFilePath)
        local localmd5 = UnityHelper.CalMd5(content)
        
        if localmd5==md5 then
            print('md5 相同，不需要下载')
            loadFromBytes(content)
            if callback then callback() end
            return
        end
    end

    CoroutineHelper.StartCoroutine(function ()
        local request = UnityEngine.Networking.UnityWebRequest.Get(url)
        request:SendWebRequest()
        while (not request.isDone) do
            yield()
        end
        if not string.IsNullOrEmpty(request.error) then
            logError('download config error request.isError='..request.error..'\nurl:'..tostring(url))
        else
            local data = request.downloadHandler.data
            loadFromBytes(data)
            if callback then callback() end
            UnityHelper.WriteFileAsync(configFilePath, data)
        end
        
    end)
end

function StartLoadFromNet(url, md5)
    CoroutineHelper.StartCoroutine(function ()
        LoadFromNetAsync(url, md5)
    end)
end

function LoadFromNetAsync(url, md5, req)
    req = req or {}
    if (File.Exists(configFilePath))then
        local readfilereq = UnityHelper.WaitReadFile(configFilePath)
        yield(readfilereq)
        local content = readfilereq.data
        local localmd5 = UnityHelper.CalMd5(content)
        if localmd5==md5 then
            print('md5 相同，不需要下载2')
            loadFromBytes(content,req)
            return
        end
    end


    local request = UnityEngine.Networking.UnityWebRequest.Get(url)
    request:SendWebRequest()
    while (not request.isDone) do
        yield()
    end
    req.progress = 0.1
    if not string.IsNullOrEmpty(request.error) then
        logError('download config error request.isError='..request.error..'\nurl:'..tostring(url))
    else
        local data = request.downloadHandler.data
        loadFromBytes(data, req)
        UnityHelper.WriteFileAsync(configFilePath, data)
    end

end

function loadFromBytes(content, req)
    local vFiles = _parsePackageContent(content)
    g_Env.dicConfig = vFiles
    _loadJsonImpl(vFiles, req)
end



function _loadJsonImpl(vFiles, req, skipstr, notskipstr)

    --local time = _G.os.time()
    local tset = function (t,k,v)
        t[k]=v
    end
    local counter = 0
    local totalcounter = 0
    for _,helperTypeName in pairs(helperList)do
        local tableName = helperTypeName.TableName

        local isNotSkip = true

        if skipstr then
            isNotSkip = not string.Contains(tableName, skipstr)
        elseif notskipstr then
            isNotSkip = string.Contains(tableName, notskipstr)
        end

        if isNotSkip then
            local tn = 'T'..helperTypeName.TableName
            -- print(tn)
            local Type = _CS[tn]
            local fileContent = vFiles[tableName]
            if not(string.IsNullOrEmpty(fileContent))then
                local tmpMd5 = UnityHelper.CalStringMd5(fileContent)
                if not(tmpMd5 == tableMd5Cache_[tableName])then
                    tableMd5Cache_[tableName] = tmpMd5
                    local jsont = json.decode(fileContent)
                    local list = List_Object()
                    for k,jt in pairs(jsont)do
                        local t = Type()
                        for k, v in pairs(jt)do
                            local mt = getmetatable(v)
                            --print(tn,k,getmetatable(v))
                            if mt and mt.__jsontype=="array"then
                                local s = json.encode(v)
                                v=Newtonsoft.Json.Linq.JArray.Parse(s)
                                --print('v=',s)
                            end
                            if k=='Item'then
                                k = 'Item_'
                            end
    
                            local status, err = pcall(tset, t,k,v)
                            if not status then
                                print('------------------',err, tn, k, v)
                            else
                                -- if tn == 'TVIP' then
                                --     print('.....',tn, k, v)
                                --     print('fileContent:'..fileContent)
                                -- end
                            end
                            counter=counter+1
                            totalcounter=totalcounter+1
                            if req and counter>500 then
                                counter = 0
                                 yield()
                                --print(k)
                            end
                        end
    
                        list:Add(t)
                    end
                    helperTypeName.LoadData(list)
                end
            end
        end
        
    end
    print('totalcounter '..totalcounter)
end

function _parsePackageContent(fileContent)
    local vFiles = {}

    local content = UnityHelper.ProcessGZipDecode(fileContent)
    local ms =  MemoryStream(content)
    local br =  BinaryReader(ms)
    --version
    local version = br:ReadByte()
    if (version == 1)then
        while (br.BaseStream.Position < br.BaseStream.Length)do
            local key = UnityHelper.ReadUtf8String(br)
            local val = UnityHelper.ReadUtf8String(br)
            vFiles[key] = val
        end
    end
    return vFiles
end



return _ENV