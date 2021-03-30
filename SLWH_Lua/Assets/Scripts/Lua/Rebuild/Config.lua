
-- 小游戏独立运行时使用Config
print'此文件只在小游戏编辑器模式使用 Config.lua'

local persistentDataPath = Application.persistentDataPath

local debugSubGamePath = {
    -- GameFQSZ = [[H:\sub_game_feiqin\FQZS_Lua\StreamingAssets\Win]],
    GameJXLW = {
        scriptpath = [[H:\GameJXLW\Assets\Scripts\Lua\]],
        respath = [[H:\GameJXLW\StreamingAssets\Win\]]
    },
    GameShz = {
        scriptpath = [[H:\GameShz\Assets\Scripts\Lua\]],
        respath = [[H:\GameShz\StreamingAssets\Win\]]
    },
    FishingJJH = {
        scriptpath = [[H:\FishingJJH\Assets\Scripts\Lua\]],
        respath = [[H:\FishingJJH\StreamingAssets\Win\]]
    },
    BCBM = {
        scriptpath = [[H:\BCBM\Assets\Scripts\Lua\]],
        respath = [[H:\BCBM\StreamingAssets\Win\]]
    },
    SLWH = {
        scriptpath = [[H:\SLWH\Assets\Scripts\Lua\]],
        respath = [[H:\SLWH\StreamingAssets\Win\]]
    },
    FQZS = {
        scriptpath = [[H:\FQZS\Assets\Scripts\Lua\]],
        respath = [[H:\FQZS\StreamingAssets\Win\]]
    },
}

local Config = {
    debug = true,
    debugPlazaRoot = [[H:\fll3d_plaza\client\Plaza\]],
    debugOneGameId = 1, -- 指定只显示某个id的游戏，-1表示不指定

    debugSubGame = true,
    debugUseSubGameDebugPath = true,--是否使用debugSubGamePath配置的路径
    debugUpdate = false,
    debugAutoLogin = true,

    debugUseLocalPath = false,

    debugPlatform = 'Win',
    
    
    RunWithoutNet = true,   -- 是否离线本地运行（不连接服务器）
    useHttps = false,

    isLoadFromEditor = true, -- 要从编辑器加载，需要在BuildSetting里面添加场景

    IsLoadFromEditor = function(self)
        if not self.debug then
            return false
        end
        return self.isLoadFromEditor
    end,
    IsUpdate = function(self)
        if not self.debug then
            return true
        end -- 默认是更新
        return self.debugUpdate
    end,
    IsAutoLogin = function(self)
        if not self.debug then
            return true
        end
        return self.debugAutoLogin
    end,
    

    GetDownUrlBase = function(self)
        local hallurl = g_Env.netinfo.OssUrl .. '/HotUpdate/Hall/' .. CS.UnityHelper.GetPlatform() .. '/'
        if self.useHttps then
            return hallurl
        end
        return hallurl:replace('https', 'http')
    end,
    GetPlazaDLUrl = function(self)
        return self:GetDownUrlBase() .. [[hall_\]]
    end,

    GetCommonDLUrl = function(self)
        return self:GetDownUrlBase() .. [[common_\]]
    end,
    GetSubGameDLUrl = function(self, gameName)
        return g_Env.netinfo.OssUrl .. '/HotUpdate/1/Games/' .. gameName .. '/' .. self:GetPlatform() .. '/'
    end,
    GetSubGameDLPath = function(self, gameName)
        return persistentDataPath .. '/' .. gameName .. '/'
    end,
    -- 被GetSavePath引用
    GetPlazaSavePath = function(self, isDownloading)
        if self.debug and self.debugUseLocalPath and not isDownloading then
            return self.debugPlazaRoot .. [[StreamingAssets\]] .. self:GetPlatform() .. [[\hall_\]]
        end
        return persistentDataPath .. [[\hall_\]]
    end,
    -- 被GetSavePath引用
    GetCommonSavePath = function(self, isDownloading)
        if self.debug and self.debugUseLocalPath and not isDownloading then
            return self.debugPlazaRoot .. [[StreamingAssets\]] .. self:GetPlatform() .. [[\common_\]]
        end
        return persistentDataPath .. [[\common_\]]
    end,
    -- 被GetSavePath引用
    GetFishSavePath = function(self, isDownloading)
        if self.debug and self.debugUseLocalPath and not isDownloading then
            return self.debugPlazaRoot .. [[StreamingAssets\]] .. self:GetPlatform() .. [[\fishing3d_\]]
        end
        return persistentDataPath .. [[\fishing3d_\]]
    end,
    GetSavePath = function(self, name)
        if name == 'Fishing3D' then
            return self:GetFishSavePath()
        end
        local f = self['Get' .. name .. 'SavePath']
        if f then
            return f(self)
        end
        if self.debug then
            return self.debugPlazaRoot .. [[StreamingAssets\]] .. self:GetPlatform() .. '/' .. name .. '/'
        end
        return self:GetSubGameDLPath(name)
    end,

    GetPlatform = function(self)
        if self.debug and self.debugPlatform then
            return self.debugPlatform
        end
        return CS.UnityHelper.GetPlatform()
    end,

    GetSubGameResPath = function(self, gameName)
        if self.debugUseSubGameDebugPath then
            local info = debugSubGamePath[gameName]
            if info then
                return info.respath
            end
            assert(false)
        else
            return persistentDataPath..'/'..gameName..'/'
        end

    end,

    GetSubGameDebugLuaScriptPath = function(self, gameName)
        local info = debugSubGamePath[gameName]
        if info then
            return info.scriptpath
        end
        assert(false)
    end,

    debugPBPath = [[H:\fll3d_support\protobuf\config\]],

    debugPBLoadFromFile = false,

    LoadPBString = function(self, pkgname)
        if self.debug then
            if self.debugPBLoadFromFile then
                local path = self.debugPBPath .. pkgname .. '.proto'
                local file = io.open(path, "r")
                return file:read("*a")
            else
                return require("protobuffer." .. pkgname)
            end
        else
            return require("protobuffer." .. pkgname)
        end
    end,

    -- testEnterSubGame = 'FishingJJH',
    GetDebugEnterSubGame = function (self)
        if self.debug then
            return self.testEnterSubGame
        end
    end,
}

CS.DG.Tweening.DOTween.SetTweensCapacity(500, 50)

if _NDEBUG then
    Config.debug = false
end

return Config
