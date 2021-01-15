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


local ChatPanel = require'ChatSystem.ChatPanel'
local ResultPanel = require'UI.ResultPanel'
local UserInfo = require'UI.UserInfo'
local TimerCounterUI = require 'UI.TimerCounterUI'


_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(panel, roomdata, loader)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

    -- 聊天界面
    self.chatPanel = ChatPanel.Create(self.ChatPanel, loader)

    -- 结算界面
    self.resultPanel = ResultPanel.Create(self.resultPanelGameObject)
    -- 玩家信息
    self.userInfo = UserInfo.Create(self.userinfo_luainithelper, roomdata)

    -- 计时器
    self.timeCounter = TimerCounterUI.Create(self.timecounter_luainithelper)

end

function Class:SetWaitNextStateTip(bShow)
    if bShow then
        self.gameStateSpineHelper:PlayByName("dengdai", nil, true)
    else
        self.gameStateSpineHelper:StopByName("dengdai", true)
    end
end



return _ENV