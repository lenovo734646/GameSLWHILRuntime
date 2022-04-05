
print'此文件只在小游戏编辑器模式使用 Cofig.lua'

local Config = {
    debug = true,
    playMusic = false,
    playEffect = false,

    debugPBPath = [[E:\WorkRoot\fll3d_support\protobuf\config\]],
    LoadPBString = function (self,pkgname)
        if self.debug then
            if self.debugProto then
                local path = self.debugPBPath..pkgname..'.proto'
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