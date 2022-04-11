


local Class = class()
function Class.Create(...)
    return Class(...)
end

function Class:__init(userID, userName, headID, headFrameID, gold, totalBets, winCount, rank, rankImageSpr)
    self.userID = userID                -- 玩家ID(用来获取发送消息的用户信息)
    self.userName = userName            -- 名字
    self.headID = headID                -- 头像ID
    self.headFrameID = headFrameID      -- 头像框ID
    self.gold = gold                    -- 金币
    self.totalBets = totalBets or 0     -- 进入游戏以来的总下注
    self.winCount = winCount or 0       -- 进入游戏以来的获胜次数
    self.rank = rank                    -- 排名（按金币）
    self.rankImageSpr = rankImageSpr    -- 排名图片精灵
end

return Class