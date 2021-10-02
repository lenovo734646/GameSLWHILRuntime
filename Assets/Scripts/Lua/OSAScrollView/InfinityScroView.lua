
local _G, assert, print, log, logError, os, math = _G, assert, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject = UnityEngine, GameObject
local EditorAssetLoader = CS.EditorAssetLoader
local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield

local OSA = CS.OSAHelper
local ContentGravity = OSA.ContentGravity
local OSAItemViewHolder = OSA.ItemViewHolder
local OSAScrollView = require 'OSAScrollView.OSAScrollView'
local ScrollItemViewDataHelper = require 'OSAScrollView.ScrollItemViewDataHelper'

local table = table
local pairs = pairs

_ENV = {}


local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(OSAScrollViewCom)
    assert(OSAScrollViewCom)
    self.OSAScrollViewCom = OSAScrollViewCom
    self.OSAScrollView = OSAScrollView.Create(OSAScrollViewCom)
    self:Init()
    self.viewDataHelper = ScrollItemViewDataHelper.Create(OSAScrollViewCom)

    OSAScrollViewCom.UpdateViewsHolderCallback = function (paramters_)
        local viewsHolder = paramters_[1]
        local index = viewsHolder.ItemIndex+1
        local scrollViewItemData = self.viewDataHelper:GetItemData(index)
        local holderdata = viewsHolder.bindData
        if self.UpdateViewItemHandler then
            return self.UpdateViewItemHandler(scrollViewItemData,index,holderdata)
        end
    end

    self.vhList = {}

    OSAScrollViewCom.CreateViewsHolderCallback = function (paramters_)
        local itemIndex = paramters_[1]
        local osaParam = OSAScrollViewCom.Parameters
        local viewsHolder = OSAItemViewHolder()
        viewsHolder.CollectViewsCallback = function ()
            if self.OnCreateViewItemData then
                viewsHolder.bindData = self.OnCreateViewItemData(viewsHolder.root,itemIndex)
            end
        end
        table.insert(self.vhList, viewsHolder)
        viewsHolder:Init(osaParam.ItemPrefab, osaParam.Content, itemIndex)

        return viewsHolder
    end
end

function Class:Init()
    self.OSAScrollView:Init()
end

function Class:SmoothScrollTo(index, duration, progressFunc, onDoneFunc)
    if index < 0 or index +1 > self.OSAScrollView:GetItemsCount() then
        return
    end
    local dur = duration
    if dur < 0.01 then
        dur = 0.01
    end
    if dur > 9 then
        dur = 9
    end
    --
    return self.OSAScrollView:SmoothScrollTo(index, dur, 0.1, 0.1, progressFunc, onDoneFunc, true)
end

function Class:SmoothScrollToEnd(dur)
    dur = dur or 0.2
    self:SmoothScrollTo(self.OSAScrollView:GetItemsCount()-1, dur)
end

function Class:SmoothScrollToStart(dur)
    dur = dur or 0.2
    self:SmoothScrollTo(0, dur)
end

function Class:InsertItemAuto(index)
    if self.dataBuilder then
        local item = self.dataBuilder()
        if index then
            return self.viewDataHelper:InsertOne(index, item, self.freezeEndEdge)
        else
            return self.viewDataHelper:InsertOneAtEnd(item,self.freezeEndEdge)
        end
    end
end

function Class:InsertItem(item,index,freezeEndEdge)
    if index then
        return self.viewDataHelper:InsertOne(index, item, freezeEndEdge)
    else
        return self.viewDataHelper:InsertOneAtEnd(item,freezeEndEdge)
    end
end

function Class:InsertItemAtStart(item)
    return self.viewDataHelper:InsertOneAtStart(item,self.freezeEndEdge)
end

function Class:InsertItems(items,index)
    return self.viewDataHelper:InsertItems(index, items, self.freezeEndEdge)
end

function Class:RemoveItem(index)
    return self.viewDataHelper:RemoveOne(index,self.freezeEndEdge)
end

function Class:RemoveItems(index,count)
    return self.viewDataHelper:RemoveItems(index, count, self.freezeEndEdge)
end

function Class:RemoveOneFromStart(freezeEndEdge)
    return self.viewDataHelper:RemoveItems(1, 1, freezeEndEdge)
end

function Class:GetItemsCount()
    return self.OSAScrollView:GetItemsCount()
end

function Class:ReplaceItems(items, freezeEndEdge)
    return self.viewDataHelper:ResetItems(items, freezeEndEdge)
end
-- 刷新 
function Class:Refresh()
    self.OSAScrollView.OSAScrollViewCom:Refresh()
end

function Class:Release()
    -- local vhCount = self.OSAScrollViewCom.VisibleItemsCount
    -- print("vhCount = ", vhCount)
    -- for i = 0, vhCount-1, 1 do
    --     local vh = self.OSAScrollView:GetItemViewsHolder(i)
    --     if vh then
    --         vh.CollectViewsCallback = nil
    --     end
    -- end
    for key, vh in pairs(self.vhList) do
        vh.CollectViewsCallback = nil
    end
    
    self.OSAScrollViewCom.UpdateViewsHolderCallback = nil
    self.OSAScrollViewCom.CreateViewsHolderCallback = nil
    self.OSAScrollView:Release()
    self.OSAScrollView = nil
    self.OSAScrollViewCom = nil
end

return _ENV

