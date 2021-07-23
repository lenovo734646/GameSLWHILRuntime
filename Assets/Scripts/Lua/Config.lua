
print'此文件只在小游戏编辑器模式使用 Cofig.lua'


 
local persistentDataPath = CS.UnityEngine.Application.persistentDataPath

local Config = {
    debug = true,
    debugPlazaRoot = [[E:\WorkRoot\fll3d_plaza\client\Plaza\]],
    debugSubGameRoot = [[E:\WorkRoot\fll3d_subGames\]],
    debugSubGameScriptPath = [[\Assets\Scripts\Lua\]],--调试时期使用源码
    debugOneGameId = 15, --指定只显示某个id的游戏，-1表示不指定

    debugUpdate = false,
    debugAutoLogin = true,

    debugPlatform = 'Win',

    plazaSavePath = persistentDataPath..[[\hall\]],
    commonSavePath = persistentDataPath..[[\common\]],
    plazaDownloadUrl = [[E:\WorkRoot\fll3d_plaza\client\Plaza\StreamingAssets\Win\]],--强制指定大厅使用哪个目录的资源，需要关闭isLoadFromEditor才能生效
    --plazaDownloadUrl = persistentDataPath..[[\Android\]],
    isLoadFromEditor = true,--要从编辑器加载，需要在BuildSetting里面添加场景

    debugProto = false,

    IsLoadFromEditor = function (self)
        if not self.debug then return false end
        return self.isLoadFromEditor
    end,
    IsUpdate = function (self)
        if not self.debug then return true end --默认是更新
        return self.debugUpdate
    end,
    IsAutoLogin = function (self)
        if not self.debug then return true end
        return self.debugAutoLogin
    end,
    GetPlazaSavePath = function (self)
        if self.debug then 
            return self.debugPlazaRoot..[[StreamingAssets\]]..self:GetPlatform()..[[\hall\]] 
        end
        return self.plazaSavePath
    end,
    GetCommonSavePath = function (self)
        if self.debug then 
            return self.debugPlazaRoot..[[StreamingAssets\]]..self:GetPlatform()..[[\common\]] 
        end
        return self.commonSavePath
    end,
    GetSavePath = function (self, name)
        return self['Get'..name..'SavePath'](self)
    end,

    GetPlatform = function (self)
        if self.debug then 
            return self.debugPlatform
        end
        return CS.UnityHelper.GetPlatform()
    end,

    GetStreamingAssetPath = function (self, gameName)
        if self.debug then 
            return self.debugSubGameRoot..gameName..'_Lua'..[[\StreamingAssets\]]..self:GetPlatform()..'/'
        end
        return persistentDataPath..'/'..gameName..'/'
    end,

    GetDebugLuaScriptPath = function (self, gameName)
        return self.debugSubGameRoot..gameName..'_Lua'..self.debugSubGameScriptPath
    end,

debugPBPath = [[E:\WorkRoot\fll3d_support\protobuf\config\]],

    LoadPBString = function (self,pkgname)
        if self.debug then
            if self.debugProto then
                local path = debugPBPath..pkgname..'.proto'
                local file = io.open(path, "r")
                return file:read("*a")
            else
                return require("protobuffer."..pkgname)
            end
        else
            return require("protobuffer."..pkgname)
        end
    end,
}

return Config