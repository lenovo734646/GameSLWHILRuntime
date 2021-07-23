return [[
syntax = "proto3";

//客户端和平台服务器之间的协议
package CLPF;

//登出请求
message LogoutReq
{
    //nothing
}
message LogoutAck
{
    int32 errcode = 1;              //0成功
}
//资源同步通知
message ResSyncNtf
{
    int64 diamond = 1;              //钻石数量
    int64 currency = 2;             //金币数量
    int64 integral = 3;             //积分数量
}

//资源变化通知
message ResChangedNtf
{
    int32 res_type = 1;             //资源类型 1钻石 2金币 3绑定金币 4积分 5魔力值 6银行金币
    int64 res_value = 2;            //资源值
    int64 res_delta = 3;            //资源变化量
    int64 res_id = 4;               //此次资源变化id，从客户端登录开始从0开始累加
}
//物品信息结构 STRUCT!!
message ItemInfo
{
    int32 item_id = 1;              //物品主类型
    int32 item_sub_id = 2;          //物品子类型
    int64 item_count = 3;           //物品数量
}
//获取物品列表请求
message ItemGetListReq
{
    //nothing
}
//获取物品列表回应
message ItemGetListAck
{
    repeated ItemInfo items = 1;    //物品数组
}
//使用物品请求
message ItemUseReq
{
    ItemInfo item = 1;              //物品信息
    string server_name = 2;         //服务名称
    bool auto_buy = 3;              //物品不足是否自动购买
}
//使用物品回应
message ItemUseAck
{
    int32 errcode = 1;              //0成功 1数量不足 2配置表错误 3使用失败 4鱼潮即将来临禁止使用 5狂暴下不能使用瞄准 6分身下不能使用瞄准 7vip等级不足
}
//物品数量变化通知
message ItemCountChangeNtf
{
    repeated ItemInfo items = 1;    //物品数组
}
//物品购买请求
message ItemBuyReq
{
    ItemInfo item = 1;              //购买的物品
}
//物品购买回应
message ItemBuyAck
{
    int32 errcode = 1;              //0购买成功 1购买数量非法 2物品不存在 3该道具不卖 4资源不足 5vip等级不足
    ItemInfo item = 2;              //获得的物品，仅用于显示
}
//商城购买次数信息 STRUCT!!
message ShopBuyCountItem
{
    int32 shop_id = 1;              //商城购买项Id
    int32 buy_count = 2;            //购买次数
}
//通用充值请求
message RechargeReq
{
    int32 content_type = 1;         //购买内容类型 1商城充值 2购买月卡 3首充礼包 4每日充值 5投资炮倍 6出海保险 7持续奖励礼包 8充值升级炮倍
    int32 content_id = 2;           //购买内容Id
    int32 pay_mode = 3;             //支付渠道 1支付宝 2微信 3银行卡 4云闪付 5代理充值
    string extra_data = 4;          //支付附加数据，根据不同支付渠道进行区分
}
//通用充值回应
message RechargeAck
{
    int32 errcode = 1;              //0成功 1无此购买项 2不支持的支付渠道 3购买次数已达上限 4vip等级不足 5系统错误 6资源不足
    string errmessage = 3;          //支付失败时的错误信息
    string pay_envir = 2;           //支付环境，json格式字符串
}
//充值到账通知
message RechargeSuccessNtf
{
    int32 content_type = 1;         //购买内容类型 1商城充值 2购买月卡 3首充礼包 4每日充值 5投资炮倍 6出海保险 7持续奖励礼包 8充值升级炮倍
    int32 content_id = 2;           //购买内容Id
    repeated ItemInfo items = 3;    //获得物品数组
}
//查询充值订单请求
message RechargeOrder
{
    string order_no = 1;            //订单编号
    int32 order_type = 2;           //1支付宝 2微信 3银行卡 4云闪付 5代理充值
    int32 order_amount = 3;         //订单金额，单位分
    int32 content_type = 4;         //购买内容类型
    int32 content_id = 5;           //购买内容Id
    int32 order_state = 6;          //支付状态 0未支付 1真支付到账 2假支付到账
    uint32 create_time = 7;         //订单创建时间戳
    uint32 finish_time = 8;         //订单完成时间戳
    int32 evaluate_star = 9;        //0代表未评价 1-5代表几颗星
}
message RechargeOrderQueryListReq
{
}
message RechargeOrderQueryListAck
{
    int32 errcode = 1;              //0成功
    repeated RechargeOrder orders = 2;//订单列表
}
//订单评价请求
message RechargeOrderEvaluateReq
{
    string order_no = 1;            //订单编号
    int32 star = 2;                 //1-5颗星
    string content = 3;             //评价文本
}
message RechargeOrderEvaluateAck
{
    int32 errcode = 1;              //0成功 1参数错误 2该订单不存在或已评价
}
//排行榜玩家信息 STRUCT!!
message RankPlayerInfo
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //性别 0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 head_frame = 5;           //头像框Id
    int32 level = 6;                //玩家等级
    int32 vip_level = 7;            //玩家vip等级
    int64 rank_value = 8;           //平台货币
}
//获取排行榜请求
message GetRankListReq
{
    int32 rank_type = 1;            //排行榜类型 1金币榜 2弹头榜
}
//获取排行榜回应
message GetRankListAck
{
    int32 errcode = 1;                      //0成功 1系统错误 2暂未开放
    repeated RankPlayerInfo rank_rows = 2;  //排行榜数据数组
    int32 my_lastday_rank = 3;              //从0开始，0代表第一名，-1代表未上榜
    bool fetched_lastday_reward = 4;        //是否已领取了昨日排行榜奖励
}
//玩家经验变化通知
message LevelExpChangedNtf
{
    int64 level_exp = 1;            //玩家等级经验
}
//玩家升级通知
message LevelUpNtf
{
    int32 level = 1;                    //玩家等级
    repeated ItemInfo reward_array = 2; //升级奖励物品数组
}
//Vip经验等级发生变化
message VipExpChangedNtf
{
    int32 vip_level = 1;            //玩家vip等级
    int64 vip_level_exp = 2;        //玩家vip等级经验
}
//修改昵称请求
message ModifyNicknameReq
{
    string new_nickname = 1;        //新的昵称
}
//修改昵称回应
message ModifyNicknameAck
{
    int32 errcode = 1;              //0成功 1格式不合法 2包含敏感字符 3昵称已存在 4钻石不足
}
//修改头像请求
message ModifyHeadReq
{
    int32 new_head = 1;             //新的头像Id
    int32 new_head_frame = 2;       //新的头像框Id
}
//修改头像回应
message ModifyHeadAck
{
    int32 errcode = 1;              //0成功
}
//查询签到请求
message QuerySignReq
{
    //nothing
}
//查询签到回应
message QuerySignAck
{
    int32 signed_count = 1;         //当月已签次数
    int32 today_signed = 2;         //当天是否已签
    int32 total_days = 3;           //当月总天数
}
//执行签到请求
message ActSignReq
{
    //nothing
}
//执行签到回应
message ActSignAck
{
    int32 errcode = 1;              //0成功 1重复签到 2配置表错误
    repeated ItemInfo items = 2;    //物品数组
}
//查询vip抽奖请求
message QueryVipWheelReq
{
    //nothing
}
//查询vip抽奖回应
message QueryVipWheelAck
{
    int32 used_count = 1;           //当天已抽奖次数
    int32 total_count = 2;          //可抽奖总次数
}
//执行vip抽奖请求
message ActVipWheelReq
{
    //nothing
}
//执行vip抽奖回应
message ActVipWheelAck
{
    int32 errcode = 1;              //0成功 1抽奖次数不足 2金币不足 3配置表错误
    int32 reward_id = 2;            //随机到的结果奖项Id
    repeated ItemInfo items = 3;    //物品数组
}
//邮件信息结构 STRUCT!!
message MailInfo
{
    int32 id = 1;                   //邮件唯一Id
    int32 type = 2;                 //邮件类型 1系统邮件 2好友赠送邮件
    string title = 3;               //邮件标题
    string content = 4;             //邮件内容
    repeated ItemInfo items = 5;    //附件物品数组
    int32 state = 6;                //邮件状态 1未读 2已读 3已领取
    int32 receive_time = 7;         //邮件接收时间戳
    int32 expire_time = 8;          //邮件过期时间戳
}
//所有邮件Id请求
message MailQueryAllIdsReq
{
    //nothing
}
//所有邮件Id回应
message MailQueryAllIdsAck
{
    repeated int32 array = 1;       //邮件Id数组
}
//批量邮件内容请求
message MailBatchQueryContentReq
{
    repeated int32 array = 1;       //邮件Id数组长度
    string language = 2;            //期望显示哪种语言？'CN'为中文
}
//批量邮件内容回应
message MailBatchQueryContentAck
{
    repeated int32 invalid_array = 1;   //无效Id数组
    repeated MailInfo result_array = 2; //结果邮件数组
}
//查看邮件请求
message MailAccessReq
{
    int32 mail_id = 1;              //邮件唯一Id
}
//查看邮件回应
message MailAccessAck
{
    bool has_unread_mail = 1;       //是否还有未读邮件
}
//领取邮件物品请求
message MailFetchItemReq
{
    int32 mail_id = 1;              //邮件唯一Id
}
//领取邮件物品回应
message MailFetchItemAck
{
    int32 errcode = 1;              //0成功 1邮件不存在 2邮件已被领取过
    repeated ItemInfo items = 2;    //获得的物品数组
    bool has_unread_mail = 3;       //是否还有未读邮件
}
//删除邮件请求
message MailRemoveReq
{
    int32 remove_type = 1;          //删除类型 1删除指定邮件 2删除已读且无可领取附件的邮件 3清空所有邮件
    repeated int32 remove_ids = 2;  //需要删除的邮件Id数组
}
//删除邮件回应
message MailRemoveAck
{
    int32 errcode = 1;              //0成功 1包含错误的邮件Id
    bool has_unread_mail = 2;       //是否还有未读邮件
    repeated int32 removed_ids = 3; //已删除的邮件Id数组
}
//邮件到来通知
message MailArriveNtf
{
    MailInfo mail_info = 1;         //邮件信息
}
//公会信息结构 STRUCT!!
message GuildInfo
{
    int32 id = 1;                   //公会Id
    string name = 2;                //公会名称
    string desc = 3;                //公会宣言
    int32 icon = 4;                 //公会徽章
    int32 level = 5;                //公会等级
    int32 user_level_limit = 6;     //入会玩家等级限制
    int32 vip_level_limit = 7;      //入会贵族等级限制
    bool allow_auto_join = 8;       //是否允许自动加入
    int32 member_count = 9;         //公会当前成员数量
    int32 member_limit = 10;        //公会最大成员限制
    int32 president_id = 11;        //会长Id
    string president_name = 12;     //会长昵称
}
//请求加入公会的信息结构 STRUCT!!
message GuildJoinItem
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //性别 0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 head_frame = 5;           //头像框Id
    int32 level = 6;                //玩家等级
    int32 vip_level = 7;            //玩家vip等级
    int32 request_time = 8;         //申请加入的时间戳
}
//公会成员信息结构 STRUCT!!
message GuildMember
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //性别 0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 head_frame = 5;           //头像框Id
    int32 level = 6;                //玩家等级
    int32 vip_level = 7;            //玩家vip等级
    int32 job = 8;                  //1会长 2管理员 3会员
    bool is_online = 9;             //是否在线
    int32 last_login_time = 10;     //最近登录时间戳
    int64 contribute = 11;          //昨日贡献总金币数量
}
//公会红包成员信息结构 STRUCT!!
message GuildRedpacketMember
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //性别 0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 head_frame = 5;           //头像框Id
    int32 level = 6;                //玩家等级
    int32 vip_level = 7;            //玩家vip等级
    int32 job = 8;                  //1会长 2管理员 3会员
    bool is_online = 9;             //是否在线
    int32 grab_count = 10;          //今日领取红包次数
    int64 total_grab_result = 11;   //今日共计抢到的金币数量
}
//公会仓库物品信息 STRUCT!!
message GuildBagItem
{
    int32 item_id = 1;              //物品Id
    int32 item_sub_id = 2;          //物品子Id
    int64 item_count = 3;           //物品数量
}
//公会仓库日志信息 STRUCT!!
message GuildBagLog
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //玩家昵称
    int32 type = 3;                 //1存入 2取出
    int32 item_id = 4;              //物品Id
    int32 item_sub_id = 5;          //物品子Id
    int64 item_count = 6;           //物品数量
    int32 timestamp = 7;            //时间戳
}
//创建公会请求
message GuildCreateReq
{
    string name = 1;                //公会名称
    int32 icon = 2;                 //公会徽章
    int32 user_level_limit = 3;     //入会玩家等级限制
    int32 vip_level_limit = 4;      //入会贵族等级限制
    bool allow_auto_join = 5;       //是否允许自动加入
}
//创建公会回应
message GuildCreateAck
{
    int32 errcode = 1;              //0成功 1已有公会 2公会名称非法 3公会名字已存在 4等级不足 5贵族等级不足 6钻石不足 7公会名称过短 8公会名称过长
    GuildInfo info = 2;             //公会信息
}
//获取公会推荐列表请求
message GuildQueryRecommendListReq
{
    //nothing
}
//获取公会推荐列表回应
message GuildQueryRecommendListAck
{
    repeated GuildInfo array = 1;           //推荐列表数组
    repeated int32 join_flags_array = 2;    //申请加入标记数组
}
//搜索公会请求
message GuildSearchReq
{
    int32 guild_id = 1;             //公会Id
}
//搜索公会回应
message GuildSearchAck
{
    int32 errcode = 1;              //0成功 1公会不存在
    GuildInfo info = 2;             //公会详细信息
    int32 join_flag = 3;            //申请加入标记
}
//快速加入公会请求
message GuildQuickJoinReq
{
    //nothing
}
//快速加入公会回应
message GuildQuickJoinAck
{
    int32 errcode = 1;              //0成功 1已有公会 2当天退出过公会无法加入 3当日申请次数已达上限 4无满足条件的公会
    GuildInfo info = 2;             //公会详细信息
}
//加入公会请求
message GuildJoinReq
{
    int32 guild_id = 1;             //申请加入的公会Id
}
//加入公会回应
message GuildJoinAck
{
    int32 errcode = 1;              //0申请成功 1已有公会 2公会不存在 3等级不满足 4贵族等级不满足 5公会成员已满 6重复申请 7当日主动退出不允许加入 8当日申请次数已达上限
}
//获取公会申请列表请求
message GuildQueryJoinListReq
{
    //nothing
}
//获取公会申请列表回应
message GuildQueryJoinListAck
{
    int32 errcode = 1;                      //0成功 1没有公会 2权限不足
    repeated GuildJoinItem item_array = 2;  //加入请求数组
}
//处理公会加入请求
message GuildHandleJoinReq
{
    int32 user_id = 1;              //玩家Id
    bool agree = 2;                 //是否同意加入
}
//处理公会加入回应
message GuildHandleJoinAck
{
    int32 errcode = 1;              //0操作成功 1你没有公会 2权限不足 3找不到该申请纪录 4玩家等级不足 5玩家贵族等级不足 6公会成员已满 7玩家已加入其它公会
    GuildMember new_member = 2;     //新加入的成员信息，只有当同意加入并操作成功时该字段才有意义
}
//加入公会应答通知
message GuildJoinResponseNtf
{
    int32 guild_id = 1;             //公会Id
    string guild_name = 2;          //公会名称
    int32 user_id = 3;              //操作员玩家Id
    string nickname = 4;            //操作员玩家昵称
    bool agree = 5;                 //是否同意加入公会
}
//新的申请加入公会的通知
message GuildNewJoinRequestNtf
{
    int32 user_id = 1;              //申请人玩家Id
    string nickname = 2;            //申请人玩家昵称
}
//获取公会信息请求
message GuildQueryInfoReq
{
    //nothing
}
//获取公会信息回应
message GuildQueryInfoAck
{
    int32 errcode = 1;                      //0成功 1你没有公会
    GuildInfo info = 2;                     //公会详细信息
    repeated GuildMember members_array = 3; //公会成员数组
    int32 job = 4;                          //你的职务
}
//修改公会信息请求
message GuildModifyInfoReq
{
    string name = 1;                //公会名称
    string desc = 2;                //公会宣言
    int32 icon = 3;                 //公会徽章
    int32 user_level_limit = 4;     //入会玩家等级限制
    int32 vip_level_limit = 5;      //入会贵族等级限制
    bool allow_auto_join = 6;       //是否允许自动加入
}
//修改公会信息回应
message GuildModifyInfoAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2权限不足 3公会名称已存在 4钻石不足 5修改次数已达上限 6公会名称不合法 7公会名称过短 8公会名称过长
}
//修改成员职务请求
message GuildModifyMemberJobReq
{
    int32 user_id = 1;              //玩家Id
    int32 job = 2;                  //2管理员 3普通成员
}
//修改成员职务回应
message GuildModifyMemberJobAck
{
    int32 errcode = 1;              //0成功 1你不是会长 2非法操作
}
//踢出成员请求
message GuildKickMemberReq
{
    repeated int32 id_array = 1;    //踢出的成员数组
}
//踢出成员回应
message GuildKickMemberAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2权限不足 3非法操作
}
//被踢出通知
message GuildKickMemberNtf
{
    int32 user_id = 1;              //操作者玩家Id
    string nickname = 2;            //操作者玩家昵称
    int32 job = 3;                  //操作者职务 1会长 2管理员
}
//自己退出公会请求
message GuildExitReq
{
    //nothing
}
//自己退出公会回应
message GuildExitAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2会长需先设置管理员才能退出
}
//公会升级请求
message GuildUpgradeReq
{
    //nothing
}
//公会升级回应
message GuildUpgradeAck
{
    int32 errcode = 1;              //0成功 1你不是会长 2钻石不足 3已满级
    int32 guild_level = 2;          //升级后的公会等级
    int32 guild_max_members = 3;    //升级后公会最大成员数量
}
//查询会长福利请求
message GuildQueryWelfareReq
{
    //nothing
}
//查询会长福利回应
message GuildQueryWelfareAck
{
    int32 errcode = 1;              //0成功 1你不是会长
    int64 contribute = 2;           //当前实时额度
    int64 welfare = 3;              //福利金币总数量
    int32 is_fetched = 4;           //0未领取 1已领取过
}
//领取会长福利请求
message GuildFetchWelfareReq
{
    //nothing
}
//领取会长福利回应
message GuildFetchWelfareAck
{
    int32 errcode = 1;              //0成功 1你不是会长 2已领取过
    int64 welfare = 2;              //获得了多少金币
}
//获取公会红包信息请求
message GuildQueryRedPacketInfoReq
{
    //nothing
}
//获取公会红包信息回应
message GuildQueryRedPacketInfoAck
{
    int32 errcode = 1;              //0成功 1你没有公会
    int64 today_pool = 2;           //今日累积奖池
    int64 past_pool = 3;            //昨日累积奖池
    int64 today_give_out = 4;       //今日已派发金币数
    int32 left_packet_count = 5;    //剩余红包个数
    int32 total_packet_count = 6;   //红包总数
    int32 donate_num = 7;           //今日奖金鱼捐献次数
    int32 grabed_count = 8;         //今日已抢红包次数
    int32 left_grab_count = 9;      //剩余可抢红包次数
}
//获取公会红包排行榜请求
message GuildQueryRedPacketRankReq
{
    //nothing
}
//获取公会红包排行榜回应
message GuildQueryRedPacketRankAck
{
    int32 errcode = 1;                              //0成功 1你没有公会
    repeated GuildRedpacketMember rank_array = 2;   //排行榜成员数组
}
//公会抢红包请求
message GuildActRedPacketReq
{
    //nothing
}
//公会抢红包回应
message GuildActRedPacketAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2次数不足 3奖池太小还不能领取红包
    int64 grab_result = 2;          //获得的金币数量
}
//获取公会仓库信息请求
message GuildBagQueryInfoReq
{
    //nothing
}
//获取公会仓库信息回应
message GuildBagQueryInfoAck
{
    int32 errcode = 1;                      //0成功 1你没有公会
    repeated GuildBagItem item_array = 2;   //仓库物品数组
    repeated GuildBagLog log_array = 3;     //仓库日志数组
}
//获取公会仓库日志请求
message GuildBagQueryLogReq
{
    int32 page_index = 1;           //每页数量100，请求第几页？
}
//获取公会仓库日志回应
message GuildBagQueryLogAck
{
    int32 errcode = 1;                  //0成功 1你没有公会
    repeated GuildBagLog log_array = 2; //仓库日志数组
}
//公会仓库存入物品请求
message GuildBagStoreItemReq
{
    ItemInfo item = 1;              //存入的物品
}
//公会仓库存入物品回应
message GuildBagStoreItemAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2不能存入该物品 3vip等级不足 4物品不足 5当日存储数量超过限制
    GuildBagLog bag_log = 2;        //当前存入仓库动作所对应的日志
}
//公会仓库取出物品请求
message GuildBagFetchItemReq
{
    ItemInfo item = 1;              //取出的物品
    int32 user_id = 2;              //物品分配给谁？
}
//公会仓库取出物品回应
message GuildBagFetchItemAck
{
    int32 errcode = 1;              //0成功 1你不是会长 2玩家不在公会中 3物品数量不足 4当日对方接收数量超过限制
    GuildBagLog bag_log = 2;        //当前取出仓库动作所对应的日志
}
//公会领取仓库物品通知
message GuildBagFetchItemNtf
{
    ItemInfo item = 1;              //领取的物品，仅用于显示
}
//消息广播通知
message MessageBroadcastNtf
{
    /*
        1击杀得金币:[昵称,vip等级,鱼名称,炮倍,获得金币]
        2击杀得弹头:[昵称,vip等级,鱼名称,物品名称,弹头数量]
        3抽奖得弹头:[昵称,vip等级,物品名称,弹头数量]
        4击杀得奖券:[昵称,vip等级,鱼名称,奖券数量]
        5抽奖得奖券:[昵称,vip等级,奖券数量]
        6击杀世界boss:[昵称,vip等级,世界boss名称,获得金币]
        7水浒传得金币:[昵称,vip等级,单线押注金币,命中倍数,获得金币]
        8水浒传小玛丽:[昵称,vip等级,单线押注金币,获得小玛丽次数]
        9拉霸机得金币:[昵称,vip等级,单线押注金币,命中倍数,获得金币]
        10拉霸机中宝箱:[昵称,vip等级,单线押注金币,宝箱奖励金币]
        11获得实物奖励:[昵称,vip等级,获得渠道名称,实物物品名称]
        12后台轮播消息:[消息唯一Id,创建时间戳,持续总时间(0代表永久),轮播时间间隔单位秒,轮播内容字符串]
        13取消轮播消息:[消息唯一Id]
    */
    int32 type = 1;                 //消息类型，详细分类请查阅协议配置xml文件中的注释。
    string content = 2;             //json格式数组，数组中的字段内容根据type而不同
}
//完成任务信息 STRUCT!!
message TaskInfo
{
    int32 task_id = 1;              //任务Id
    int64 achieve_num = 2;          //达成数量
}
//查询任务请求
message TaskQueryReq
{
    //nothing
}
//查询任务回应
message TaskQueryAck
{
    repeated TaskInfo task_info_array = 1;      //任务信息数组
    repeated int32 finish_task_id_array = 2;    //已完成（并领取奖励）的任务Id数组
    int32 daily_active_value = 3;               //当前日活跃值
    int32 weekly_active_value = 4;              //当前周活跃值
    repeated int32 finish_active_id_array = 5;  //已领取奖励的活跃值Id数组
}
//领取任务奖励请求
message TaskFetchTaskRewardsReq
{
    int32 task_id = 1;              //任务Id
}
//领取任务奖励回应
message TaskFetchTaskRewardsAck
{
    int32 errcode = 1;              //0成功 1任务不存在 2任务目标未达成 3任务奖励已领取
    repeated ItemInfo items = 2;    //物品数组
}
//领取活跃度奖励请求
message TaskFetchActiveRewardsReq
{
    int32 active_id = 1;            //活跃度奖励Id
}
//领取活跃度奖励回应
message TaskFetchActiveRewardsAck
{
    int32 errcode = 1;              //0成功 1不存在 2目标未达成 3已领取
    repeated ItemInfo items = 2;    //物品数组
}
//完成的成就任务数据 STRUCT!!
message TaskAchieveData
{
    int32 kind = 1;                 //1累计登录 2捕鱼能手 3倍率大人 4竞技高手 5捕鱼累计获得金币
    int64 count = 2;                //累计完成数量
}
//成就任务重置数据 STRUCT!!
message TaskAchieveResetData
{
    int32 kind = 1;                 //1累计登录 2捕鱼能手 3倍率大人 4竞技高手 5捕鱼累计获得金币
    int32 left_days = 2;            //剩余天数
}
//获取成就任务信息请求
message TaskAchieveQueryInfoReq
{
    //nothing
}
//获取成就任务信息回应
message TaskAchieveQueryInfoAck
{
    repeated TaskAchieveData data_array = 1;            //任务数据数组
    repeated int32 finish_id_array = 2;                 //完成的任务Id数组
    repeated TaskAchieveResetData reset_data_array = 3; //成就任务重置数组
}
//领取成就任务奖励请求
message TaskAchieveFetchRewardReq
{
    int32 task_achieve_id = 1;      //成就任务Id
}
//领取成就任务奖励回应
message TaskAchieveFetchRewardAck
{
    int32 errcode = 1;              //0成功 1任务不存在 2任务未达成 3奖励已领取
    repeated ItemInfo items = 2;    //物品数组
}
//领取月卡奖励请求
message MonthCardFetchRewardReq
{
    //nothing
}
//领取月卡奖励回应
message MonthCardFetchRewardAck
{
    int32 errcode = 1;              //0成功 1请先购买月卡 2当日已领取 3领取次数不足
    repeated ItemInfo items = 2;    //物品数组
}
//领取救济金请求
message ReliefGoldFetchReq
{
    //nothing
}
//领取救济金回应
message ReliefGoldFetchAck
{
    int32 errcode = 1;              //0成功 1当前金币不为零 2领取次数已达上限 3你的金库中还有金币不能领取救济金
    int64 currency_delta = 2;       //领取到的救济金数量，仅用于显示
}
//摇数字获取信息请求
message ShakeNumberQueryInfoReq
{
    //nothing
}
//摇数字获取信息回应
message ShakeNumberQueryInfoAck
{
    repeated int32 shake_number_array = 1;  //已经摇到的数字数组，该数字由两部分组成：个位表示当天摇到的数字，十位为0表示当天尚未领取宝箱奖励，十位为1表示当天已领取宝箱奖励
    bool shake_number_act_flag = 2;         //当天是否已摇过数字
    bool shake_number_fetched = 3;          //本轮是否已领取过奖励
}
//摇数字请求
message ShakeNumberActReq
{
    //nothing
}
//摇数字回应
message ShakeNumberActAck
{
    int32 errcode = 1;              //0成功 1今天已经摇过 2有奖励尚未领取
    int32 number = 2;               //摇到的数字：0~9
}
//领取摇到的金币奖励请求
message ShakeNumberFetchRewardReq
{
    //nothing
}
//领取摇到的金币奖励回应
message ShakeNumberFetchRewardAck
{
    int32 errcode = 1;              //0成功 1条件未达成 2已领取过
    int64 currency_delta = 2;       //领取到的7日摇数字奖励金币数量，仅用于显示
}
//领取摇到数字后的宝箱礼包请求
message ShakeNumberFetchBoxRewardReq
{
    int32 day = 1;                  //第几天的宝箱？范围：0-6
}
//领取摇到数字后的宝箱礼包回应
message ShakeNumberFetchBoxRewardAck
{
    int32 errcode = 1;              //0成功 1参数非法 2当天还未摇数字 3已领取过
    repeated ItemInfo items = 2;    //物品数组，仅用于显示
}
//查询每日充值请求
message RechargeDailyQueryReq
{
    //nothing
}
//查询每日充值回应
message RechargeDailyQueryAck
{
    repeated int32 finished_id_array = 1;   //已完成的每日充值id数组
}
//福利猪获取信息请求
message WelfarePigQueryInfoReq
{
    //nothing
}
//福利猪获取信息回应
message WelfarePigQueryInfoAck
{
    int32 welfare = 1;              //累积的总福利值
    int32 expire_time = 2;          //总福利过期时间戳
    bool is_fetched = 3;            //今日是否已领取锤子碎片
    bool is_broken = 4;             //今日是否已砸过罐子
}
//福利猪领取每日锤子碎片请求
message WelfarePigFetchMaterialReq
{
    //nothing
}
//福利猪领取每日锤子碎片回应
message WelfarePigFetchMaterialAck
{
    int32 errcode = 1;              //0成功 1当日已领取
    ItemInfo item = 2;              //领取到的物品信息
}
//福利猪砸罐子请求
message WelfarePigBrokenReq
{
    //nothing
}
//福利猪砸罐子回应
message WelfarePigBrokenAck
{
    int32 errcode = 1;              //0成功 1当日已砸过 2罐子中金币数量太少 3锤子碎片不足
    int64 currency_delta = 2;       //获得的金币数量，仅用于显示
}
//福利猪搜一搜请求
message WelfarePigSearchReq
{
    //nothing
}
//福利猪搜一搜回应
message WelfarePigSearchAck
{
    int32 errcode = 1;              //0搜索成功 1阶段不对 2很遗憾啥也没搜到
    int64 currency_delta = 2;       //搜索到的罐子里砸开后获得的金币数量，仅用于显示
}
//查询投资炮倍信息请求
message InvestGunQueryInfoReq
{
    //nothing
}
//查询投资炮倍信息回应
message InvestGunQueryInfoAck
{
    int32 max_recharge_id = 1;          //已完成的最大投资充值Id，关联InvestGunRecharge.xlsx表主键
    int32 max_gun_value = 2;            //已解锁的最大炮值
    repeated int32 finished_array = 3;  //已领取的解锁炮倍数组，对应InvestGunReward.xlsx表主键
}
//领取投资炮倍奖励请求
message InvestGunFetchRewardReq
{
    int32 gun_value = 1;            //领取奖励的解锁炮倍
}
//领取投资炮倍奖励回应
message InvestGunFetchRewardAck
{
    int32 errcode = 1;              //0成功 1无此项 2炮值解锁条件不足 3充值条件不足 4奖励已领取
    repeated ItemInfo items = 2;    //物品数组，仅用于显示
}
//查询出海保险信息请求
message InvestCostQueryInfoReq
{
    //nothing
}
//查询出海保险信息回应
message InvestCostQueryInfoAck
{
    bool is_recharged = 1;              //是否已完成充值
    int64 total_currency_cost = 2;      //累计金币总消耗
    repeated int32 finished_array = 3;  //已领取的奖励Id数组，对应InvestCostReward.xlsx表主键
}
//领取出海保险奖励请求
message InvestCostFetchRewardReq
{
    int32 reward_id = 1;            //奖励Id
}
//领取出海保险奖励回应
message InvestCostFetchRewardAck
{
    int32 errcode = 1;              //0成功 1无此项 2累计金币消耗不足 3尚未充值 4奖励已领取
    repeated ItemInfo items = 2;    //物品数组，仅用于显示
}
//领取新手初始礼包请求
message FirstPackageFetchReq
{
    //nothing
}
//领取新手初始礼包回应
message FirstPackageFetchAck
{
    int32 errcode = 1;              //0成功 1已领取
    repeated ItemInfo items = 2;    //物品数组，仅用于显示
}
//公告变动通知
message AnnouncementChangedNtf
{
    int32 content_type = 1;         //0公告变动 1客服信息变动
}
//vip金币补足通知
message VipFillUpCurrencyNtf
{
    int64 currency_delta = 1;       //补足的金币数量，仅用于显示
}
//实物奖励兑换日志 STRUCT!!
message RealGoodsExchangeLog
{
    int32 goods_id = 1;             //商品Id
    string goods_name = 2;          //商品名称
    string real_name = 3;           //真实姓名
    string phone = 4;               //联系电话
    string address = 5;             //联系地址
    int32 state = 6;                //订单状态 0未发货 1已发货 2拒绝发货
    int32 create_time = 7;          //创建订单时间戳
    int32 process_time = 8;         //处理订单时间戳
}
//查询常用的真实地址请求
message RealGoodsQueryAddressReq
{
    //nothing
}
//查询常用的真实地址回应
message RealGoodsQueryAddressAck
{
    int32 errcode = 1;              //0成功 1不存在
    string real_name = 2;           //真实姓名
    string phone = 3;               //联系电话
    string address = 4;             //联系地址
}
//实物奖励下单请求
message RealGoodsCreateOrderReq
{
    int32 goods_id = 1;             //实物商品Id
    string real_name = 2;           //真实姓名
    string phone = 3;               //联系电话
    string address = 4;             //联系地址
}
//实物奖励下单回应
message RealGoodsCreateOrderAck
{
    int32 errcode = 1;              //0成功 1信息填写不完整 2商品不存在 3vip等级不足 4购买次数已达上限 5资源不足
}
//查询实物奖励兑换纪录请求
message RealGoodsQueryExchangeLogReq
{
    //nothing
}
//查询实物奖励兑换纪录回应
message RealGoodsQueryExchangeLogAck
{
    repeated RealGoodsExchangeLog log_array = 1;    //日志数组
}
//查询已完成的新手引导标记数组请求
message GuideDataQueryReq
{
    //nothing
}
//查询已完成的新手引导标记数组回应
message GuideDataQueryAck
{
    repeated int32 flag_array = 1;  //已完成的新手引导标记数组
}
//上报完成了某个新手引导标记
message GuideDataActRpt
{
    int32 flag = 1;                 //新手引导完成标记
}
//客户端配置表发布通知
message ClientConfigPublishNtf
{
    string md5 = 1;                 //最新配置表的md5，里面出现的字母大写
}
//子游戏在线人数信息 STRUCT!!
message SubGamesOnlineCountInfo
{
    string service_name = 1;        //玩法Id
    int32 online_count = 2;         //在线人数
}
//子游戏在线人数请求
message SubGamesOnlineCountReq
{
    //nothing
}
//子游戏在线人数回应
message SubGamesOnlineCountAck
{
    repeated SubGamesOnlineCountInfo array = 1; //在线人数数组
}
//激活码领取奖励请求
message CdkeyFetchRewardReq
{
    string code = 1;                //激活码
}
//激活码领取奖励回应
message CdkeyFetchRewardAck
{
    int32 errcode = 1;              //0成功 1兑换码不存在 2兑换码已被领取 3同一类型的兑换码礼包每个玩家只能领取一次
    repeated ItemInfo items = 2;    //物品数组，仅用于显示
}
//账号绑定状态请求
message AccountBindStateReq
{
    //nothing
}
//账号绑定状态回应
message AccountBindStateAck
{
    int32 errcode = 1;                  //0成功
    repeated int32 bind_type_array = 2; //绑定数组 1游客2手机号3QQ4微信5Facebook6GooglePlay7GameCenter
}
//账号手机绑定请求
message AccountPhoneBindReq
{
    string phone = 1;               //手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    string password = 5;            //登录密码，使用CA3加密，固定秘钥19357
    int32 sms_channel = 6;          //0Mob渠道 1其他渠道
}
//账号手机绑定回应
message AccountPhoneBindAck
{
    int32 errcode = 1;              //0成功 1该账号已经绑定过手机号 2密码不合法 3输入的手机号码已绑定其他账号 4短信验证失败
}
//账号手机更换请求1
message AccountPhoneChange1Req
{
    string phone = 1;               //手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    int32 sms_channel = 5;          //0Mob渠道 1其他渠道
}
//账号手机更换回应1
message AccountPhoneChange1Ack
{
    int32 errcode = 1;              //0成功 1请先绑定手机号 2手机号与预留的不一致 3短信验证失败
}
//账号手机更换请求2
message AccountPhoneChange2Req
{
    string new_phone = 1;           //新手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    int32 sms_channel = 5;          //0Mob渠道 1其他渠道
}
//账号手机更换回应2
message AccountPhoneChange2Ack
{
    int32 errcode = 1;              //0成功 1状态不对 2原手机号和新手机号不能一致 3新手机号码已绑定其他账号 4短信验证失败
}
//账号统一绑定请求
message AccountUniformBindReq
{
    string phone = 1;               //手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    int32 type = 5;                 //绑定类型 1设备 3QQ 4微信 5Facebook 6GooglePlay 7GameCenter
    string token = 6;               //唯一标识串，使用CA3加密，固定秘钥：19357
    int32 sms_channel = 7;          //0Mob渠道 1其他渠道
}
//账号统一绑定回应
message AccountUniformBindAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2手机号与预留的不一致 3绑定类型非法 4token非法 5已绑定该类型，请先解绑 6已关联其他账号 7短信验证失败
}
//账号统一解绑请求
message AccountUniformUnbindReq
{
    string phone = 1;               //手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    int32 type = 5;                 //绑定类型 1设备 3QQ 4微信 5Facebook 6GooglePlay 7GameCenter
    int32 sms_channel = 6;          //0Mob渠道 1其他渠道
}
//账号统一解绑回应
message AccountUniformUnbindAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2手机号与预留的不一致 3解绑类型非法 4还未绑定该类型 5短信验证失败
}
//查询玩家昵称请求
message PlayerNicknameQueryReq
{
    int32 user_id = 1;              //玩家Id
}
//查询玩家昵称回应
message PlayerNicknameQueryAck
{
    int32 errcode = 1;              //0成功 1玩家不存在
    string nickname = 2;            //昵称
}
//金库密码初始化请求 注意：该请求成功后，不用再进行密码验证功能了，可以直接进入金库界面
message BankPasswordInitReq
{
    string password = 1;            //金库初始密码，使用CA3加密，固定秘钥：19357
}
//金库密码初始化回应
message BankPasswordInitAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2已设置过初始密码 3密码不合法
}
//金库密码验证请求
message BankPasswordVerifyReq
{
    string password = 1;            //金库密码，使用CA3加密，固定秘钥：19357
}
//金库密码验证回应
message BankPasswordVerifyAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2您还没设置过银行密码 3银行密码验证失败
}
//金库密码修改请求
message BankPasswordModifyReq
{
    string origin_password = 1;     //原密码，使用CA3加密，固定秘钥：19357
    string new_password = 2;        //新密码，使用CA3加密，固定秘钥：19357
}
//金库密码修改回应
message BankPasswordModifyAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2请先设置密码 3原密码不正确 4新密码不合法
}
//金库密码重置请求 注意：该请求成功后，不用再进行密码验证功能了，可以直接进入金库界面
message BankPasswordResetReq
{
    string phone = 1;               //手机号码
    string sms_app_key = 2;         //短信验证的AppKey
    string sms_zone = 3;            //短信验证的区号
    string sms_code = 4;            //短信验证码
    string new_password = 5;        //新密码，使用CA3加密，固定秘钥：19357
    int32 sms_channel = 6;          //0Mob渠道 1其他渠道
}
//金库密码重置回应
message BankPasswordResetAck
{
    int32 errcode = 1;              //0成功 1请先绑定手机 2手机号与预留的不一致 3还未设置过密码 4新密码不合法 5短信验证失败
}
//金库物品查询请求
message BankItemQueryReq
{
    //nothing
}
//金库物品查询回应
message BankItemQueryAck
{
    int32 errcode = 1;              //0成功 1权限不足
    repeated ItemInfo items = 2;    //物品数组
}
//金库物品存入请求
message BankItemStoreReq
{
    ItemInfo item = 1;              //要存入的物品
}
//金库物品存入回应
message BankItemStoreAck
{
    int32 errcode = 1;              //0成功 1权限不足 2参数无效 3资源数量不足 4您正在游戏中无法存入
}
//金库物品取出请求
message BankItemFetchReq
{
    ItemInfo item = 1;              //要取出的物品
}
//金库物品取出回应
message BankItemFetchAck
{
    int32 errcode = 1;              //0成功 1权限不足 2参数无效 3资源数量不足
}
//金库物品赠送请求
message BankItemSendReq
{
    int32 user_id = 1;              //玩家Id
    ItemInfo item = 2;              //要赠送的物品
}
//金库物品赠送回应
message BankItemSendAck
{
    int32 errcode = 1;              //0成功 1权限不足 2参数无效 3资源数量不足 4目标玩家不存在 5对方等级不足 6赠送的资源数量太少 7该物品不允许赠送 8您尚未达成赠送条件，请先充值 9目标玩家已达到接收最大上限 10vip等级不足，赠送数量超过限制 11权限不足，仅允许赠送给推广上下级关系的玩家
}
//金库物品日志信息 STRUCT!!
message BankItemLogInfo
{
    int32 log_type = 1;             //1存入 2取出 3赠送 4接收
    ItemInfo item = 2;              //物品信息
    int32 refer_user_id = 3;        //关联的玩家Id
    string refer_nickname = 4;      //关联的玩家昵称
    int32 timestamp = 5;            //时间戳
    int32 unique_id = 6;            //唯一Id
}
//金库物品日志查询请求
message BankItemLogQueryReq
{
    //nothing
}
//金库物品日志查询回应
message BankItemLogQueryAck
{
    int32 errcode = 1;                      //0成功 1权限不足
    repeated BankItemLogInfo log_array = 2; //日志数组
}
//金库物品详细日志查询请求
message BankItemLogDetailQueryReq
{
    int32 log_type = 1;             //日志类型 0全部 1存入 2取出 3赠送 4接收
    int32 query_type = 2;           //查询类型 1查询大于指定Id的纪录 2查询小于指定Id的纪录
    int32 refer_unique_id = 3;      //指定纪录Id
    int32 order_type = 4;           //排序类型 1升序 2降序
    int32 count = 5;                //请求数量，最大100条
}
//金库物品详细日志查询回应
message BankItemLogDetailQueryAck
{
    int32 errcode = 1;                      //0成功 1权限不足 2日志类型错误 3查询类型错误 4排序类型参数错误 5查询数量参数错误
    repeated BankItemLogInfo log_array = 2; //日志数组
}
//领取N天持续奖励请求
message ContinuousRewardFetchReq
{
    int32 content_id = 1;           //购买内容Id
}
//领取N天持续奖励回应
message ContinuousRewardFetchAck
{
    int32 errcode = 1;              //0成功 1充值购买后才能领取 2当日已领取 3领取次数不足 4参数错误
    repeated ItemInfo items = 2;    //物品数组
}
//上次未结束的游戏查询请求
message LastGameQueryReq
{
    //nothing
}
//上次未结束的游戏查询回应
message LastGameQueryAck
{
    int32 errcode = 1;              //0成功 1不存在未结束的游戏
    string server_name = 2;         //服务名称
    string app_id = 3;              //所在服务器唯一Id
}
//领取排行榜奖励请求
message RankRewardFetchReq
{
    int32 rank_type = 1;            //1金币榜 2弹头榜
}
//领取排行榜奖励回应
message RankRewardFetchAck
{
    int32 errcode = 1;              //0成功 1你昨日未上榜，不能领取奖励 2排行榜奖励你已领取过了 3领取排行榜奖励参数错误
    repeated ItemInfo items = 2;    //物品数组
}
//银行卡信息 STRUCT!!
message CashOutBankCard
{
    string bank_card_id = 1;        //银行卡号
    string bank_name = 2;           //银行名称
    string real_name = 3;           //真实姓名
}
//绑定银行卡请求
message CashOutBindBankCardReq
{
    CashOutBankCard bank_card = 1;  //银行卡信息
}
//绑定银行卡回应
message CashOutBindBankCardAck
{
    int32 errcode = 1;              //0成功 1参数错误
}
//查询绑定的银行卡请求
message CashOutQueryBankCardReq
{
    //nothing
}
//查询绑定的银行卡回应
message CashOutQueryBankCardAck
{
    int32 errcode = 1;              //0成功 1尚未绑定银行卡
    CashOutBankCard bank_card = 2;  //银行卡信息
}
//申请提现请求
message CashOutCreateOrderReq
{
    int64 item_count = 1;           //提现消耗的道具数量
    string phone = 2;               //手机号
}
//申请提现回应
message CashOutCreateOrderAck
{
    int32 errcode = 1;              //0成功 1该服不允许提现 2参数错误 3尚未绑定银行卡 4资源不足
}
//提现日志 STRUCT!!
message CashOutLog
{
    int64 item_count = 1;           //提现消耗的道具数量
    CashOutBankCard bank_card = 2;  //银行卡信息
    string phone = 3;               //手机号
    int32 state = 4;                //订单状态 0待处理 1已处理 2拒绝处理
    int32 create_time = 5;          //创建订单时间戳
    int32 process_time = 6;         //处理订单时间戳
}
//查询提现记录请求
message CashOutLogQueryReq
{
    //nothing
}
//查询提现记录回应
message CashOutLogQueryAck
{
    repeated CashOutLog log_array = 1;  //日志数组
}
//斗地主比赛即将开始通知
message DdzMatchStartingNtf
{
    int32 config_id = 1;            //比赛场配置Id
    int32 left_time = 2;            //剩余时间，单位秒
}
//弹头兑换魔力值请求
message MagicTradeInReq
{
    ItemInfo item = 1;              //物品信息
    int64 factor = 2;               //魔力值系数
}
//弹头兑换魔力值回应
message MagicTradeInAck
{
    int32 errcode = 1;              //0成功 1当前魔力值不为零，无法变更兑换系数 2当前魔力值不为0，无法变更兑换物品 3物品数量不足
    int64 latest_magic_value = 2;   //最新的魔力值，该字段仅当兑换成功时才有意义
}
//魔力值兑换弹头请求
message MagicTradeOutReq
{
    int64 item_count = 1;           //物品数量
}
//魔力值兑换弹头回应
message MagicTradeOutAck
{
    int32 errcode = 1;              //0成功 1参数错误 2魔力值不足
    int64 latest_magic_value = 2;   //最新的魔力值，该字段仅当兑换成功时才有意义
}
//弹头交换请求
message WarheadExchangeReq
{
    ItemInfo item = 1;              //需要消耗的物品信息
    int32 action = 2;               //1兑换 2拆解
}
//弹头交换回应
message WarheadExchangeAck
{
    int32 errcode = 1;              //0成功 1参数错误 2功能暂未开放 3兑换或拆解比例系数配置错误 4物品数量不足
    ItemInfo item = 2;              //获得的新物品
}
//获取头像地址请求
message HeadUrlQueryReq
{
    int32 head_id = 1;              //头像Id
}
//获取自定义头像回应
message HeadUrlQueryAck
{
    int32 errcode = 1;              //0成功 1自定义头像不存在
    string url = 2;                 //头像的url地址
}
//修改性别请求
message ModifyGenderReq
{
    int32 new_gender = 1;           //0保密 1男 2女
}
//修改性别回应
message ModifyGenderAck
{
    int32 errcode = 1;              //0成功
}
//公会红包数据 STRUCT!!
message GuildPacketData
{
    int64 total_amount = 1;         //红包总额
    int32 total_count = 2;          //红包总数量
    int32 duration = 3;             //持续时间，单位秒
    int32 create_time = 4;          //创建时间
    int64 left_amount = 5;          //剩余额度
    int32 left_count = 6;           //剩余个数
}
//获取公会红包信息2请求
message GuildQueryRedPacketInfo2Req
{
    //nothing
}
//获取公会红包信息2回应
message GuildQueryRedPacketInfo2Ack
{
    int32 errcode = 1;                  //0成功 1你没有公会
    int64 quota = 2;                    //红包总额度
    bool has_packet = 3;                //当前是否存在红包
    int32 has_fetched = 4;              //当前红包你是否领取过
    GuildPacketData packet_data = 5;    //红包数据
}
//公会发红包请求
message GuildRedPacket2CreateReq
{
    int64 total_amount = 1;         //红包总额
    int32 total_count = 2;          //红包总数量
    int32 duration = 3;             //持续时间，单位秒
}
//公会发红包回应
message GuildRedPacket2CreateAck
{
    int32 errcode = 1;              //0成功 1你不是会长 2当前红包未过期 3额度不足 4参数非法
}
//公会抢红包请求
message GuildRedPacket2GrabReq
{
    //nothing
}
//公会抢红包回应
message GuildRedPacket2GrabAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2没有可领取的红包 3你今天已领取过 4红包已被抢光
    int64 grab_result = 2;          //获得的金币数量
}
//获取公会成员信息请求
message GuildQueryMembersReq
{
    int32 page_index = 1;           //第几页？0代表第一页
}
//获取公会成员信息回应
message GuildQueryMembersAck
{
    int32 errcode = 1;                      //0成功 1你没有公会
    int32 total_count = 2;                  //成员总数量
    repeated GuildMember members_array = 3; //公会成员数组
}
//公会玩家信息查询请求
message GuildMemberQueryReq
{
    int32 user_id = 1;              //玩家id
}
//公会玩家信息查询回应
message GuildMemberQueryAck
{
    int32 errcode = 1;              //0成功 1你没有公会 2玩家不存在
    GuildMember member_info = 2;    //公会成员信息
}
//会长ID搜索公会请求
message GuildSearch2Req
{
    int32 president_id = 1;         //会长Id
}
//会长ID搜索公会回应
message GuildSearch2Ack
{
    int32 errcode = 1;              //0成功 1公会不存在
    GuildInfo info = 2;             //公会详细信息
    int32 join_flag = 3;            //申请加入标记
}
//发送邮件请求
message MailSendReq
{
    int32 receiver_id = 1;          //收件人Id, 1代表客服
    string title = 2;               //邮件标题
    string content = 3;             //邮件内容
}
//发送邮件回应
message MailSendAck
{
    int32 errcode = 1;              //0成功 1收件人Id不存在
}

//周签到查询请求
message WeekSignStateQueryReq
{
}
message WeekSignStateQueryAck
{
    int32 errcode = 1;              //0成功
    bool today_signed = 2;          //今天是否已签到
    int32 signed_count = 3;         //已连续签到天数
}
//执行周签到请求
message WeekSignActReq
{
}
message WeekSignActAck
{
    int32 errcode = 1;              //0成功 1你今天已签到过 2系统错误，请先调用查询签到接口 3配置错误，无法获取对应的签到奖励
    int32 signed_count = 2;         //连续签到天数
    ItemInfo item = 3;              //获得的签到奖励物品
}

//反馈状态查询状态
message FeedbackStateQueryReq
{
}
message FeedbackStateQueryAck
{
    int32 errcode = 1;              //0成功
    int32 unread_count = 2;         //未读数量
    int32 total_count = 3;          //反馈总条数
}
//反馈提交请求
message FeedbackSubmitReq
{
    string content = 1;             //提交内容，内容长度不能超过4k字节
}
message FeedbackSubmitAck
{
    int32 errcode = 1;              //0成功 1内容不合法
    int32 id = 2;                   //唯一Id
    uint32 timestamp = 3;           //提交时间戳
}
//反馈列表查询请求
message FeedbackItem
{
    int32 id = 1;                   //唯一Id
    string submit_content = 2;      //提交内容
    uint32 submit_time = 3;         //提交时间戳
    int32 state = 4;                //1未回复 2未读已回复 3已读已回复
    string reply_content = 5;       //回复内容
    uint32 reply_time = 6;          //回复时间戳
}
message FeedbackListQueryReq
{
    int32 page_index = 1;           //请求第几页？从0开始
    int32 page_count = 2;           //每页多少条记录？
}
message FeedbackListQueryAck
{
    int32 errcode = 1;              //0成功
    repeated FeedbackItem items = 2; //反馈列表
}
//反馈设置为已读请求
message FeedbackReadReq
{
    int32 id = 1;                   //唯一Id
}
message FeedbackReadAck
{
    int32 errcode = 1;              //0成功 1无效的参数id
}
//反馈处理通知
message FeedbackReplyNtf
{
    FeedbackItem item = 1;          //反馈信息
}
//添加行为日志
message AddOperationLogRpt
{
    string operation_id = 1;        //操作行为
    string param1 = 2;              //参数1
    string param2 = 3;              //参数2
    string param3 = 4;              //参数3
    string param4 = 5;              //参数4
}

//代理投诉请求
message RechargeAgentComplainReq
{
    string agent_info = 1;          //代理信息
    string content = 2;             //投诉内容
}
message RechargeAgentComplainAck
{
    int32 errcode = 1;              //0成功 1代理信息不能为空 2代理信息文本内容太长 3投诉内容太少 4投诉文本内容太长
}

]]