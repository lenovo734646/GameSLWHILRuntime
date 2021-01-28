local _G = _G
local g_Env = g_Env
local _CS = CS
local print, tostring, package, LogW, typeof, Destroy, LogE, string, ReloadModule, TraceErr = print, tostring,
    package, LogW, typeof, Destroy, LogE, string, ReloadModule, TraceErr

local print, tostring, require, pairs, ipairs, setmetatable, assert, string, rawset = print, tostring, require, pairs,
    ipairs, setmetatable, assert, string, rawset

local AssetLoader = CS.AssetLoader
local LuaBundleLoader = CS.LuaBundleLoader
local LuaFileLoader = CS.LuaFileLoader
local UnityHelper = CS.UnityHelper
local GameObject = GameObject
local DontDestroyOnLoad = DontDestroyOnLoad
local objectPoolMgrType = typeof(CS.ObjectPoolManagerSubGame)
local env = {}

local Loader = require 'Rebuild.LuaAssetLoader'
local Config = require 'Rebuild.Config'

-- 在小游戏中使用到的UI必须在这里加上引用
require 'UI.LuaSystemNoticeUI'
require 'UI.MessageBoxUI'
_ENV = env
--------------------------------------------------

local subGameG = {}

subGameG.CS = {
    UnityEngine = _CS.UnityEngine,
    XLuaExtension = _CS.XLuaExtension,
    Spine = _CS.Spine,
    DG = _CS.DG,
    ForRebuild = _CS.ForRebuild,
    TimeHelper = _CS.TimeHelper,
    ErrcodeHelper = _CS.ErrcodeHelper,
    YouMe = _CS.YouMe,
    Config = Config,
    ShotHitMessage = function(msg)
        g_Env.CreateHintMessage(msg)
    end
}
local CS = subGameG.CS

CS.AudioManager = _CS.AudioManager

CS.CoroutineController = _CS.CoroutineController

for k, v in pairs(_CS) do
    local s = tostring(k)
    if not s:Find('.') then
        CS[s] = v
        -- print(s)
    end
end

CS.Context = {}

local approot = {
    GameToHall = function()
        g_Env.SubGameCtrl.Leave()
    end,
    IsRunInHall = function()
        return true
    end
}

CS.AppRoot = {
    Get = function()
        return approot
    end

}
CS.GameController = {
    Instance = {
        Player = g_Env.gamePlayer,
        UIParent = g_Env.gamectrl.SubGameParent,--小游戏父级另外处理，方便释放
        MainCamera = g_Env.gamectrl.MainCamera,
        CreateHintMessage = function(_, msg)
            g_Env.CreateHintMessage(msg)
        end
    }
}

local UnityHelper_ = {}
for k, v in pairs(UnityHelper) do
    UnityHelper_[k] = v
end
UnityHelper_.PhysicsHit = function(...)
    return UnityHelper.PhysicsHit2(g_Env.gamectrl.MainCamera, ...)
end
CS.UnityHelper = UnityHelper_

local loader

local _G_bak = {}

function Init(config)
    print('--------------------sub game init')

    -- 给小游戏创建一个独立的对象池
    local ObjectPoolManager = {}
    local objpoolmgrMt = {
        __index = function(t, key)
            if key == 'Instance' then
                if ObjectPoolManager.poolmgr == nil then
                    local obj = GameObject('_SubGamePoolManager')
                    DontDestroyOnLoad(obj)
                    ObjectPoolManager.poolmgr = obj:AddComponent(objectPoolMgrType)
                end
                return ObjectPoolManager.poolmgr
            end
        end
    }
    setmetatable(ObjectPoolManager, objpoolmgrMt)
    CS.ObjectPoolManager = ObjectPoolManager

    local gameName = config.gameName
    loader = Loader.Create(g_Env.Config:GetSubGameResPath(gameName), false)
    assert(loader)
    local luaFileLoader = g_Env.luaFileLoader
    CS.Context.Game = {
        Loader = loader
    }
    subGameG.Loader = loader

    if g_Env.Config.debugSubGame then
        local luaScriptPath = g_Env.Config:GetSubGameDebugLuaScriptPath(gameName)
        print('luaScriptPath', luaScriptPath)
        local fileloader = LuaFileLoader(luaScriptPath)
        luaFileLoader.bundleLoader = function(filename)
            return fileloader:LoadFile(filename)
        end
    else
        local textAssetsLoader = function(filename)
            return loader:Load(filename)
        end
        local luaBundleLoader = LuaBundleLoader("Assets/Lua", textAssetsLoader)
        luaFileLoader.bundleLoader = function(filename)
            return luaBundleLoader:LoadFile(filename)
        end
    end

    g_Env.loadedpackage = package.loaded
    for k, _ in pairs(g_Env.loadedpackage) do
        package.loaded[k] = nil
    end

    local function MoveToBak(name)
        _G_bak[name] = _G[name]
        _G[name] = nil
    end
    MoveToBak 'CS'
    MoveToBak '__TRACKBACK__'
    MoveToBak 'class'
    MoveToBak 'LuaClass'
    MoveToBak 'LuaBase'

    MoveToBak 'functional'
    MoveToBak 'math'
    MoveToBak 'json'

    setmetatable(_G, {
        __index = function(t, k)
            local v = subGameG[k]
            if v == nil then
                return _G_bak[k]
            end
            return v
        end,
        __newindex = function(t, k, v)
            if v == nil then
                TraceErr(k .. ' try set to nil')
            else
                subGameG[k] = v
            end
        end
    })

    ReloadModule 'Main'
    g_Env.isInSubGame = true

end

function Release()
    print('-----------SubGame Release')
    local t = {}
    for k, _ in pairs(package.loaded) do
        t[k] = true
    end
    for k, _ in pairs(t) do
        package.loaded[k] = nil
        print(k)
    end
    for k, v in pairs(g_Env.loadedpackage) do
        package.loaded[k] = v
    end
    setmetatable(_G, nil)
    for k, v in pairs(_G_bak) do
        _G[k] = v
    end
    _G_bak = {}

    loader:Clear()
    loader = nil

    Destroy(CS.ObjectPoolManager.poolmgr.gameObject)
    CS.ObjectPoolManager = nil

    local childCount = g_Env.gamectrl.SubGameParent.childCount
    if childCount>0 then
        LogW('小游戏没有自己释放所有Unity.Object')
        for i = 1, childCount do
            local obj = g_Env.gamectrl.SubGameParent:GetChild(i-1)
            LogW('Destroy '..tostring(obj))
            Destroy(obj)
        end
    end

    g_Env.isInSubGame = false
end

return _ENV
