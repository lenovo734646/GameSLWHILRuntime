
local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs= class, typeof, type, string, utf8, pairs

local tostring, tonumber = tostring, tonumber
local table = table
local tinsert = table.insert
local tremove = table.remove

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local DOTweenAnimation = CS.DG.Tweening.DOTweenAnimation

local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'

local PBHelper = require 'protobuffer.PBHelper'
local CLCHATROOMSender = require'protobuffer.CLCHATROOMSender'
local SubGame_Env = SubGame_Env
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

    -- -- onComplete回调 playForward finish 调用
    -- self.popUpDOTweenAnim.onComplete:AddListener(function ()
    --     print("OnComplete......")
    --     if self.panel.transform.localScale.x < 0.1 then
    --         self.panel:SetActive(false)
    --     end
    -- end)
    -- self.popUpDOTweenAnim.hasOnComplete = true;
end


-- 发送 玩家列表请求
function Class:OnSendPlayerListReq()
    print("发送玩家列表请求")
    CoroutineHelper.StartCoroutineAuto(self.eventListener,function ()
        local data = CLCHATROOMSender.Send_QueryPlayerListReq_Async(0, 100,
        SubGame_Env.ShowErrorByHint)
        --
        local items = {}
        local count = data.total_amount
        print("count = ", count)
        local players = data.players
        self.onlineCount.text = "在线人数："..count
        for key, info in pairs(players) do
            print("玩家列表：", key, info.nickname, info.user_id, info.head)
            local rankImageSpr = self.rankImages[key]
            local itemData = PlayerListItemData.Create(info.user_id, info.nickname, info.head, info.headFrame, 
                                                        info.currency, info.betScore, info.winCount, key, rankImageSpr)
            tinsert(items, itemData)
        end
        self.playerListScrollView:ReplaceItems(items)
    end)
end




return _ENV