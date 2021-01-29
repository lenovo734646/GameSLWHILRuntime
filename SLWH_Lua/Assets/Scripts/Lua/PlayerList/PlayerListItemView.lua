
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, System, Sprite, AudioClip = UnityEngine, GameObject, System, UnityEngine.Sprite, UnityEngine.AudioClip
local Color = UnityEngine.Color
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local TextAnchor = UnityEngine.TextAnchor

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

--root:RectTransform类型
function Class:__init(view)
    self.view = view
    local initHelper = view:GetComponent(typeof(LuaInitHelper))
    initHelper:Init(self)
    self.msgItemBGs = {}
    initHelper:ObjectsSetToLuaTable(self.msgItemBGs)


    self.paddingAtIconSide = self.rootLayoutGroup.padding.right
    self.paddingAtOtherSide = self.rootLayoutGroup.padding.left
    self.colorAtInit = self.contentBackImage.color

    self.isPlaying = false
    self.onClick = nil
end

-- data : ChatMsgData.lua类型
function Class:UpdateFromData(data)
    if data == nil then
        logError("UpdateFromData data is nil")
        return
    end
    -- 时间戳
    self.timeText.text = data:GetTimeStamp()
    -- 头像和布局
    self.userID = data.userID
    if data.isMine then
        self.rightHeadBG:SetActive(true)
        self.rightHeadImage.sprite = data.iconSpr
        self.leftIHeadBG:SetActive(false)
        --
        --self.contentBackImage.color = Color(0.75, 1, 1, self.colorAtInit.a)
        self.rootLayoutGroup.childAlignment = TextAnchor.MiddleRight
        self.msgContentLayoutGroup.childAlignment = TextAnchor.MiddleRight
        self.rootLayoutGroup.padding.right = self.paddingAtIconSide
        self.rootLayoutGroup.padding.left = self.paddingAtOtherSide
    else
        self.leftIHeadBG:SetActive(true)
        self.leftHeadImage.sprite = data.iconSpr
        self.rightHeadBG:SetActive(false)
        --
        --self.contentBackImage.color = self.colorAtInit
        self.rootLayoutGroup.childAlignment = TextAnchor.MiddleLeft
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
        self.soundBtn.onClick:AddListener(function ()
            self:StartPlayback()
        end)
        self.text.text = ""
    else
        self.wfDraw.gameObject:SetActive(false);
        self.text.gameObject:SetActive(true);

        self.text.text = data.text;
        self.onClick = nil;
        self.audioSource = nil;
    end

    
end

function Class:StartPlayback()
    if self.isPlaying then
        return
    end
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
    if not self.isPlaying then
        return
    end
    self.isPlaying = false
    self.audioSource:Stop()
    self.wfDraw.playbackSli.value = 0
end


return _ENV