return [[
syntax = "proto3";

//客户端与聊天室之间的消息
package CLCHATROOM;

//玩家信息
message PlayerInfo
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 vip_level = 5;            //vip等级
    int64 currency = 6;             //金币数量
    int64 bind_currency = 7;        //绑定金币数量
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
    int32 errcode = 1;                  //0成功 1你不在聊天室
    int32 total_amount = 2;             //聊天室总人数
    repeated PlayerInfo players = 3;    //玩家信息数组
}

//查询在线玩家数量请求
message QueryPlayerAmountReq
{
}
message QueryPlayerAmountAck
{
    int32 errcode = 1;                  //0成功 1你不在聊天室
    int32 total_amount = 2;             //聊天室总人数
}

//获取语音上传链接回应
message QueryUploadUrlReq
{
}
//获取语音上传链接回应
message QueryUploadUrlAck
{
    int32 errcode = 1;              //0成功
    string upload_url = 2;          //上传链接
    string download_url = 3;        //上传完成后的下载地址（当上传成功后发送语音消息时需要回传到服务器）
}

//发送文本聊天请求
message SendChatMessageReq
{
    int32 message_type = 1;         //消息类型 1文本消息 2语音消息
    string content = 2;             //消息内容
    string metadata = 3;            //消息内容的元数据（比如语音消息的时长信息）
}
//发送文本聊天回应
message SendChatMessageAck
{
    int32 errcode = 1;              //0成功 1你不在聊天室 2发送内容太长 3不支持的消息类型
}
//文本聊天通知
message ChatMessageNtf
{
    int32 user_id = 1;              //玩家Id
    string nickname = 2;            //昵称
    int32 gender = 3;               //0保密 1男 2女
    int32 head = 4;                 //头像Id
    int32 vip_level = 5;            //vip等级
    int32 message_type = 6;         //消息类型 1文本消息 2语音消息
    string content = 7;             //消息内容
    string metadata = 8;            //消息内容的元数据（比如语音消息的时长信息）
}
]]