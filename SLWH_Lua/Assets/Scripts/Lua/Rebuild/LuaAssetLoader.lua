local _G = _G
local g_Env,class = g_Env,class
local print, tostring, log, type, debug, pairs,string, assert =
      print, tostring, log, type, debug, pairs,string, assert

local logError = logError
local logWarning = logWarning
-- local AssetBundle = UnityEngine.AssetBundle
local yield = coroutine.yield
local SceneManager = SceneManager
-- local Resources = UnityEngine.Resources
local BundleInfo = CS.ForReBuild.BundleInfo
local WaitLoadFromFile = BundleInfo.WaitLoadFromFile
local GetFileNameFromPath = require'LuaUtil.Helpers'.GetFileNameFromPath
-- local CoroutineHelper, cs_coroutine_runner = require 'LuaUtil.CoroutineHelper'
local Config = require'Rebuild.Config'
local Directory = CS.System.IO.Directory
require'LuaUtil.Functions'

_ENV = moduledef { seenamespace = CS }
-----------------------------------------

local function LogE(str)
    logError('[LuaAssetLoader]'..str..'\n'..debug.traceback())
end

local function LogW(str)
    logWarning('[LuaAssetLoader]'..str..'\n'..debug.traceback())
end

local function Log(str)
    log('[LuaAssetLoader]'..str..'\n'..debug.traceback())
end

local Class = class()

function Create(basepath, isLoadFromEditor)
    assert(type(isLoadFromEditor) ~= "string")
    if isLoadFromEditor==nil then
        isLoadFromEditor = Config:IsLoadFromEditor()
    end
    local bundlePathHelper = BundlePathHelper(basepath)
    if not isLoadFromEditor then
        if bundlePathHelper.Loadfailed then
            LogW(bundlePathHelper.LoadfailedReson)
            return nil
        end
    end
    return Class(basepath,bundlePathHelper,isLoadFromEditor)
end

function Class:__init(basepath,bundlePathHelper,isLoadFromEditor)
    self.isLoadFromEditor = isLoadFromEditor
    self.name = GetFileNameFromPath(basepath)
    -- self.sceneCache = {}
    self.bundleCache = {}--引用资源以防止被GC
    self.basepath = basepath
    print('basepath ----------',basepath)
    
    self.bundlePathHelper = bundlePathHelper
end

function Class:LoadBundleAndCache(realpath)
    assert(not UnityHelper.IsDir(realpath),realpath)
    local abinfo = self.bundleCache[realpath]
    abinfo = abinfo or BundleInfo.LoadFromFile(realpath)
    assert(abinfo, realpath)
    self.bundleCache[realpath] = abinfo
    return abinfo
end

function Class:LoadAssetBundleByPath(path,notCache,isRawPath)
    local realpath = self.bundlePathHelper:GetBundleRealPath(path,isRawPath)
    if string.IsNullOrEmpty(realpath) then
        LogE('can not find '..path)
        return
    end
    if notCache then
        assert(not UnityHelper.IsDir(realpath),realpath)
        local abinfo = BundleInfo.LoadFromFile(realpath,isRawPath)
        assert(abinfo, realpath)
        self.bundleCache[realpath] = abinfo
        return abinfo
    end
    return self:LoadBundleAndCache(realpath)
end

function Class:Load(path,type,notCache)
    
    local isRawPath = path:Contains('Assets/')
    if self.isLoadFromEditor then
        Log('Load from editor'..path)
        local r
        if type then
            r = ResHelper.Load(path, type, isRawPath)
        else
            r = ResHelper.Load(path, isRawPath)
        end
        if r then
            return r
        else
            LogE('can not load from editor '..path..'\nbasePath='..self.basepath)
        end
        return
    end
    Log('Load '..path)

    local bundle = self:LoadAssetBundleByPath(path,notCache,isRawPath)
    if path:Contains('.unity') then
        return
    end

    if bundle then
        local r
        if type then
            r = bundle:LoadAsset(path, type, isRawPath)
        else
            r = bundle:LoadAsset(path, isRawPath)
        end

        if r then
            return r
        else
            LogE('can not load res '..path..'\nbasePath='..self.basepath)
        end
    end
end

-- 载入所有
function Class:LoadAll(path, type, notCache)
    local isRawPath = path:Contains('Assets/')
    if self.isLoadFromEditor then
        Log('Load from editor'..path)
        local r
        if type then
            r = ResHelper.LoadAll(path, type, isRawPath)
        else
            r = ResHelper.LoadAll(path, isRawPath)
        end
        if r then
            return r
        else
            LogE('can not load from editor '..path..'\nbasePath='..self.basepath)
        end
        return
    end
    Log('LoadAll '..path)

    local bundle = self:LoadAssetBundleByPath(path,notCache,isRawPath)
    if path:Contains('.unity') then
        return
    end

    if bundle then
        local r
        if type then
            r = bundle:LoadAssetWithSubAssets(path, isRawPath)
        else
            r = bundle:LoadAssetWithSubAssets(path, isRawPath)
        end

        if r then
            return r
        else
            LogE('can not load res '..path..'\nbasePath='..self.basepath)
        end
    end
end

local function doDone(req, assert)
    req.isDone = true
    req.progress = 1
    req.assert = assert
    if req.onComplete then
        req.onComplete(assert)
    end
    return assert
end


function Class:LoadAsync(path, infoOut, notCache)
    local isRawPath = path:Contains('Assets/')
    infoOut = infoOut or {}
    infoOut.progress = 0
    if self.isLoadFromEditor then
        return doDone(infoOut, ResHelper.Load(path,isRawPath))
    end
    local bundlePathHelper = self.bundlePathHelper
    if infoOut.withDependencies then
        local realpath = bundlePathHelper:GetBundleRealPath(path,isRawPath)
        local strs = bundlePathHelper:GetAllDependencies(realpath)
        if strs then
            local len = strs.Length-1
            for i=0,len do
                local s = strs[i]
                self:LoadBundleAsync(s, notCache)
            end
        end
    end
    local bundlename = bundlePathHelper:GetAssetBundleNameByPath(path, isRawPath)
    assert(bundlename, path)
    local assetBundle,realpath = self:LoadBundleAsync(bundlename, notCache)
    assert(assetBundle, realpath)
    if path:Contains('.unity') then
        return
    end
    local reqab = assetBundle:LoadAssetAsync(path)
    while not reqab.isDone do
        yield()
        infoOut.progress = reqab.progress
    end
    assert(reqab.asset, path)
    return doDone(infoOut, reqab.asset)
end

function Class:LoadBundle(bundlename)
    assert(bundlename)
    if  self.isLoadFromEditor then
        return
    end
    local bundlePathHelper = self.bundlePathHelper
    local realpath = bundlePathHelper:GetRealPathByName(bundlename)
    if string.IsNullOrEmpty(realpath) then
        LogE('can not find '..bundlename)
        return
    end
    return self:LoadBundleAndCache(realpath)
end

function Class:LoadBundleAsync(bundlename, notCache)
    assert(bundlename)
    if  self.isLoadFromEditor then
        yield()
        return
    end
    local bundlePathHelper = self.bundlePathHelper
    local realpath = bundlePathHelper:GetRealPathByName(bundlename)
    Log('LoadBundleAsync bundlename:'..bundlename..' realpath:'..realpath)
    if string.IsNullOrEmpty(realpath) then
        LogE('can not find '..bundlename)
        return
    end
    local abinfo
    if not notCache then
        abinfo = self.bundleCache[realpath]
    end
    if not abinfo then
        local req = WaitLoadFromFile(realpath)
        yield(req)
        abinfo = req.bundleInfo
        assert(abinfo, realpath)
        self.bundleCache[realpath] = abinfo
    end
    return abinfo,realpath
end

function Class:LoadBundleAllAsync(bundlename)
    local abinfo = self:LoadBundleAsync(bundlename)
    if not abinfo then
        return
    end

    local allnames = abinfo:GetAllAssetNames()
    local len = allnames.Length-1
    for i = 0, len do
        local name = allnames[i]
        local req = abinfo:LoadAssetAsync(name)
        yield(req)
    end
    return abinfo
end





function Class:LoadScene(name)
    if self.isLoadFromEditor then
        SceneManager.LoadScene(name)
        return
    end
    local path = [[Assets/Scenes/]]..name..'.unity'
    self:Load(path)
    return SceneManager.LoadScene(name)
end

function Class:LoadSceneAsync(name,infoOut)
    if not self.isLoadFromEditor then
        local path = [[Assets/Scenes/]]..name..'.unity'
        self:LoadAsync(path)
    end
    local req = SceneManager.LoadSceneAsync(name)
    if infoOut then
        infoOut.progress = 0
        while not req.isDone do
            if infoOut.UpdateInfo then
                infoOut:UpdateInfo(req.progress)
            else
                infoOut.progress = req.progress
            end
        end
        infoOut.progress = 1
    else
        yield(req)
    end
    
    -- self.sceneCache[name] = true
end

function Class:LoadSoundsPackageAsync(path)
    local prefab = self:LoadAsync(path)
    return _G.Instantiate(prefab)--声音装载
end

function Class:LoadSoundsPackage(path)
    local prefab = self:Load(path)
    return _G.Instantiate(prefab)--声音装载
end

function Class:Clear()
    for _,bundle in pairs(self.bundleCache)do
        bundle:Unload()
    end
    self.bundleCache = {}
    -- self.sceneCache = {}
    -- return self.bundlePathHelper:Clear()
end

--兼容旧Loader
function Class:LoadTextAsset(path)
    return self:Load(path)
end
--兼容旧Loader
function Class:LoadAsset(path, type)
    return self:Load(path, type)
end

return _ENV