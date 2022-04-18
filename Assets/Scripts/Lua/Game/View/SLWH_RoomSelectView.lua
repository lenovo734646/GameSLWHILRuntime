
local Class = class()

function Class.Create(...)
    return Class(...)
end

function Class:__init(allRoomConfig, OnRoomClickCallback)
    local View = GS.GameObject.Find('View')
    self.view = View
    View:GetComponent(typeof(GS.LuaInitHelper)):Init(self)
    
    self.ctrl = GG.FQZS_RoomSelectViewCtrl.Create(self, View, allRoomConfig, OnRoomClickCallback)
end


function Class:Release()

end

return Class