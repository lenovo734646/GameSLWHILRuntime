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


function Class:__init(userInfoInitHelper, roomData)
    userInfoInitHelper:Init(self)
    self.userInfoEventListener:Init(self)

    self.selfUserID = roomData.self_user_id
    self.userName.text = roomData.self_user_name
    self:OnChangeMoney(roomData.self_score)
    self:OnChangeHead(roomData.self_user_Head)
    self:OnChangeHeadFrame(roomData.self_user_HeadFrame)
end

function Class:OnChangeMoney(currency)
    self.userMoney.text = tostring(currency)
end

function Class:OnChangeHead(headID)
    --self.headImg.sprite = GetHeadSprite(headID)
end

function Class:OnChangeHeadFrame(headFrameID)
    --self.headFrameImg.sprite = GetHeadFrameSprite(headFrameID)
end

function Class:On_btnUserInfo_Event(btnUserInfo)
    print("On_btnUserInfo Click....打开个人信息窗口....")
end


return _ENV