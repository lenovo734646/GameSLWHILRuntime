
local _G, g_Env, print, log, LogW, LogE, os, math = _G, g_Env, print, log, LogW, LogE, os, math
local class, typeof, type, string, utf8, pairs, ipairs= class, typeof, type, string, utf8, pairs, ipairs

local tostring, tonumber = tostring, tonumber
local table = table
local tinsert = table.insert
local tremove = table.remove
local _STR_=_STR_

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local DOTweenAnimation = CS.DG.Tweening.DOTweenAnimation

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'

local PBHelper = require 'protobuffer.PBHelper'
local CLCHATROOMSender = require'protobuffer.CLCHATROOMSender'
local CLSLWHSender = require 'protobuffer.CLSLWHSender'
local SEnv = SEnv
local PlayerListItemData = require'PlayerList.PlayerListItemData'
local PlayerListItemView = require'PlayerList.PlayerListItemView'


_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel)
    self.panel = panel
    local initHelper = panel:GetComponent(typeof(LuaInitHelper))
    initHelper:Init(self)
    self.eventListener:Init(self)
    -- 神算子，大富豪图标
    self.rankImages = {}
    initHelper:ObjectsSetToLuaTable(self.rankImages)
    self.initHelper = nil
    --Item scroll view
    self.playerListScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    -- self.playerListScrollView.OSAScrollView.ChangeItemsCountCallback = function (_, changeMode, changedItemCount)
    --     if changeMode == ItemCountChangeMode.INSERT then    --插入则自动滚动到末尾
    --         local itemsCount = self.playerListScrollView:GetItemsCount()
    --         local tarIndex = itemsCount-1
    --         local DoneFunc = function ()
    --             if itemsCount > 100 then                    -- 只保存100条数据
    --                 self.playerListScrollView:RemoveOneFromStart(true)
    --             end
    --         end
    --         self.playerListScrollView:SmoothScrollTo(tarIndex, 0.1, nil, DoneFunc)
    --     end
    -- end
    --itemRoot : RectTransform类型
    self.playerListScrollView.OnCreateViewItemData = function (itemRoot, itemIndex)
        return PlayerListItemView.Create(itemRoot)
    end

    self.playerListScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        viewItemData:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
    end

    self.playerInfoItemDatas = {}
end
function Class:UpdateOnLineCount(count)
    self.onlineCount.text = string.Format2(_STR_"在线人数：{1}",count)
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
        -- print("查找玩家", user_id, playerInfoItemData.userID)
        if user_id == playerInfoItemData.userID then
            -- print("更新玩家下注:", user_id, totalBets)
            playerInfoItemData.totalBets = totalBets
            tIndex = index
            break
        end
    end
    if tIndex ~= nil then
        -- print("self.playerInfoItemDatas[tIndex].totalBets = ",self.playerInfoItemDatas[tIndex].userID, self.playerInfoItemDatas[tIndex].totalBets)
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
function Class:OnSendPlayerListReq()
    print("发送玩家列表请求")
    CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
        local data = CLSLWHSender.Send_QueryPlayerListReq_Async(0, 100, _G.ShowErrorByHintHandler)
        if data then
            self.playerInfoItemDatas = {}
            local count = data.total_amount
            -- print("在线人数 = ", count)
            local players = data.players
            self.onlineCount.text = string.Format2(_STR_"在线人数：{1}",count)
            for key, info in pairs(players) do
                -- print("玩家列表：", key, info.nickname, info.bets, info.winCount)
                local rankImageSpr = self.rankImages[key]
                local itemData = PlayerListItemData.Create(info.user_id, info.nickname, info.head, info.headFrame, 
                                                            info.currency, info.bets, info.winCount, key, rankImageSpr)
                tinsert(self.playerInfoItemDatas, itemData)
                itemData.rankid = key
            end
            self.playerListScrollView:ReplaceItems(self.playerInfoItemDatas)
        end
    end)
end

function Class:Release()
    self.playerListScrollView.OnCreateViewItemData = nil
    self.playerListScrollView.UpdateViewItemHandler = nil
    self.playerListScrollView:Release()
    self.playerListScrollView = nil
    self.playerInfoItems = nil
end

function Class:OnDestroy()
    print("PlayerListPanel OnDestroy")
    self:Release()
end


return _ENV