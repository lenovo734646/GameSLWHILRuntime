local GS = GS
local GF = GF
local _G = _G
local g_Env, class = g_Env, class
local pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert
    = pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert

local SEnv = SEnv
_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(userInfoInitHelper, playerRes)
    userInfoInitHelper:Init(self)
    self.userInfoEventListener:Init(self)
    print("userInfo:", json.encode(playerRes))
    if g_Env and g_Env.CommonUICtrl then  -- 使用GamePlayer 大厅数据
        g_Env.CommonUICtrl.SetPlayerValues(self)
    else    -- 使用进入房间返回的数据(独立运行不能设置头像和头像框)
        self.selfUserID = playerRes.selfUserID
        self.TMP_f_UserNickName.text = playerRes.userName
        self:OnChangeMoney(playerRes.currency)
        self:OnChangeHead(playerRes.headID)
        self:OnChangeHeadFrame(playerRes.headFrameID)
    end

end

function Class:OnChangeMoney(currency)
    self.TMP_f_UserMoney.text = tostring(currency)--Helpers.GameNumberFormat(currency)
end

function Class:OnChangeHead(headID)
    SEnv.AutoUpdateHeadImage(self.image_f_UserHead, headID, self.selfUserID)
end

function Class:OnChangeHeadFrame(headFrameID)
    self.image_f_UserHeadFrame.sprite = SEnv.GetHeadFrameSprite(headFrameID)
    self.image_f_UserHeadFrame:SetNativeSize()
end

function Class:On_btnUserInfo_Event(btnUserInfo)
    print("On_btnUserInfo Click....打开个人信息窗口....")
end


return _ENV