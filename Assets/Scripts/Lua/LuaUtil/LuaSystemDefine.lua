local GS = GS
local GF = GF
local pairs = pairs

_ENV = {}

UIICONPATH = "UI/" -- icon 路径
UIBOX = UIICONPATH .. "Icon/Box/" -- box路径
FISH = "fish/" -- 鱼预制路径
AUDIO = "AudioPrefab/" -- 音频路径
FISHBACKGROUND = "fish/BG/" -- 渔场背景图
BulletShootCD = 1000
BulletSpeed = 1000 -- 子弹速度，单位：单位/秒
SmsChannel = 0 --短信渠道
--自定义的主场景的按钮标签
MainBtnTag = "mainBtn"
--自定义的捕鱼场景的按钮标签
FishingBtnTag = "fishingBtn"
--自定义的主场景的红点标签
MainRedDotTag = "mainRedDot"
--自定义的捕鱼场景的红点标签
FishingRedDotTag = "fishingRedDot"

NickNameLength = 12--昵称的默认的字符长度
ScoreViewPara = 10000--积分显示权重
GroupId_Fish = 1--捕鱼服务组Id

CA3Key = 19357--CA3加密固定密钥.
VerifyWait = 60 -- 手机短信验证码再次请求间隔(可变)
VerifyWait_Succeed = 60--手机短信验证码请求成功再次请求间隔
VerifyWait_Failed = 10 -- 手机短信验证码请求失败再次请求间隔
PhoneNumberBindAccount_MAX_COUNT = 5   -- 一个手机号最多绑定账号数量，方便以后更改
ExchargeRate = 1 -- 1人民币兑换其他货币的数量（汇率），非中文用来把人民币金额转为对应的支持的货币金额(可变，根据实际汇率情况来设置)
if GS.SysDefines.curLanguage == "EN" then
    ExchargeRate = 0.1568 -- 1 人民币换 0.1568美元
end
--游戏内提示文字
FishTips = {
    DiamondInsufficient = "钻石不足",
    QuitGame = "确定要退出游戏？",
    QuitFishScene = "确定离开捕鱼界面",
    QuitMainScene = "确定返回登录界面",
    UnLock = "至少解锁{0}倍炮台才可进入游戏！",
    ShortGold = "金币不足",
    ForgeUnLock = "解锁到{0}倍即可开启锻造功能",
    ForgeEssenceCount = "水晶精华不足",
    SelectGifts = "请选择礼物",
    SelectPlayer = "请填写赠送玩家ID",
    DontGiveGiftsToSelf = "不能赠送礼物给自己",
    GiveGiftsSuccess = "赠送成功",
    PlayerIDError = "ID输入错误",
    NewInvestAddTip = "请先进行投资",
    CheckPlayer = "请先检测赠送玩家是否存在"
}
for key, value in pairs(FishTips) do
    _ENV[key]=value
end

return _ENV

