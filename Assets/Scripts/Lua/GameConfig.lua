local Tweening = CS.DG.Tweening

local Config={
    debug = false,
    ShowRunTime = 2,
    ShowSharkRunTime = 1,
    ShowAnimationTime = 8,
    ShowZhanShiTime = 4.1,    --中奖动物展示动画时间（固定3秒+跳入动画1.1，Victory动画长度不是3秒的进行了速度调整）
    ShowResultTime = 5,     --结算界面显示时间（可调整）
    JumpTime = 1.1,
    RunItemCount = 24,
    AnimalCount = 4,
    -- 胜利音效名字（根据itemID）
    WinSound = {"red_lion", "red_panda", "red_monkey", "red_rabbit", 
                "green_lion", "green_panda", "green_monkey", "green_rabbit",
                "yellow_lion", "yellow_panda", "yellow_monkey", "yellow_rabbit",
                "enjoygame_zhuang", "enjoygame_he","enjoygame_xian" },

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
        -- Tweening.Ease.InOutQuad, Tweening.Ease.InOutCubic,
        -- Tweening.Ease.InOutCubic, Tweening.Ease.InOutQuart,
        -- Tweening.Ease.InOutQuart, Tweening.Ease.InOutQuint,
        -- Tweening.Ease.InOutExpo, Tweening.Ease.InOutFlash,
        -- Tweening.Ease.InOutCirc, Tweening.Ease.InOutFlash
    },

    -- 游戏状态 1=下注 2=开奖 3=空闲 
    GameState = {
        BET = 1,
        SHOW = 2,
        FREE = 3,
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
    
    BetErrorTip = {
        "下注失败：你不在房间中", "下注失败：当前阶段不是下注阶段","下注失败：下注筹码不合法",
        "下注失败：下注项不合法","下注失败：金币不足","下注失败：超过个人下注最大上限",
        "下注失败：超过房间下注最大上限",
        "下注失败：庄家不可以下注",
    },
    EnterRoomErrorTip = {
        "已经在房间中", "房间人数已满", "系统错误"
    },
}

return Config