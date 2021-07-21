
/******************************************************************************
 * 
 *  Title:  捕鱼项目
 *
 *  Version:  1.0版
 *
 *  Description:
 *    1：系统常量
 *    2：全局枚举对象
 *    3：全局委托
 *
 *  Author:  WangXingXing
 *       
 *  Date:  2018
 * 
 ******************************************************************************/

using System;
using System.Collections.Generic;
using UnityEngine;


/// <summary>
/// 对象当前状态
/// </summary>
public enum EnumObjectState
{
    None,
    Initial,                 //初始化
    Loading,                 //装载中
    Ready,                   //准备结束
    Disabled,                //过去的
    Closing,                 //关闭
}

//ui界面类型
public enum EnumUIType
{
    None = -1,

    LuaUI,                              //所有热更界面共用

    AwardUI,                            //获奖界面
    ChangeGunUI,                        //切换炮台界面
    FirstChargeUI,                      //首充界面
    FishFreeDrawUI,                     //赏金鱼抽奖界面
    FishingSelectUI,                    //竞技场渔场选择界面
    FishingCommonUI,                    //普通竞技场界面
    FishingFreeMatchUI,                 //免费赛界面
    FishingRewardMatchUI,               //大奖赛界面
    ForgeUI,                            //锻造界面
    KnapsackUI,                         //背包界面
    LevelUpUI,                          //升级界面
    LoadingUI,                          //过度界面
    LoginUI,                            //登录界面
    MainUI,                             //主界面
    MessageBoxUI,                       //消息弹窗界面
    MonthCardUI,                        //月卡界面
    PersonalInfoUI,                     //个人信息界面
    RechargeUI,                         //商城界面
    SettingUI,                          //设置界面
    VIPUI,                              //VIP特权界面
    WelfareUI,                          //福利中心界面
    RankUI,                             //排行榜
    ArenaUI,                            //比赛场选择
    FreeMatchUI,                        //免费赛报名排行
    RewardMatchUI,                      //大奖赛报名排行
    VIPLottery,                         //VIP转盘
    MailUI,                             //邮件
    GuildListUI,                        //工会列表
    GuildHomeUI,                        //工会主界面
    GuildHallUI,                        //工会大厅
    GuildSetupUI,                       //创建工会设置
    GuildSelectBadgeUI,                 //选择工会徽章
    GuildMemberManagementUI,            //工会成员管理
    GuildApplicationListUI,             //工会申请界面
    GuildSetupUpgradeUI,                //工会修改界面
    GuildRedPacketMainUI,               //工会红包主界面
    GuildWarehouseUI,                   //工会仓库
    GuildRedPacketHelpUI,               //工会红包说明界面
    GuildRedPacketRankUI,               //工会红包排行
    GuildRedPacketGrabUI,               //工会红包拆开界面
    GuildChairmanWelfareUI,             //工会会长福利
    GuildChairmanWelfareHelpUI,         //工会会长福利说明
    GuildWarheadAllotUI,                //工会物品分配界面
    GuildWarehouseJournalUI,            //工会仓库日志
    NoticeUI,                           //公告
    InputBoxUI,                         //物品输入通用弹窗
    FishHandBookUI,                     //鱼百科
    FishingFreeMatchResultUI,           //免费赛成绩
    FishingRewardMatchResultUI,         //大奖赛成绩
    DailyChargeUI,                      //每日充值礼包
    //SystemNoticeUI,                     //系统消息
    WelfarePigUI,                       //砸金猪
    WelfarePigAwardUI,                  //砸金猪奖励界面
    InvestUI,                           //投资界面
    ExchangePropDetailsUI,              //兑换实物详情
    ExchangeFillOrderUI,                //兑换实物玩家信息
    ExchangeRecordUI,                   //兑换记录
    NoviceGuideUI,                      //新手引导
    VIPPrivilegeUI,                     //VIP特权界面
    NuclearBombUI,                      //弹头目标选择界面
    RoomSelectUI,                       //选房间界面
    MessageLeaveFishUI,                 //退出渔场等待界面
    VIPLevelUpUI,                       //VIP升级界面
    SailGiftUI,                         //起航礼包
    UserAgreementUI,                    //用户协议
    PrivacyGuidelinesUI,                //用户隐私
    HotUpdateUI,                        //热更界面
    WorldBossOrderUI,                   //世界Boss悬赏令
    WorldBossRankUI,                    //世界Boss排行榜
    WorldBossResultUI,                  //世界Boss结算
    PayUI,                              //支付界面
    RegisterUI,                         //账号注册界面
    WelfareExchangeUI,                  //兑换码
    VaultUI,                            //金库界面
    VaultRegisterUI,                    //金库注册界面
    PhoneVerifyUI,                      //手机验证界面
    PhoneBindUI,                        //手机绑定/更换界面
    AgencyUI,                           //全民代理
    GiveGiftsUI,                        //礼物
    WaitForGameEndUI,                   //等待进行中的游戏结束
    NuclearBombCountUI,                 //弹头数量选择界面
    AgateMainUI,                        //聚宝盆小游戏界面
    PayAgentUI,                         //代理支付界面
    PayQRCodeUI,                        //扫码支付界面
    MagicUI,                            //魔力场魔力转换界面
    WarheadComposeUI,                   //弹头合成界面
    RoomPasswordUI,                     //密码房界面
    MessageBoardUI,                     //留言板界面
}

//event事件类型
public enum EnumTouchEventType
{
    OnBeginDrag,
    OnCancel,
    OnDeselect,
    OnDrag,
    OnDrop,
    OnEndDrag,
    OnInitializePotentialDrag,
    OnMove,
    OnClick,
    OnDoubleClick,
    OnDown,
    OnEnter,
    OnExit,
    OnUp,
    OnScroll,
    OnSelect,
    OnSubmit,
    OnUpdateSelected,
}

//场景类型
public enum EnumSceneType
{
    Entry = 0,
    FishScene,
    LoadingScene,
    MainScene,
}



//按钮点击可变参数的键值类型
public enum EnumHashtableParamsType
{
    None = 0,
    Audio,
    LockAllClick,
    LockSelfClick,
}







/// <summary>
/// 玩家性别
/// </summary>
public enum EnumPlayerGenderType
{
    Unknown = 0,              //保密
    Male,                     //男
    Female,                   //女
}

public class SysDefines
{

    //icon 路径
    public const string UIICONPATH = "UI/";

    //头像路径
    public const string UIHEAD = UIICONPATH + "Icon/Head/";
    //头像框路径
    public const string UIFRAME = UIICONPATH + "Icon/Frame/";
    //排行标志
    public const string UIRANK = UIICONPATH + "Icon/Rank/";
    //徽章
    public const string UIBADGE = UIICONPATH + "Icon/Badge/";
    //box路径
    public const string UIBOX = UIICONPATH + "Icon/Box/";
    //鱼图鉴
    public const string UIHANDBOOK = UIICONPATH + "HandBook/";
    //鱼预制路径
    public const string FISH = "fish/";
    //音频路径
    public const string AUDIO = "AudioPrefab/";
    //渔场背景图
    public const string FISHBACKGROUND = "fish/BG/";
    //特效路径
    public const string FISHEFFECT = "Effect/";
    //区服预设路径
    public const string ZONEPREFAB = "Zones/";
    //单个角色渔场中存在最大的子弹数
    public const int BulletLimitNum = 40;
    //子弹发射CD，单位：毫秒/发
    public const ulong BulletShootCD = 1000;
    //子弹速度，单位：单位/秒
    public const float BulletSpeed = 1000;
    //炮台长度，单位：像素
    public const float CannoGunLength = 130;
    //区服ID
    public const int ZoneId = 1;
    //短信渠道
    public static int SmsChannel = 0;
    //自定义的主场景的按钮标签
    public const string MainBtnTag = "mainBtn";
    //自定义的捕鱼场景的按钮标签
    public const string FishingBtnTag = "fishingBtn";
    //自定义的主场景的红点标签
    public const string MainRedDotTag = "mainRedDot";
    //自定义的捕鱼场景的红点标签
    public const string FishingRedDotTag = "fishingRedDot";
    //产品版本号
    public const uint Version = 1;
    //昵称的默认的字符长度
    public const int NickNameLength = 12;
    //积分显示权重
    public const long ScoreViewPara = 10000;
    //大厅的游戏ID(热更新)
    public const int GameID_Hall = 1001;
    //捕鱼服务组Id
    public const int GroupId_Fish = 1;

    //CA3加密固定密钥
    public const int CA3Key = 19357;
    //手机短信验证间隔
    public const int VerifyWait = 60;
    //礼物组件标签
    public const string GiftsTag = "giftsItem";
    //聚宝天宫总时间
    public const int TreasureTotalTime = 40;
    //聚宝天宫物品掉落增速间隔时间
    public const int TreasureAddSpeedIntervalTime = 10;
    //#endregion

    //#region 静态变量
    public static int outScreenOffset = 10;
    public static Dictionary<string, int> outScreenOffsetDic = new Dictionary<string, int>() {

    };
    //射线获得指定的层级
    public static int FishLayer = 1 << LayerMask.NameToLayer("Fish");
    //是否检测过版本信息
    public static bool IsCheckVersion = false;
    //public static string Ip = string.Empty;
    //public static long Port;
    //public static string OssUrl = string.Empty;
    public static string HotUpdateUrl = string.Empty;
    public static string PopularizeUrl = string.Empty;
    //public static string OpeninstallToken = string.Empty;
    // 运行平台 1:IOS 2:ANDRIOD 3:WINDOWS 4:LINUX 5:MAC
    public static uint Platform;
    //登录标识
    public static string LoginToken;
    //本次进入游戏是否首次登录      0是1否
    public static int FirstLogin = 0;
    //本次进入大厅是否首次        0是1否 
    public static int FirstEnterHall = 0;
    //加入玩法
    //public static EnumSiteType SiteId = EnumSiteType.None;
    //public static int SiteId = -1;
    //加入房间的ID
    public static int RoomConfigID = 0;
    //当前房间视角    1侧视角 2斜俯
    public static int RoomViewAngle = 1;
    //是否固定零点捕鱼碰撞边框比率为16:9
    public static bool isFixedScreen = true;
    //渔场碰撞边框宽度
    public static float DesignWidth = 1920;
    //渔场碰撞边框高度
    public static float DesignHeight = 1080;
    //普通模式发炮速度倍率
    public static double NormalBulletShootRate = 1;
    //穿透模式发炮速度倍率
    public static double PenetrateBulletShootRate = 1;
    //聚宝盆子弹速度倍率
    public static double AgateBulletSpeedRate = 0.6;
    //普通模式子弹速度倍率
    public static double NormalBulletSpeedRate = 1;
    //穿透模式子弹速度倍率
    public static double PenetrateBulletSpeedRate = 1;

    //是否在渔场中
    public static bool IsInFishingGame;
    //当前场景
    public static EnumSceneType SceneType = EnumSceneType.Entry;
    //预加载界面 大小大于1M的都加入预加载
    public static EnumUIType[] preloadUIArray = new EnumUIType[]
    {
        EnumUIType.FishingSelectUI,
        EnumUIType.InvestUI,
        EnumUIType.RechargeUI,
        EnumUIType.RankUI,
        EnumUIType.WelfarePigUI,
        EnumUIType.WelfareUI
    };

    public static string[] preloadPrefab = new string[]
    {
        "eff_fishdie",
        "eff_fishdie_small",
        "fishBigBomb",
        "fishBossBomb",
        "fishBossBomb_Contest",
        "fishGoldBomb",
        "fishingSiteSelf",
        "fishingSiteOther_0_1",
        "fishingSiteOther_2_3",
        "Effect_Boom_UI",
        "Effect_Ice_UI",
        "dropBomb",
        "dropBombOther",
        "fishComeTips",
    };
//#endregion



    public static int NetMaxHandlePackPerFrame = 10;//每帧最多处理的数据包

    public static string AB_BASE_PATH = "Assets/AssetsFinal/";

    public static bool Relogin = false;

    public static string curLanguage = "CN";

    public static string tempStr = "";

    public static bool throwErrMsg = false;

    public static string QLPostContentType = "application/x-www-form-urlencoded;charset=utf-8";
    public static string QLUserAgent = "ql-sdk-net";
    public static string QLAccept = "text/xml,text/javascript";

    public static void LogError(string err)
    {
        if (throwErrMsg)
            throw new Exception(err);
        else
        {
            Debug.LogError(err);
        }
    }
}
