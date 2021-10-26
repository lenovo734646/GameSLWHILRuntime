

local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

_ENV = {}

local Class = class()
function Create(...)
    return Class(...)
end

function Class:__init(userID, userName, headID, headFrameID, gold, recently_setbets, recently_wincount, rank, rankImageSpr)
    self.userID = userID                -- 玩家ID(用来获取发送消息的用户信息)
    self.userName = userName            -- 名字
    self.headID = headID                -- 头像ID
    self.headFrameID = headFrameID      -- 头像框ID
    self.gold = gold                    -- 金币
    self.recently_setbets = recently_setbets            -- 近20局下注
    self.recently_wincount = recently_wincount            -- 近20局获胜次数
    self.rank = rank                    -- 排名（按金币）
    self.rankImageSpr = rankImageSpr    -- 排名图片精灵
end

return _ENV