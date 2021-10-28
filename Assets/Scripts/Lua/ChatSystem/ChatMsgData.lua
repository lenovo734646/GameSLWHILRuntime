

local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

_ENV = {}

local Class = class()
function Create(...)
    return Class(...)
end

function Class:__init(msgType, timestampSec, userID, nickName, isMine, text, audioClip, iconSpr, msgItemBgSpr)
    self.msgType = msgType              -- 消息类型  
    self.timestampSec = timestampSec    -- 时间戳（秒数）
    self.userID = userID                -- 玩家ID(用来获取发送消息的用户信息)
    self.nickName = nickName            -- 玩家昵称
    self.isMine = isMine                -- 是否是自己发的消息（根据UserID判断）
    self.text = text                    -- 聊天内容（文字）
    self.audioClip = audioClip          -- 音频源
    self.iconSpr = iconSpr              -- 头像
    self.msgItemBgSpr = msgItemBgSpr    -- 消息条目背景
    self.IsSendSusseed = false
end
    -- 获取时间戳（时：分：秒）
function Class:GetTimeStamp() 
    return os.date( "%H:%M:%S", self.timestampSec)
end

return _ENV