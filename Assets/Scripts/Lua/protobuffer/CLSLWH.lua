return [[
syntax = "proto3";

//客户端和森林舞会之间的协议
package CLSLWH;

//登入服务通知
message EnterServerNtf
{
    //nothing
}

//押注信息 STRUCT!!
message BetInfo
{
    int32 index_id = 1;            //下注区域Id(1-15)
    int64 total_bet = 2;            //此项总下注
}
//加入房间请求
message EnterRoomReq
{
}
//加入房间回应
message EnterRoomAck
{
    int32 errcode = 1;                      //0成功 1已经在房间中 2房间人数已满 3系统错误
    repeated int64 bet_config_array = 2;    //筹码配置数组
    int32 state = 3;                        //1押注中 2开奖中
    int32 left_time = 4;                    //当前阶段剩余秒数
    int32 last_bet_id = 5;                  //上次的押注选择
    int32 normal_show_time = 6;                //在不出鲨鱼的情况下，服务器约定的显示结果时间
    int32 shark_more_show_time = 7;            //在出鲨鱼的情况下，服务器约定的显示结果时间
    int64 self_score = 8;                       //玩家当前的分数
    int32 online_player_count = 9;              //在线玩家数量
    repeated BetInfo room_total_bet_info_list = 10;//房间总下注信息
    repeated BetInfo self_bet_info_list = 11;       //我自己已下注数组
    int32 self_user_id = 12;                //self UserID
    string self_user_name = 13;             // 玩家昵称
    int32 self_user_Head = 14;               // 玩家头像
    int32 self_user_HeadFrame = 15;          // 玩家头像框

    int32 last_color_index = 16;            // 上局中奖颜色下标
    int32 last_animal_index = 17;           // 上局中奖动物下标
}
//退出房间请求
message ExitRoomReq
{
    //nothing
}
//退出房间回应
message ExitRoomAck
{
    int32 errcode = 1;              //0成功 1你不在房间中
}

// 请求服务器数据（断线重连用）
message GetServerDataReq
{
}
// 请求服务器数据回应
message GetServerDataAck
{
    int32 errcode = 1;              //0成功
    int32 left_time = 2;            //此状态的剩余时间 2开奖状态时间应该是不固定的
    int32 state = 3;                //游戏状态：1、下注 2、开奖 3、空闲
    repeated int32 color_array = 4;                 // 颜色列表1-24
    repeated int32 ratio_array = 5;                 // 倍率列表1-12动物 13-15庄和闲
    repeated ResultAnimIndex anim_result_list = 7;  //开奖结果列表（RunItem起始点和结束点）
    int32 enjoy_game_ret = 8;                       // 庄闲和开奖结果
    int32 ex_ret = 9;                               // 额外中奖结果（彩金，送灯，闪电翻倍）
    int64 caijin_ratio = 10;                         // 彩金倍数
    int64 shandian_ratio = 11;                        // 闪电翻倍倍数
    int64 self_score = 12;          // 玩家自己的分数
    repeated BetInfo room_total_bet_info_list = 13;  //房间总下注信息
    repeated BetInfo self_bet_info_list = 14;             //我自己已下注数组
    int64 time_stamp = 15;          // 消息时间戳
}

//自己下注请求
message SetBetReq
{
    int32 index_id = 1;             //下注区域Id(1-15)
    int32 bet_id = 2;               //筹码Id，注意：筹码Id从0开始！
}
//自己下注回应
message SetBetAck
{
    int32 errcode = 1;              //0成功 1你不在房间中 2阶段不对 3筹码不合法 4押注项不合法 5金币不足 6超过个人下注最大上限 7超过房间下注最大上限  8庄家不可以下注
    int64 self_score = 2;           //玩家当前的分数
    BetInfo self_bet_info = 3;      //自己下注信息
    string errParam = 4;            // 错误参数：比如下注上限等
    //repeated BetInfo room_total_bet_info_list = 4;//房间总下注信息
}

//
// message OtherPlayerBetInfo
// {
//     int32 animal_id = 1;    // 下注区域
//     int64 cur_bet = 2;      // 筹码下标
// }
//其他玩家下注通知
message OtherPlayerSetBetNtf
{
    int32 user_id = 1; // 本次下注的userID
    BetInfo info = 2; // 本次下注区总押分信息（正常下注使用，一次操作只影响一个下注区）
    repeated BetInfo room_total_bet_info_list = 3; // 所有下注区总下注信息（只有清除下注使用，可能影响多个下注区）
    int64 total_bets = 4; // 本次下注的玩家当前总下注，用来刷新玩家列表信息
}

// 动物倍率信息
message AnimalRatioInfo
{
    int32 color_id  = 1;                // 颜色(1:红 2：绿 3：黄)
    repeated int32 animal_ratio = 3;    // 颜色对应的动物倍率(狮子，熊猫，猴子，兔子)
}

message ResultInfo
{
    int32 winColor = 1;        // 中奖颜色（包含三元四喜）
    int32 winSiXiColor = 2; // 四喜中奖颜色
    int32 winAnimal = 3;       // 中奖动物
}

// 历史记录(目前只有请求历史记录使用到)
message HistoryRecord
{
    ResultInfo ressult_info = 1;            // 中奖结果
    int32 win_enjoyGameType = 2;            // 中奖“庄闲和”
    int32 win_exType = 3;                   // 特殊奖（彩金、送灯、闪电翻倍）
    ResultInfo ressult_info_songdeng = 4;   // 特殊奖送灯中奖结果
    int32 caijin_ratio = 5;                 // 特殊将彩金倍数
    int32 shandian_ratio = 6;               // 特殊奖闪电翻倍倍数
}

// 单次开奖结果
message ResultAnimIndex
{
    int32 color_form = 1;
    int32 color_to = 2;

    int32 animal_form = 3;
    int32 animal_to = 4;

    int32 color_id = 5;       // 中奖颜色ID（红、绿、黄、三元、四喜） 
    int32 animal_id = 6;      // 中奖动物ID
    int32 sixi_color_id = 7;// 四喜的中奖颜色ID
}

//状态通知
message StateChangeNtf
{
    int32 left_time = 1;                            //此状态的剩余时间 2开奖状态时间应该是不固定的
    int32 state = 2;                                //状态 1=下注 2=开奖 3=空闲 
    repeated int32 color_array = 3;                 // 颜色列表1-24
    repeated int32 ratio_array = 4;                 // 倍率列表1-12动物 13-15庄和闲
    repeated ResultAnimIndex anim_result_list = 5;  //开奖结果列表（RunItem起始点和结束点），正常只有一个，如果有送灯会有多个
    int32 enjoy_game_ret = 6;                       // 庄闲和开奖结果
    int32 ex_ret = 7;                               // 额外中奖结果（彩金，送灯，闪电翻倍）
    int32 caijin_ratio = 8;                         // 彩金倍数
    int32 shandian_ratio = 9;                        // 闪电翻倍倍数
    //int64 betMaxLimit = 10;                          // 本局下注最大限制（防止超过庄家分数）
    int64 time_stamp = 10;          // 消息时间戳
}

// 游戏彩金数
message CaiJinNtf
{
    int64 caijin_count = 1;
}

// 请求历史记录
message HistoryReq
{

}

// 请求历史记录返回
message HistoryAck 
{
    int32 errcode = 1;              //0成功
    repeated HistoryRecord record_list = 2;    //历史记录列表
}

// 结算分数
message SelfWinResultNtf
{
    int64 win_score = 1;          //本局输赢
    int64 bet_score = 2;    // 本局下注
    int64 self_score = 3;   // 自己分数
}

// 统计数据
message StatisticDataNtf
{
    int32 SixiCount = 1;    // 四喜中奖次数
    int32 SanYuanCount = 2; // 三元中奖次数
    int32 ZhuangCount = 3;  // 庄中奖次数
    int32 XianCount = 4;    // 闲中奖次数
    int32 HeCount = 5;      // 和中奖次数
    int32 AllGameCount = 6; // 游戏总局数
}

//玩家信息
message PlayerInfo
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 headFrame = 5;            //头像框Id
    int32 vip_level = 6;            //vip等级
    int64 currency = 7;             //金币数量
    int64 bets = 8;                 //从进入游戏起总下注
    int32 winCount = 9;             //从进入游戏起获胜次数
}

// 在线人数变化
message OnlinePlayerCountNtf
{
    int32 online_count = 1;         // 在线人数
}

//玩家信息列表请求
message QueryPlayerListReq
{
    int32 page_index = 1;           //请求第几页？
    int32 page_count = 2;           //每页多少人？
}

//玩家信息列表回应
message QueryPlayerListAck
{
    int32 errcode = 1;                  //0成功 1你不在房间内
    int32 total_amount = 2;             //房间总人数
    repeated PlayerInfo players = 3;    //玩家信息数组
}

// 玩家胜利次数信息
message PlayerWinCountInfo
{
    int32 user_id = 1;              //玩家Id
    int32 winCount = 2;             //从进入游戏起获胜次数
}

// 玩家胜利次数消息
message PlayerWinCountInfoNtf
{
    repeated PlayerWinCountInfo player_winCount_info_list = 1;    //玩家胜利次数信息数组，用来刷新玩家列表信息
}

]]