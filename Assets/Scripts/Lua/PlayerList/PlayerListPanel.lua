
-- 玩家列表界面
local CoroutineMonoBehaviour = nil

local Class = class()

function Class.Create(...)
    return Class(...)
end

function Class:__init(panel, coMonoBehaviour)
    self.panel = panel
    local initHelper = panel:GetComponent(typeof(GS.LuaInitHelper))
    initHelper:Init(self)
    self.eventListener:Init(self)
    CoroutineMonoBehaviour = coMonoBehaviour
    -- 神算子，大富豪图标
    self.rankImages = {}
    initHelper:ObjectsSetToLuaTable(self.rankImages)
    self.initHelper = nil
    --Item scroll view
    self.playerListScrollView = GG.InfinityScroView.Create(self.OSAScrollViewCom)
    --itemRoot : RectTransform类型
    self.playerListScrollView.OnCreateViewItemData = function (itemRoot, itemIndex)
        return GG.PlayerListItemView.Create(itemRoot)
    end

    self.playerListScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        viewItemData:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
    end

    self.playerInfoItemDatas = {}
end
function Class:UpdateOnLineCount(count)
    self.onlineCount.text = GF.string.Format2(_STR_"在线人数：{1}",count)
end

-- 更新玩家列表的胜利次数
function Class:UpdatePlayersWinCount(player_winCount_info_list)
    if #self.playerInfoItemDatas == 0 then
        return
    end
    for key, winCountInfo in pairs(player_winCount_info_list) do
        for _, playerInfoItemData in pairs(self.playerInfoItemDatas) do
            if winCountInfo.user_id == playerInfoItemData.userID then
                playerInfoItemData.winCount = winCountInfo.winCount
            end
        end
    end
    self.playerListScrollView:ReplaceItems(self.playerInfoItemDatas)
end

-- 更新玩家列表的本局下注
function Class:UpdatePlayerTotalBets(user_id, totalBets)
    if #self.playerInfoItemDatas == 0 then
        return
    end
    local tIndex
    for index, playerInfoItemData in ipairs(self.playerInfoItemDatas) do
        -- Log("查找玩家", user_id, playerInfoItemData.userID)
        if user_id == playerInfoItemData.userID then
            -- Log("更新玩家下注:", user_id, totalBets)
            playerInfoItemData.totalBets = totalBets
            tIndex = index
            break
        end
    end
    if tIndex ~= nil then
        -- Log("self.playerInfoItemDatas[tIndex].totalBets = ",self.playerInfoItemDatas[tIndex].userID, self.playerInfoItemDatas[tIndex].totalBets)
        self.playerListScrollView:ReplaceItems(self.playerInfoItemDatas)
    -- else
    --     LogW("未找到玩家:", user_id)
    end
end

function Class:ResetAllPlayerTotalBets()
    if #self.playerInfoItemDatas == 0 then
        return
    end
    for index, playerInfoItemData in ipairs(self.playerInfoItemDatas) do
        playerInfoItemData.totalBets = 0
    end
    self.playerListScrollView:ReplaceItems(self.playerInfoItemDatas)
end


-- 发送 玩家列表请求
function Class:OnSendPlayerListReq(sender)
    Log("发送玩家列表请求")
    GG.CoroutineHelper.StartCoroutineAuto(CoroutineMonoBehaviour,function ()
        local data, err = sender.Send_QueryPlayerListReq_Async(0, 100)
        if err then
            ShowTips(err)
        else
            self.playerInfoItemDatas = {}
            local count = data.total_amount
            -- Log("在线人数 = ", count)
            local players = data.players
            self.onlineCount.text = GF.string.Format2(_STR_"在线人数：{1}",count)
            for key, info in pairs(players) do
                -- Log("玩家列表：", key, info.nickname, info.bets, info.winCount)
                local rankImageSpr = self.rankImages[key]
                local itemData = GG.PlayerListItemData.Create(info.user_id, info.nickname, info.head, info.headFrame, 
                                                            info.currency, info.bets, info.winCount, key, rankImageSpr)
                                                            table.insert(self.playerInfoItemDatas, itemData)
                itemData.rankid = key
            end
            self.playerListScrollView:ReplaceItems(self.playerInfoItemDatas)
        end
    end)
end

function Class:StopAllCoroutines()
    if CoroutineMonoBehaviour then
        GG.CoroutineHelper.StopAllCoroutinesAuto(CoroutineMonoBehaviour)
    end
end

function Class:Release()
    self:StopAllCoroutines()
    if self.playerListScrollView then
        self.playerListScrollView:Release()
        self.playerListScrollView = nil
    end
    self.playerInfoItems = nil
    CoroutineMonoBehaviour = nil
end

function Class:OnDestroy()
    Log("PlayerListPanel OnDestroy")
    self:Release()
end


return Class