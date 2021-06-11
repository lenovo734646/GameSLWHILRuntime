local _G = _G
local g_Env,class = g_Env,class
local print, tostring, log, typeof, debug, pairs,string, assert =
      print, tostring, log, typeof, debug, pairs,string, assert

local logError = logError

local UnityEngine = CS.UnityEngine
local AssetBundle = UnityEngine.AssetBundle
local yield = coroutine.yield
local SceneManager = CS.UnityEngine.SceneManagement.SceneManager
-- local Resources = UnityEngine.Resources


local Config = require'Config'

_ENV = moduledef { seenamespace = CS }
-----------------------------------------

local function LogE(str)
    logError('[LuaAssetLoader]'..str..'\n'..debug.traceback())
end

local function Log(str)
    log('[LuaAssetLoader]'..str..'\n'..debug.traceback())
end

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(basepath,name)
    self.sceneCache = {}
    self.basepath = basepath
    self.getFullPathFunc = function (filename)
        return basepath .. filename
    end
    self.bundleManager = BundleManager(self.getFullPathFunc, true)
    self.bundleManager.name = name or 'noname'--目前是为了调试
end

function Class:Load(path,type)
    Log('Load'..path)
    if Config:IsLoadFromEditor() then
        local r
        if type then
            r = ResHelper.Load(path, type)
        else
            r = ResHelper.Load(path)
        end
        if r then 
            return r 
        else
            LogE('can not load from editor '..path..'\nbasePath='..self.basepath)
        end
    end

    local bundle = self.bundleManager:LoadAssetBundleByPath(path)
    if bundle then
        local r
        if type then
            r = bundle:LoadAsset(path, type)
        else
            r = bundle:LoadAsset(path)
        end
        
        if r then 
            return r 
        else
            LogE('can not load res '..path..'\nbasePath='..self.basepath)
        end
    else
        LogE('can not load bundle '..path..'\nbasePath='..self.basepath)
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


local function getBundleAsync(self, bundleHashName, bundleManager)
    assert(bundleHashName)
    assert(bundleManager)
    local assetBundle = bundleManager:GetAssetBundleFromCache(bundleHashName)
    if not assetBundle then
        local bundlefullpath = self.getFullPathFunc(bundleHashName)
        local reqab = AssetBundle.LoadFromFileAsync(bundlefullpath)
        yield(reqab)
        if(reqab.assetBundle==nil) then
            LogE('AssetBundle.LoadFromFileAsync failed. path:'..bundlefullpath)
            return
        end
        assetBundle = reqab.assetBundle
        bundleManager:AddCache(bundleHashName, assetBundle)
    end
    return assetBundle
end

function Class:LoadBundleAsync(bundlename)
    if  g_Env.Config:IsLoadFromEditor() then 
        yield()
        return 
    end
    local bundleManager = self.bundleManager
    local bundleHashName = bundleManager:GetAssetBundleHashName(bundlename)
    if string.isNullOrEmpty(bundleHashName) then
        LogE('can not find '..bundlename)
        return
    end
    local assetBundle = getBundleAsync(self, bundleHashName, bundleManager)
    if not assetBundle then
        return
    end
    
    return assetBundle
end

function Class:LoadBundleAllAsync(bundlename)
    local assetBundle = self:LoadBundleAsync(bundlename)
    if not assetBundle then
        return
    end
    
    local allnames = assetBundle:GetAllAssetNames()
    local len = allnames.Length-1
    for i = 0, len do
        local name = allnames[i]
        local req = assetBundle:LoadAssetAsync(name)
        yield(req)
        
    end
    return assetBundle
end

function Class:LoadSceneAsync(name)
    if not g_Env.Config:IsLoadFromEditor() then
        self:LoadBundleAsync('scene')
    end
    yield(SceneManager.LoadSceneAsync(name))
    self.sceneCache[name] = true
end

function Class:LoadAsync(path, req)
    req.progress = 0
    local bundleManager = self.bundleManager
    local bundlename = bundleManager:GetAssetBundleName(path)
    if string.isNullOrEmpty(bundlename) then
        return doDone(req, ResHelper.Load(path))
    end
    local bundleHashName = bundleManager:GetAssetBundleHashName(bundlename)
    if string.isNullOrEmpty(bundleHashName) then
        return doDone(req, ResHelper.Load(path))
    end
    if req.withDependencies then
        local strs = bundleManager:GetAllDependencies(bundleHashName)
        if strs then
            local len = strs.Length-1
            for i=0,len do
                local s = strs[i]
                getBundleAsync(self, s, bundleManager)
            end
        end
    end
    
    local assetBundle = getBundleAsync(self, bundleHashName, bundleManager)
    if not assetBundle then return doDone(req, ResHelper.Load(path)) end

    local passedpro = req.progress
    local leftpro = 1-passedpro
    local reqab = assetBundle:LoadAssetAsync(path)
    while not reqab.isDone do
        yield()
        req.progress = passedpro + reqab.progress * leftpro
    end
    return doDone(req, reqab.asset)
end


function Class:LoadScene(name)
    if Config:IsLoadFromEditor() then
        SceneManager.LoadScene(name)
        return
    end
    if self.sceneCache[name] then
        SceneManager.LoadScene(name)
        return
    end
    local path = [[Assets/Scenes/]]..name..'.unity'
    assert(self.bundleManager:LoadAssetBundleByPath(path),path)
    SceneManager.LoadScene(name)
    self.sceneCache[name] = true
end

function Class:Clear()
    self.sceneCache = {}
    return self.bundleManager:Clear()
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