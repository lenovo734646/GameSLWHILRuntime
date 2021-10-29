local _G, g_Env = _G, g_Env
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local Helpers = require'LuaUtil.Helpers'
local SEnv = SEnv
_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(userInfoInitHelper, roomData)
    userInfoInitHelper:Init(self)
    self.eventListener:Init(self)

    if g_Env and g_Env.CommonUICtrl then  -- 使用GamePlayer 大厅数据
        g_Env.CommonUICtrl.SetPlayerValues(self)
    else    -- 使用进入房间返回的数据(独立运行不能设置头像和头像框)
        self.selfUserID = roomData.self_user_id
        self.TMP_f_UserNickName.text = roomData.self_user_name
        self:OnChangeMoney(roomData.self_score)
        self:OnChangeHead(roomData.self_user_Head)
        self:OnChangeHeadFrame(roomData.self_user_HeadFrame)
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
end


-- 以下为自动生成代码
function Class:On_btn_UserInfo_Event(btn_UserInfo)
    print("On_btnUserInfo Click....打开个人信息窗口....")
end


return _ENV