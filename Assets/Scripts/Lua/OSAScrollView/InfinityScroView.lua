
local GS = GS
local GF = GF
local _G, assert, print, os, math
    = _G, assert, print, os, math
local class, typeof, type, string, utf8
    = class, typeof, type, string, utf8

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
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
        local viewsHolder = GS.ItemViewHolder()
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
-- 获取ViewHolder只能获取到 visible 的，不是随便GetItemCount() 的index 就可以的
-- 最好不要使用这几个函数来获取，而是在UpdateViewHolder 回调中获取，保证显示且能获取到
function Class:GetItemViewsHolderAtStart()
    if self:GetItemsCount() <= 0 then
        return nil
    end
    return self.OSAScrollView:GetItemViewsHolder(0)
end

function Class:GetItemViewsHolderAtEnd()
    if self:GetItemsCount() <= 0 then
        return nil
    end
    local index = self.OSAScrollView.OSAScrollViewCom.VisibleItemsCount - 1-- self:GetItemsCount()-1
    -- print("GetItemViewsHolderAtEnd index = ", index)
    return self.OSAScrollView:GetItemViewsHolder(index)
end

function Class:GetItemViewsHolder(index)
    if self:GetItemsCount() <= 0 or index < 0 or index >= self:GetItemsCount() then
        return nil
    end
    return self.OSAScrollView:GetItemViewsHolder(index)
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
    self.OnCreateViewItemData = nil
    self.UpdateViewItemHandler = nil
    if self.OSAScrollViewCom then
        self.OSAScrollViewCom.UpdateViewsHolderCallback = nil
        self.OSAScrollViewCom.CreateViewsHolderCallback = nil
        self.OSAScrollViewCom = nil
    end
    if self.OSAScrollView then
        self.OSAScrollView:Release()
        self.OSAScrollView = nil
    end
end

return _ENV

