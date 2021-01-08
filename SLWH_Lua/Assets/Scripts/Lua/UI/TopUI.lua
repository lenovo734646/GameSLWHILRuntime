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

local GameConfig = require'GameConfig'

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(topUIInitHelper)
    topUIInitHelper:Init(self)
    self.topUIEventListener:Init(self)
end

function Class:UpdateOnlinePlayerCount(count)
    self.onlineCount.text = "在线人数："..tostring(count)
end

function Class:On_Toggle_Menu_Event(Toggle_Menu)
    local ison = Toggle_Menu.isOn
    print("Toggle_Menu ison = ", ison)
    if ison then
        self.optionMenuAnim:DOPlayForward()
    else
        self.optionMenuAnim:DOPlayBackwards()
    end
end

function Class:On_btn_Exit_Event(btn_Exit)
    print("OnExitClick...")
end

function Class:On_btn_Bank_Event(btn_Bank)
    print("OnBankClick...")
end

function Class:On_toggle_Music_Event(toggle_Music)
    print("OnMusicClick...isOn = ", toggle_Music.isOn)
end

function Class:On_toggle_Sound_Event(toggle_Sound)
    print("OnSoundClick...isOn = ", toggle_Sound.isOn)
end

function Class:On_btnUserInfo_Event(btnUserInfo)
    print("OnbtnUserInfoClick...")
end







return _ENV

