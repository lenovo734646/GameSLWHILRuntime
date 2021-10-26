
local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs= class, typeof, type, string, utf8, pairs

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
end


-- 发送 玩家列表请求
function Class:OnSendPlayerListReq()
    print("发送玩家列表请求")
    CoroutineHelper.StartCoroutineAuto(SEnv.CoroutineMonoBehaviour,function ()
        local data = CLCHATROOMSender.Send_QueryPlayerListReq_Async(0, 100, _G.ShowErrorByHintHandler)
        if data then
            local items = {}
            local count = data.total_amount
            print("count = ", count)
            local players = data.players
            self.onlineCount.text = string.Format2(_STR_"在线人数：{1}",count)
            for key, info in pairs(players) do
                print("玩家列表：", key, info.nickname, info.recently_setbets, info.recently_wincount)
                local rankImageSpr = self.rankImages[key]
                local itemData = PlayerListItemData.Create(info.user_id, info.nickname, info.head, info.headFrame, 
                                                            info.currency, info.recently_setbets, info.recently_wincount, key, rankImageSpr)
                tinsert(items, itemData)
                itemData.rankid = key
            end
            self.playerListScrollView:ReplaceItems(items)
        end
    end)
end

function Class:Release()
    self.playerListScrollView.OnCreateViewItemData = nil
    self.playerListScrollView.UpdateViewItemHandler = nil
    self.playerListScrollView:Release()
    self.playerListScrollView = nil
end

function Class:OnDestroy()

end


return _ENV