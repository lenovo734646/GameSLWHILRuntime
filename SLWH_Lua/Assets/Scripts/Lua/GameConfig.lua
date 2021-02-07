local Config={
    debug = true,
    ShowAnimationTime = 8,
    ShowResultTime = 5,
    RunItemCount = 24,
    Ratio = {40, 30, 20, 10, 5, 5, 5, 5}, --下标从1开始
    Color ={ Red = 1, Green = 2, Yellow = 3, SanYuan = 4, SiXi = 5 },  -- 颜色定义
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

    Ease = {
        DG.Tweening.Ease.InOutSine, DG.Tweening.Ease.InOutQuad,
        DG.Tweening.Ease.InOutQuad, DG.Tweening.Ease.InOutCubic,
        DG.Tweening.Ease.InOutCubic, DG.Tweening.Ease.InOutQuart,
        DG.Tweening.Ease.InOutQuart, DG.Tweening.Ease.InOutQuint,
        DG.Tweening.Ease.InOutExpo, DG.Tweening.Ease.InOutFlash,
        DG.Tweening.Ease.InOutCirc, DG.Tweening.Ease.InOutFlash
    },
}

return Config