local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local DOTween = CS.DG.Tweening.DOTween

local tinsert = table.insert
local tremove = table.remove
local tonumber = tonumber

local CoroutineHelper = require'CoroutineHelper'
local yield = coroutine.yield

local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject
local EditorAssetLoader = CS.EditorAssetLoader

local ChatPanel = require'UI.ChatPanel'


_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(panel, loader)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

    -- 聊天界面
    self.chatPanel = ChatPanel.Create(self.ChatPanel, EditorAssetLoader)

end



return _ENV