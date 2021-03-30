

local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

_ENV = {}

local Class = class()
function Create(...)
    return Class(...)
end

function Class:__init(userID, userName, headID, headFrameID, gold, betScore, winCount, rank, rankImageSpr)
    self.userID = userID                -- 玩家ID(用来获取发送消息的用户信息)
    self.userName = userName            -- 名字
    self.headID = headID                -- 头像ID
    self.headFrameID = headFrameID      -- 头像框ID
    self.gold = gold                    -- 金币
    self.betScore = betScore            -- 近20局押分
    self.winCount = winCount            -- 近20局获胜场次
    self.rank = rank                    -- 排名（按金币）
    self.rankImageSpr = rankImageSpr    -- 排名图片精灵
end

return _ENV