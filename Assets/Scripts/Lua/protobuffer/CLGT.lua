return [[
syntax = "proto3";

//客户端与网关之间的消息
package CLGT;

//握手请求
message HandReq
{
    enum PlatformType
    {
        Unknown = 0;
        IOS = 1;
        ANDROID = 2;
        WINDOWS = 3;
        LINUX = 4;
        MAC = 5;
        WebGL = 6;
    }
    PlatformType platform = 1;
    int32 product = 2;              //产品代号 0:未知的产品 1:游戏平台
    int32 version = 3;              //产品版本号
    string device = 4;              //机器设备码
    int32 channel = 5;              //渠道 0未知 1官方 2苹果 3华为 4OPPO 5VIVO 6小米 7应用宝 8百度 9快手 10抖音
    string country = 6;             //国家标识
    string language = 7;            //语言标识
}
//握手回应
message HandAck
{
    int32 errcode = 1;              //0成功 1无法识别的平台 2无法识别的产品 3版本太老需强更 4拒绝访问 5你的IP已被封禁 6你的设备已被封禁
    int32 payload = 2;              //当前网关负载
    bytes random_key = 3;           //随机秘钥数组
    repeated int32 random_key_arr = 4;
}
//网络中断通知
message DisconnectNtf
{
    int32 code = 1;                 //0断开通知 1连接超时 2被踢下线 3被挤下线 4网关维护 5平台维护 6游戏维护 7与平台服务器断开连接 8与游戏服务器断开连接 9系统错误 10离线挂机
    string errmessage = 2;          //附加错误信息，目前是当错误码为9时该字段有效
}
//物品信息结构 STRUCT!!
message ItemInfo
{
    int32 item_id = 1;              //物品主类型
    int32 item_sub_id = 2;          //物品子类型
    int64 item_count = 3;           //物品数量
}
//登录平台请求
message LoginReq
{
    enum LoginType
    {
        Unknown = 0;            //未知
        Guest = 1;              //游客
        Phone = 2;              //手机
        QQ = 3;                 //QQ
        Wechat = 4;             //微信
        Facebook = 5;           //Facebook
        GooglePlay = 6;         //GooglePlay
        GameCenter = 7;         //GameCenter
    }
    LoginType login_type = 1;   //登录方式
    string token = 2;           //唯一标识串，CA3加密
}
//管理员登录平台请求
message AdminLoginReq
{
    int32 user_id = 1;              //目标玩家Id
}
//登录平台应答
message LoginAck
{
    int32 errcode = 1;                      //0成功 1平台服务器不可用 2账号被封禁 3系统繁忙 4系统错误 5系统暂未开放
    int32 user_id = 2;                      //玩家Id
    string nickname = 3;                    //昵称
    bool nickname_mdf = 4;                  //昵称是否修改过
    int32 gender = 5;                       //性别 0保密 1男 2女
    int32 head = 6;                         //头像Id
    int32 head_frame = 7;                   //头像框Id
    int32 level = 8;                        //玩家等级
    int64 level_exp = 9;                    //等级经验
    int32 vip_level = 10;                   //vip等级
    int64 vip_level_exp = 11;               //vip等级经验
    string phone = 12;                      //手机号
    int64 diamond = 13;                     //钻石
    int64 currency = 14;                    //平台货币
    int64 bind_currency = 15;               //绑定货币
    int64 integral = 16;                    //积分
    repeated ItemInfo items = 17;           //物品数组
    fixed32 server_timestamp = 18;          //服务器时间戳
    bool has_unread_mail = 20;              //是否有未读邮件
    int32 guild_id = 21;                    //当前已加入的公会Id
    bool guild_join_list_state = 22;        //是否还有未处理的公会申请
    uint32 month_card_expire_time = 23;     //月卡过期时间戳
    bool month_card_has_fetched = 24;       //月卡当天奖励是否已领取过
    bool finish_first_recharge = 25;        //是否已完成首充礼包
    int32 relief_finish_count = 26;         //当天救济金领取次数
    bool fetched_first_package = 27;        //是否领取了新手起航礼包
    string client_config_md5 = 28;          //最新客户端配置表的md5
    int64 max_gun_value = 29;               //最大解锁炮倍
    string time_string = 30;                //账号解封时间或系统开放时间，空串代表永久
    bool bank_password_flag = 31;           //是否已设置金库密码
    bool is_businessman = 32;               //是否商人
    int32 agent_level = 33;                 //全民代理等级 有些服需要根据代理等级决定是否可以推广
    string continuous_reward = 34;          //持续奖励数组，格式：[购买内容Id,过期时间戳,当日是否已领取1是0否]
    bool rank_reward_gold = 35;             //是否有可领取的金币榜奖励
    bool rank_reward_warhead = 36;          //是否有可领取的弹头榜奖励
    int64 bank_currency = 41;               //银行金币数量
    string last_game_appid = 42;            //最近参与的游戏AppId，用于客户端AccessService的app_id字段
}
//访问游戏服务请求
message AccessServiceReq
{
    string server_name = 1;     //服务名称
    int32 action = 2;           //1加入服务 2离开服务
    string app_id = 3;           //精确指定要加入的服务唯一名称，目前用于客户端加入上次未结束的游戏
}
//访问游戏服务应答
message AccessServiceAck
{
    int32 errcode = 1;              //0成功 1服务不存在 2拒绝访问
    string game_data = 2;           //上次未结束的游戏数据，json格式
}
//心跳包请求，客户端应当每间隔10秒发一个心跳包，证明你还活着
message KeepAliveReq
{
    //nothing
}
//心跳包回应
message KeepAliveAck
{
    int32 errcode = 1;              //0成功
}


]]