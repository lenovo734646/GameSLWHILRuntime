local _G = _G
local SEnv, class = SEnv, class
local print, tostring, Log, LogE, debug, pairs, string, assert = print, tostring, Log, LogE, debug, pairs, string,
    assert

local logError = logError
-- local AssetBundle = UnityEngine.AssetBundle
local config = require 'Config'
local yield = coroutine.yield
local SceneManager = SceneManager
-- local Resources = UnityEngine.Resources

require 'LuaUtil.Functions'

_ENV = moduledef {
    seenamespace = CS
}
-----------------------------------------


local function Log(...)
    -- log('[LuaAssetLoader]' .. str .. '\n' .. debug.traceback())
end

local Class = class()

function Create()
    return Class()
end

-- notCache在大厅运行时有用
function Class:Load(path, type)

    local isRawPath = path:Contains('Assets/')
    Log('Load from editor ' ,path, isRawPath)
    local r
    if type then
        r = ResHelper.Load(path, type, isRawPath)
    else
        r = ResHelper.Load(path, isRawPath)
    end
    if r then
        return r
    else
        LogE('can not load from editor ' .. path )
    end
    return Log('Load ' .. path)
end

-- 载入所有
function Class:LoadAll(path, type)
    local isRawPath = path:Contains('Assets/')

    Log('LoadAll from editor ' ,path, isRawPath)
    local r
    r = ResHelper.LoadAll(path, isRawPath)
    if r then
        return r
    else
        LogE('can not load from editor ' .. path )
    end
    return Log('LoadAll ' .. path)
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
--异步加载，在编辑器模式下看不出效果，但是建议使用此方法以提升加载流畅度
function Class:LoadAsync(path, infoOut)
    yield()
    local isRawPath = path:Contains('Assets/')
    infoOut = infoOut or {}
    infoOut.progress = 0
    return doDone(infoOut, ResHelper.Load(path, isRawPath))
end
-- 可以根据bundlename进行加载，在编辑器模式下无效
function Class:LoadBundle(bundlename)
    assert(bundlename)
end
-- 可以根据bundlename进行加载，在编辑器模式下无效
function Class:LoadBundleAsync(bundlename)
    assert(bundlename)
    yield()
    return
end

function Class:LoadBundleAllAsync(bundlename)
    
end

function Class:LoadScene(name)
    if config.isLoadFromEditor then
        SceneManager.LoadScene(name)
        return
    end
    local path = [[Assets/Scenes/]] .. name .. '.unity'
    self:Load(path)
    return SceneManager.LoadScene(name)
end

function Class:LoadSceneAsync(name, infoOut)
    if not config.isLoadFromEditor then
        local path = [[Assets/Scenes/]] .. name .. '.unity'
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
    return _G.Instantiate(prefab) -- 声音装载
end

function Class:LoadSoundsPackage(path)
    local prefab = self:Load(path)
    return _G.Instantiate(prefab) -- 声音装载
end
-- 释放所有资源
function Class:Clear()

end

return _ENV
