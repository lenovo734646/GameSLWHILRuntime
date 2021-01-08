-- Debug模式直接使用“fll3d_support\protobuf\config\CLBCBM.proto”源文件，方便修改，正式发布再同步

return [[
syntax = "proto3";

//客户端和飞禽走兽之间的协议
package CLBCBM;

//登入服务通知
message EnterServerNtf
{
    //nothing
}

//押注信息 STRUCT!!
message BetInfo
{
    int32 animal_id = 1;           //奖项Id
    int64 total_bet = 2;               //筹码Id，注意：筹码Id从0开始！
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
    repeated BetInfo room_tatol_bet_info_list = 6;//房间总下注信息
    repeated int32 histroy_icon_list = 7;  //最近100局开奖纪录数组
    repeated BetInfo self_bet_list = 8;       //我自己已下注数组
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
//自己下注请求
message SetBetReq
{
    int32 animal_id = 1;           //奖项Id
    int32 bet_id = 2;               //筹码Id，注意：筹码Id从0开始！
}
//自己下注回应
message SetBetAck
{
    int32 errcode = 1;              //0成功 1你不在房间中 2阶段不对 3筹码不合法 4押注项不合法 5金币不足 6超过下注最大上限
    BetInfo self_bet_info = 2;      //自己下注信息
    repeated BetInfo room_tatol_bet_info_list = 3;//房间总下注信息
}
message OtherPlayerBetInfo{
    int32 animal_id = 1;
    int64 cur_bet = 2;
}
//其他玩家下注通知
message OtherPlayerSetBetNtf
{
    repeated OtherPlayerBetInfo info_list = 1;     //押注数组
    repeated BetInfo room_tatol_bet_info_list = 2; //房间总下注信息
}

message ResultAnimIndex
{
    int32 from = 1;
    int32 to = 2;
}

//状态通知
message StateChangeNtf
{
    int32 left_time = 1;                            //此状态的剩余时间 2开奖状态时间应该是不固定的
    int32 state = 2;                                //状态 1=下注 2=开奖 3=空闲 
    repeated ResultAnimIndex anim_result_list = 3;       //开奖结果
    repeated int32 histroy_icon_list = 4;           //最近100局开奖纪录数组
}

message HistoryReq
{

}

message HistoryAck 
{
    repeated int32 icon_list = 1;    //历史记录列表
}

message SelfWinResultNtf{
    int64 win = 1;//本局输赢
    int64 tatol_win = 2;//总输赢
}
]]