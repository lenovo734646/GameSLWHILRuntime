
local GS = GS
local GF = GF
local _G = _G
local g_Env, class = g_Env, class
local print, tostring, typeof, debug, LogW, LogE, string, assert
    = print, tostring, typeof, debug, LogW, LogE, string, assert

local xpcall, require, package = xpcall, require, package

local RoomSelectViewCtrl = require'controller.RoomSelectViewCtrl'


_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(allRoomConfig, OnRoomClickCallback)
    local View = GS.GameObject.Find('View')
    self.view = View
    View:GetComponent(typeof(GS.LuaInitHelper)):Init(self)
    
    self.ctrl = RoomSelectViewCtrl.Create(self, View, allRoomConfig, OnRoomClickCallback)
end


function Class:Release()

end

return _ENV