
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, System, Sprite, AudioClip = UnityEngine, GameObject, System, UnityEngine.Sprite, UnityEngine.AudioClip
local Color = UnityEngine.Color
local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local TextAnchor = UnityEngine.TextAnchor
local Vector2 = UnityEngine.Vector2
local SEnv = SEnv
local _STR_ = _STR_
local _ERR_STR_ = _ERR_STR_

_ENV = moduledef { seenamespace = CS }

local musicMute = false
local audioMute = false

local Class = class()

function Create(...)
    return Class(...)
end

--root:RectTransform类型
function Class:__init(view)
    self.view = view
    view:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

    self.paddingAtIconSide = self.rootLayoutGroup.padding.right
    self.paddingAtOtherSide = self.rootLayoutGroup.padding.left
    self.colorAtInit = self.contentBackImage.color

    self.isPlaying = false
    -- data 信息
    self.msgData = nil

    --
    self.progressSliderRoot:SetActive(false)
    self.btn_ReSend.gameObject:SetActive(false)
end

-- data : ChatMsgData.lua类型
function Class:UpdateFromData(data)
    self.eventListener:Init(self)
    if data == nil then
        logError("UpdateFromData data is nil")
        return
    end
    self.msgData = data
    -- 时间戳
    self.timeText.text = data:GetTimeStamp()
    -- 头像和布局
    self.userID = data.userID
    if data.isMine then
        self.rightHeadBG:SetActive(true)
        SEnv.AutoUpdateHeadImage(self.rightHeadImage, data.headID, data.userID)
        self.leftIHeadBG:SetActive(false)
        -- 自己发言不用显示名字
        --self.nameText.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(1, 30)
        self.nameText.gameObject:SetActive(false)
        --self.InfoRootLayout.childAlignment = TextAnchor.UpperRight
        --self.contentBackImage.color = Color(0.75, 1, 1, self.colorAtInit.a)
        self.rootLayoutGroup.childAlignment = TextAnchor.UpperRight
        self.msgContentLayoutGroup.childAlignment = TextAnchor.MiddleRight
        self.rootLayoutGroup.padding.right = self.paddingAtIconSide
        self.rootLayoutGroup.padding.left = self.paddingAtOtherSide
    else
        self.leftIHeadBG:SetActive(true)
        SEnv.AutoUpdateHeadImage(self.leftHeadImage, data.headID, data.userID)
        self.rightHeadBG:SetActive(false)
        --
        --self.nameText.gameObject:GetComponent("RectTransform").sizeDelta = Vector2(210, 30)
        self.nameText.gameObject:SetActive(true)
        self.nameText.text = data.nickName
        --self.InfoRootLayout.childAlignment = TextAnchor.UpperLeft
        --self.contentBackImage.color = self.colorAtInit
        self.rootLayoutGroup.childAlignment = TextAnchor.UpperLeft
        self.msgContentLayoutGroup.childAlignment = TextAnchor.MiddleLeft
        self.rootLayoutGroup.padding.right = self.paddingAtOtherSide
        self.rootLayoutGroup.padding.left = self.paddingAtIconSide
    end
    -- 设置消息条目背景
    self.contentBackImage.sprite = data.msgItemBgSpr
    -- 消息内容
    if data.audioClip ~= nil then
        self.wfDraw.gameObject:SetActive(true)
        self.text.gameObject:SetActive(false)

        self.audioSource.clip = data.audioClip
        self.wfDraw:StartWaveFormGeneration(data.audioClip)
        -- self:StartPlayback() -- 不自动播放
        self.text.text = ""
        -- 消息状态
        if data.isMine then
            self.progressSliderRoot:SetActive(not self.msgData.IsSendSusseed)
        else
            self.progressSliderRoot:SetActive(false)
        end
        self.btn_ReSend.gameObject:SetActive(false)
    else
        self.wfDraw.gameObject:SetActive(false);
        self.text.gameObject:SetActive(true);

        self.text.text = self:FixEmojiSize(data.text)
        self.audioSource.clip = nil;
    end
end

function Class:FixEmojiSize(text, fixSize)
    fixSize = fixSize or 45
    local tempText = text
    tempText = string.gsub(text, "<sprite=%d+>", function (s)
        -- print(s)
        return "<size="..fixSize..">"..s.."</size>"
    end)
    return tempText
end

function Class:StartPlayback()
    if self.isPlaying then
        self:StopPlayback()
        return
    end
    print("开始回放音频：", self.isPlaying, self.audioSource.clip.length)
    if not AudioManager.Instance.MusicAudio.mute then
        AudioManager.Instance.MusicAudio.mute = true
        musicMute = false
    else
        musicMute = true
    end
    if not AudioManager.Instance.EffectAudio.mute then
        AudioManager.Instance.EffectAudio.mute = true
        audioMute = false
    else
        audioMute = true
    end
    -- 
    self.isPlaying = true
    self.audioSource:Play()
    -- 协程等待播放结束
    CoroutineHelper.StartCoroutine(function ()
        if not self.isPlaying then
            yield()
        end
        while self.isPlaying do
            yield()
            self.wfDraw.playbackSli.value = self.audioSource.timeSamples * self.audioSource.clip.channels
            if self.audioSource.isPlaying == false then
                self:StopPlayback()
                break
            end
        end

    end)
end

function Class:StopPlayback()
    print("结束回放音频：", self.isPlaying)
    if not self.isPlaying then
        return
    end
    self.isPlaying = false
    self.audioSource:Stop()
    self.wfDraw.playbackSli.value = 0
    AudioManager.Instance.MusicAudio.mute = musicMute
    AudioManager.Instance.EffectAudio.mute = audioMute
end

function Class:OnSendSuccess()
    self.progressSliderRoot:SetActive(false)
    self.btn_ReSend.gameObject:SetActive(false)
    self.msgData.IsSendSusseed = true
    print("发送成功...")
end

function Class:OnSendFailed(err)
    _G.ShotHintMessage(_STR_'发送失败:'..err)
    self.progressSliderRoot:SetActive(false)
    self.btn_ReSend.gameObject:SetActive(true)
end

function Class:OnUpdateProgress(progress)
    self.progressSlider.value = progress
    -- print("发送进度:", progress*100)
end

function Class:OnDestroy()
    -- print("ChatMsgViewItem OnDestroy.............")
end

-- function Class:OnEnable()
--     print("ChatMsgView OnEnable.............")
-- end

function Class:On_btn_ReSend_Event(btn_ReSend)
    if self.OnReSend then
        self.OnReSend(self.timestampSec)
    end
end

function Class:On_btn_PlaySound_Event(btn_PlaySound)
    self:StartPlayback()
end


return _ENV