
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds
local UnityHelper = CS.UnityHelper
local _STR_ = _STR_
local _ERR_STR_ = _ERR_STR_
local ShowHitMessage = ShowHitMessage

_ENV = moduledef { seenamespace = CS }

local musicMute = false
local audioMute = false

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, gr, maxRecordTime)
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.panel = panel
    self.gr = gr
    self.maxRecordTime = maxRecordTime
    -- self.recorder.RecordVOLEnhanceMulti = 1 -- 声音放大

    self.btnPressRecording.OnTouchDown:RemoveAllListeners()
    self.btnPressRecording.OnTouchDown:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(true)
        local bStart = self.recorder:StartRecording(self.maxRecordTime)
        if not bStart then
            if g_Env then
                g_Env.ShowHitMessage(_STR_("录音失败，请检查权限"))
            else
                print("录音失败，请检查权限")
            end
        else
            self:PauseMusicAndAudio()
        end
    end)

    self.btnPressRecording.OnTouchUp:RemoveAllListeners()
    self.btnPressRecording.OnTouchUp:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(false)
        if UnityHelper.IsMouseCorveredTarget(self.btnPressRecording.gameObject, self.gr) then
            --send msg
            local clipData = self.recorder:GetSendDataBuff()
            if clipData ~= nil then
                
                if self.onSendCallback then
                    print("OnTouchUp....发送消息", #clipData, type(clipData))
                    self.onSendCallback(clipData)
                end
                self.recorder:CancelRecording()
            end
        else
            --松手时不在录音按钮上就取消
            self.recorder:CancelRecording()
            print("取消语音发送...")
        end
        self:RecoverMusicAndAudio()
    end)
end

function Class:OnShow(isOn)
    -- self.panel:SetActive(isOn)
    -- self.sliderPanel.gameObject:SetActive(not isOn)
end

function Class:ByteToAudioClip(clipData)
    if clipData == nil then
        logError("ByteToAudioClip clipData is nil")
        return nil
    end

    return self.recorder:ByteToAudioClip(clipData)
end

function Class:Release()
    self.btnPressRecording.OnTouchDown:RemoveAllListeners()
    self.btnPressRecording.OnTouchUp:RemoveAllListeners()
end

function Class:PauseMusicAndAudio()
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
end

function Class:RecoverMusicAndAudio()
    AudioManager.Instance.MusicAudio.mute = musicMute
    AudioManager.Instance.EffectAudio.mute = audioMute
end

return _ENV
