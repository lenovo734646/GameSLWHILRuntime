
-- 快捷消息
local musicMute = false
local audioMute = false

local Class = class()

function Class.Create(...)
    return Class(...)
end

function Class:__init(panel, gr, maxRecordTime)
    panel:GetComponent(typeof(GS.LuaInitHelper)):Init(self)
    self.panel = panel
    self.gr = gr
    self.maxRecordTime = maxRecordTime
    -- self.recorder.RecordVOLEnhanceMulti = 1 -- 声音放大

    self.btnPressRecording.OnTouchDown:RemoveAllListeners()
    self.btnPressRecording.OnTouchDown:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(true)
        local bStart = self.recorder:StartRecording(self.maxRecordTime)
        if not bStart then
            ShowTips(_STR_("录音失败，请检查权限"))
        else
            self:PauseMusicAndAudio()
        end
    end)

    self.btnPressRecording.OnTouchUp:RemoveAllListeners()
    self.btnPressRecording.OnTouchUp:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(false)
        if GS.UnityHelper.IsMouseCorveredTarget(self.btnPressRecording.gameObject, self.gr) then
            --send msg
            local clipData = self.recorder:GetSendDataBuff()
            if clipData ~= nil then
                local clipChannels = self.recorder:GetRecordingClipChannels()
                if self.onSendCallback then
                    Log("OnTouchUp....发送消息", #clipData, type(clipData))
                    self.onSendCallback(clipData, clipChannels, self.recorder.freq)
                end
                self.recorder:CancelRecording()
            end
        else
            --松手时不在录音按钮上就取消
            self.recorder:CancelRecording()
            ShowTips(_G._STR_("取消语音发送"))
        end
        self:RecoverMusicAndAudio()
    end)
end

function Class:RequestMicrophone()
    self.recorder:Init()
end
-- 取消音频输入
function Class:CancelVoiceInput()
    if self.recorder.isRecording then
        self.recorder:CancelRecording()
        ShowTips(_G._STR_("取消语音发送"))
        self:RecoverMusicAndAudio()
    end
end

function Class:OnShow(isOn)
    self.panel:SetActive(isOn)
    self.sliderPanel.gameObject:SetActive(not isOn)
end

function Class:ByteToAudioClip(clipData, clipChannels, freq)
    if clipData == nil then
        GF.logError("ByteToAudioClip clipData is nil")
        return nil
    end

    return self.recorder:ByteToAudioClip(clipData, clipChannels, freq)
end

function Class:Release()
    self.btnPressRecording.OnTouchDown:RemoveAllListeners()
    self.btnPressRecording.OnTouchDown:Invoke()
    self.btnPressRecording.OnTouchUp:RemoveAllListeners()
    self.btnPressRecording.OnTouchUp:Invoke()
    self.onSendCallback = nil
end

function Class:PauseMusicAndAudio()
    if not GS.AudioManager.Instance.MusicAudio.mute then
        GS.AudioManager.Instance.MusicAudio.mute = true
        musicMute = false
    else
        musicMute = true
    end
    if not GS.AudioManager.Instance.EffectAudio.mute then
        GS.AudioManager.Instance.EffectAudio.mute = true
        audioMute = false
    else
        audioMute = true
    end
end

function Class:RecoverMusicAndAudio()
    GS.AudioManager.Instance.MusicAudio.mute = musicMute
    GS.AudioManager.Instance.EffectAudio.mute = audioMute
end


return Class
