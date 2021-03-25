


local _G, g_Env, print, log, LogE, os, math = _G, g_Env, print, log, LogE, os, math
local class, typeof, type, string, utf8, pairs= class, typeof, type, string, utf8, pairs

local tostring, tonumber = tostring, tonumber

local UnityEngine, GameObject, TextAsset, Sprite, Input, KeyCode = UnityEngine, GameObject, UnityEngine.TextAsset, UnityEngine.Sprite, UnityEngine.Input, UnityEngine.KeyCode
local Image = UnityEngine.UI.Image
local Vector2 = UnityEngine.Vector2
local CoroutineHelper = require'CoroutineHelper'
local yield = coroutine.yield

local ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local SubGame_Env = SubGame_Env

_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(slotPanelInitHelper)
    slotPanelInitHelper:Init(self)
    self.sprs = {}
    slotPanelInitHelper:ObjectsSetToLuaTable(self.sprs)
    --
    self.slotScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.slotScrollView:Init()
    self.slotScrollView.OSAScrollView.ChangeItemsCountCallback = function (_, changeMode, changedItemCount)
        print("简单老虎机：ChangeItemsCountCallback....")
    end

    --itemRoot : RectTransform类型
    self.slotScrollView.OnCreateViewItemData = function (itemRoot, itemIndex)
        print("简单老虎机创建庄闲和：itemIndex = ", itemIndex)
        local viewItemData = {
            image = itemRoot:GetComponent(typeof(Image))
        }
        return viewItemData
    end

    self.slotScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        print("简单老虎机：UpdateViewItemHandler index = ", index)
        viewItemData.image.sprite = itemdata.sprite
        self.updateIndex = index
    end

    --
    local data = {
        {sprite = self.sprs[1]},
        {sprite = self.sprs[2]},
        {sprite = self.sprs[3]},
    }
    self.slotScrollView:ReplaceItems(data)
    -- self.slotScrollView:InsertItem({sprite = self.sprs[1]})
    -- self.slotScrollView:InsertItem({sprite = self.sprs[2]})
    -- self.slotScrollView:InsertItem({sprite = self.sprs[3]})

    -- 惯性（0-1）
    self.OSAScrollViewCom.BaseParameters.effects.InertiaDecelerationRate = 0.865
    self.OSAScrollViewCom.Velocity = 0
    -- 转动力度：正数为从下向上转，负数为从上向下转
    self.Volicity = Vector2(0, -2000)
end


function Class:Run111(ret, time)
    print("简单老虎机开始 ret = ", ret)
    ret = ret -1
    CoroutineHelper.StartCoroutine(function ()
        self.OSAScrollViewCom.Velocity = self.Volicity
        while true do
            if self.OSAScrollViewCom.Velocity.y > -50 then
                 if (self.updateIndex -1) == ret then
                    self.slotScrollView:SmoothScrollTo(ret, 1.5, nil, nil)
                    print("老虎机结束....")
                    break
                 else
                    self.OSAScrollViewCom.Velocity = Vector2(0, -50)
                 end
            else
                yield()
            end

        end

        
        -- while self.OSAScrollViewCom.Velocity.y > -200 do
        --     print("Velocity.y = ", self.OSAScrollViewCom.Velocity.y)
        --     self.slotScrollView:SmoothScrollTo(ret, 0.1, nil, nil)
        --     break
        -- end
    end)
    
end







return _ENV