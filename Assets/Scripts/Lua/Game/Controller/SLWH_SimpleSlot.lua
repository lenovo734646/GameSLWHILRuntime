
local GS = GS
local GF = GF
local _G = _G
local g_Env, class = g_Env, class
local pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert, tonumber
    = pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert, tonumber

local Image = GS.UnityEngine.UI.Image
local Vector2 = GS.UnityEngine.Vector2
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local yield = coroutine.yield

local InfinityScroView = require 'OSAScrollView.InfinityScroView'

_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(slotPanelInitHelper)
    slotPanelInitHelper:Init(self, false)
    self.sprs = {}
    slotPanelInitHelper:ObjectsSetToLuaTable(self.sprs)
    --
    self.slotScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.slotScrollView:Init()
    self.slotScrollView.OSAScrollView.ChangeItemsCountCallback =
        function(_, changeMode, changedItemCount)
            -- print("简单老虎机：ChangeItemsCountCallback....")
        end

    -- itemRoot : RectTransform类型
    self.slotScrollView.OnCreateViewItemData = function(itemRoot, itemIndex)
        -- print("简单老虎机创建庄闲和：itemIndex = ", itemIndex)
        local viewItemData = {
            image = itemRoot:GetComponent(typeof(Image))
        }
        return viewItemData
    end

    self.slotScrollView.UpdateViewItemHandler = function(itemdata, index, viewItemData)
        -- print("简单老虎机：UpdateViewItemHandler index = ", index)
        viewItemData.image.sprite = itemdata.sprite
        self.updateIndex = index
    end
    local data
    if GS.SysDefines.curLanguage == 'EN' then
        data = {{
            sprite = self.sprs[4]
        }, {
            sprite = self.sprs[5]
        }, {
            sprite = self.sprs[6]
        }}
    else
        data = {{
            sprite = self.sprs[1]
        }, {
            sprite = self.sprs[2]
        }, {
            sprite = self.sprs[3]
        }}
    end

    self.slotScrollView:ReplaceItems(data)

    -- 惯性（0-1）
    self.OSAScrollViewCom.BaseParameters.effects.InertiaDecelerationRate = 0.865
    self.OSAScrollViewCom.Velocity = Vector2(0, 0)
    -- 转动力度：正数为从下向上转，负数为从上向下转
    self.Volicity = Vector2(0, -1500)
end

function Class:Run111(ret, time)
    -- print("简单老虎机开始 ret = ", ret)
    ret = ret - 1
    CoroutineHelper.StartCoroutine(function()
        self.OSAScrollViewCom.Velocity = self.Volicity
        while true do
            if self.OSAScrollViewCom.Velocity.y > -100 then
                if (self.updateIndex - 1) == ret then
                    self.slotScrollView:SmoothScrollTo(ret, 1.5, nil, nil)
                    -- print("老虎机结束....")
                    break
                else
                    self.OSAScrollViewCom.Velocity = Vector2(0, -100)
                end
            else
                yield()
            end

        end
    end)
end

return _ENV
