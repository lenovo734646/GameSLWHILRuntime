

local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, System, Sprite, AudioClip = UnityEngine, GameObject, System, UnityEngine.Sprite, UnityEngine.AudioClip
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield


_ENV = {}

local Class = class()
function Create(...)
    return Class(...)
end

function Class:__init(timestampSec, userID, isMine, text, audioClip, iconSpr)
    self.timestampSec = timestampSec    -- 时间戳（秒数）
    self.userID = userID                -- 玩家ID(用来获取发送消息的用户信息)
    self.isMine = isMine                -- 是否是自己发的消息（根据UserID判断）
    self.text = text                    -- 聊天内容（文字）
    self.audioClip = audioClip          -- 音频源
    self.iconSpr = iconSpr              -- 头像
end
    -- 获取时间戳（分：秒）
function Class:GetTimeStamp() 
    return os.date( "%M:%S", self.timeStampSec)
end

return _ENV