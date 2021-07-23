
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8, tostring= class, typeof, type, string, utf8, tostring

local UnityEngine, GameObject, System, Sprite, AudioClip = UnityEngine, GameObject, System, UnityEngine.Sprite, UnityEngine.AudioClip
local Color = UnityEngine.Color
local TextAnchor = UnityEngine.TextAnchor
local SEnv=SEnv
local Helpers = require'LuaUtil.Helpers'

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

--root:RectTransform类型
function Class:__init(view)
    self.view = view
    view:GetComponent(typeof(LuaInitHelper)):InitWithList(self,'rangimglist')
    self.onClick = nil
end

-- data : ChatMsgData.lua类型
function Class:UpdateFromData(data)
    if data == nil then
        logError("UpdateFromData data is nil")
        return
    end
    -- 头像和布局
    self.userID = data.userID
    self.TMP_f_UserNickName.text = data.userName
    self.TMP_f_UserMoney.text = Helpers.GameNumberFormat(data.gold)
    if data.headID then
        self.head_image.sprite = SEnv.GetHeadSprite(data.headID)
    end
    
    if data.headFrameID ~= nil then
        self.frame_image.sprite = SEnv.GetHeadFrameSprite(data.headFrameID)
    end

    for i = 1, #self.rangimglist do
        self.rangimglist[i].gameObject:SetActive(false)
    end

    local img = self.rangimglist[data.rankid]
    if img then
        img.gameObject:SetActive(true)
    end
    
    if data.rankImageSpr ~= nil then
        -- self.rankImage.sprite = data.rankImageSpr
        -- self.rankImage.gameObject:SetActive(true)
        self.rankText.gameObject:SetActive(false)
    else
        -- self.rankImage.gameObject:SetActive(false)
        self.rankText.gameObject:SetActive(true)
        self.rankText.text = tostring(data.rank)
    end
    data.betScore = data.betScore or 0
    data.winCount = data.winCount or 0
    self.betScoreText.text = Helpers.GameNumberFormat(data.betScore)
    self.winCountText.text = Helpers.GameNumberFormat(data.winCount)
end

function Class:UserInfoBtnClick()
    -- TODO： 点击玩家头像按钮，显示玩家详细信息
    
end


return _ENV