local Tweening = CS.DG.Tweening

local Config={
    debug = true,
    ShowAnimationTime = 8,
    ShowResultTime = 5,
    RunItemCount = 24,
    Ratio = {40, 30, 20, 10, 5, 5, 5, 5}, --下标从1开始
    Color ={ Red = 1, Green = 2, Yellow = 3, SanYuan = 4, SiXi = 5 },  -- 颜色定义
    -- 胜利音效名字（根据itemID）
    WinSound = {"red_lion", "red_panda", "red_monkey", "red_rabbit", 
                "green_lion", "green_panda", "green_monkey", "green_rabbit",
                "yellow_lion", "yellow_panda", "yellow_monkey", "yellow_rabbit",
                "enjoygame_zhuang", "enjoygame_xian", "enjoygame_he"},

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
        Tweening.Ease.InOutSine, Tweening.Ease.InOutQuad,
        Tweening.Ease.InOutQuad, Tweening.Ease.InOutCubic,
        Tweening.Ease.InOutCubic, Tweening.Ease.InOutQuart,
        Tweening.Ease.InOutQuart, Tweening.Ease.InOutQuint,
        Tweening.Ease.InOutExpo, Tweening.Ease.InOutFlash,
        Tweening.Ease.InOutCirc, Tweening.Ease.InOutFlash
    },

    ColorType = {
        Red = 1,
        Green = 2,
        Yellow = 3, 
        SanYuan = 4,
        SiXi = 5,
    },

    ExWinType = {
        CaiJin = 1,
        SongDeng = 2,
        LiangBei = 3,
        SanBei = 4,
        MeiZhong = 5,
    },

    AnimalType = {
        Lion = 1,      
        Panda = 2,    
        Monkey = 3,        
        Rabbit = 4,
    },

    EnjoyGameType = {
        Zhuang = 1,
        Xian = 2,
        He = 3,
    },
    
}

return Config