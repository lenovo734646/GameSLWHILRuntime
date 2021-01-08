
local _G, assert, print, log, table, pairs, setmetatable,getmetatable = _G, assert, print, log, table, pairs, setmetatable, getmetatable
local class, typeof, type, string, utf8, logError = class, typeof, type, string, utf8, logError
local next = next



_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(OSAScrollView, keepVelocityOnCountChange)
    self.OSAScrollView = OSAScrollView
    self.itemList = {}
    self.keepVelocityOnCountChange = keepVelocityOnCountChange or true
end

function Class:GetItemData(index)
    return self.itemList[index]
end

function Class:Count()
    return #self.itemList
end

function Class:InsertItems(index, items, freezeEndEdge)
    if next(items) == nil then
        return
    end
    -- models内容插入到datalist中
    for i = 1, #items do    
        assert(items[i])
        table.insert(self.itemList, index, items[i]) -- self.dataList[#self:Count()+1] = models[i]
    end
    return self:Insert(index, #items, freezeEndEdge)
end

function Class:Insert(index, count, freezeEndEdge)
    if freezeEndEdge==nil then
        freezeEndEdge = false
    end
    if(self.OSAScrollView.InsertAtIndexSupported) then
        return self.OSAScrollView:InsertItems(index-1, count, freezeEndEdge, self.keepVelocityOnCountChange)
    else
        return self.OSAScrollView:ResetItems(self:Count(), freezeEndEdge, self.keepVelocityOnCountChange)
    end
end
-- Insert data and items
function Class:InsertItemsAtSatrt(items, freezeEndEdge)
    return self:InsertItems(1, items, freezeEndEdge)
end

function Class:InsertItemsAtEnd(items, freezeEndEdge)
    return self:InsertItems(#self.itemList+1, items, freezeEndEdge)
end

function Class:InsertOne(index, item, freezeEndEdge)
    if item == nil then
        logError("InsertItems models is null index = "..index)
    end
    table.insert(self.itemList, index, item)
    return self:Insert(index, 1, freezeEndEdge)
end

function Class:InsertOneAtStart(model, freezeEndEdge)
    return self:InsertOne(1, model, freezeEndEdge)
end

function Class:InsertOneAtEnd(model, freezeEndEdge)
    return self:InsertOne(#self.itemList+1, model, freezeEndEdge)
end


-- Remove data and items
function Class:RemoveItems(index, count, freezeEndEdge)
    if freezeEndEdge==nil then
        freezeEndEdge = false
    end
    local len = #self.itemList
    if len <= count then
        self.itemList = {}
        count = len
    else
        local i = 0
        while true do
            table.remove(self.itemList, index)
            i = i + 1
            if i == count then
                break
            end
        end
    end
    if self.OSAScrollView.RemoveFromIndexSupported then
       return self.OSAScrollView:RemoveItems(index - 1, count, freezeEndEdge, self.keepVelocityOnCountChange)
    else
       return self.OSAScrollView:ResetItems(len, freezeEndEdge, self.keepVelocityOnCountChange)
    end
end

function Class:RemoveItemsFromStart(count, freezeEndEdge)
    return self:RemoveItems(1, count, freezeEndEdge)
end

function Class:RemoveItemsFromEnd(count, freezeEndEdge)
    local len = #self.itemList
    return self:RemoveItems(len-count, len, freezeEndEdge)
end

function Class:RemoveOne(index, freezeEndEdge)
    local len = #self.itemList
    if len <= 0 or len < index then
        return
    end
    return self:RemoveItems(index, 1, freezeEndEdge)
end

function Class:RemoveOneFromStart(freezeEndEdge)
    return self:RemoveOne(1, freezeEndEdge)
end

function Class:RemoveOneFromEnd(freezeEndEdge)
    return self:RemoveOne(#self.itemList, freezeEndEdge)
end

-- Reset Items 重新设置数据
function Class:ResetItems(itemList, freezeEndEdge)
    if freezeEndEdge==nil then
        freezeEndEdge = false
    end
    self.itemList = itemList
    return self.OSAScrollView:ResetItems(#itemList, freezeEndEdge, self.keepVelocityOnCountChange)
end

-- function Class:ResetItemsByReplacingListInst(itemList, freezeEndEdge)
--     freezeEndEdge = freezeEndEdge or false
--     self.itemList = itemList
--     self.adapter:ResetItems(self:Count(), freezeEndEdge, self.keepVelocityOnCountChange)
-- end

-- 通知list从外部改变了（refreshData）
function Class:NotifyListChangeExternally(freezeEndEdge)
    if freezeEndEdge==nil then
        freezeEndEdge = false
    end
    self.OSAScrollView:ResetItems(self:Count(), freezeEndEdge, self.keepVelocityOnCountChange)
end

return _ENV