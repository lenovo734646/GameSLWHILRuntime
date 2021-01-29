
local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs= class, typeof, type, string, utf8, pairs

local tostring, tonumber = tostring, tonumber

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local GraphicRaycaster = UnityEngine.UI.GraphicRaycaster

local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'

local PBHelper = require 'protobuffer.PBHelper'
local CLCHATROOMSender = require'protobuffer.CLCHATROOMSender'
local SubGame_Env = SubGame_Env


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
    self.msgScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.msgScrollView.OSAScrollView.ChangeItemsCountCallback = function (_, changeMode, changedItemCount)
        if changeMode == ItemCountChangeMode.INSERT then    --插入则自动滚动到末尾
            local itemsCount = self.msgScrollView:GetItemsCount()
            local tarIndex = itemsCount-1
            local DoneFunc = function ()
                if itemsCount > 100 then                    -- 只保存100条数据
                    self.msgScrollView:RemoveOneFromStart(true)
                end
            end
            self.msgScrollView:SmoothScrollTo(tarIndex, 0.1, nil, DoneFunc)
        end
    end
    --itemRoot : RectTransform类型
    self.msgScrollView.OnCreateViewItemData = function (itemRoot, itemIndex)
        return ChatMsgView.Create(itemRoot)
    end

    self.msgScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        viewItemData:UpdateFromData(itemdata)
        self.OSAScrollViewCom:ScheduleComputeTwinPass(true)
    end

end

-- 发送 玩家列表请求
function Class:OnSendPlayerListReq()
    print("发送玩家列表请求")
    CLCHATROOMSender.Send_QueryPlayerListReq(function (data)
        print("收到玩家列表返回：", data.errcode)
        if data.errcode == 1 then
            print("你不在房间中")
            return
        end
        --
        local count = data.total_amount
        for i = 1, count, 1 do
            local info = data.players[i]
            print("玩家列表：", info.nickname, info.user_id, info.head)

            -- local msgData = ChatMsgData.Create(timeStampSec, userID, isMine, content, audioClip, headSpr, msgItemBgSpr)
            -- self.msgScrollView:InsertItem(msgData)
        end

     
    end)
end



return _ENV