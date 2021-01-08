local Config={
    debug = true,
    ShowAnimationTime = 8,
    ShowResultTime = 5,
    RunItemCount = 32,
    Ratio = {40, 30, 20, 10, 5, 5, 5, 5}, --下标从1开始
    -- 胜利音效名字（根据itemID）
    WinSound = {"shizi", "laoying", "xiongmao", "kongque", "houzi", "gezi", "tuzi", "yanzi"},

    debugPBPath = [[E:\WorkRoot\fll3d_support\protobuf\config\]],

    LoadPBString = function (self,pkgname)
        if self.debug then
            local path = [[E:\WorkRoot\fll3d_support\protobuf\config\]]..pkgname..'.proto'
            local file = io.open(path, "r")
            return file:read("*a")
        else
            return require("protobuffer."..pkgname)
        end
    end,
}

return Config