--------------------------------------------------------------------------
--物品构造
local LuaItemInfo = class()

function LuaItemInfo:__init(itemId,itemSubId,itemCount)
    self.ItemID = itemId
    self.ItemSubID = itemSubId
    self.ItemCount = itemCount
end

return LuaItemInfo
