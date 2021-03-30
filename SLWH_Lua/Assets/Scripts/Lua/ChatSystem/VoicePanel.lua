
local _G, g_Env, print, log, logError, os, math = _G, g_Env, print, log, logError, os, math
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Image, Button = UnityEngine, GameObject, UnityEngine.UI.Image, UnityEngine.UI.Button
local CoroutineHelper = require 'CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = UnityEngine.WaitForSeconds
local IsMouseCorveredTarget = CS.UnityHelper.IsMouseCorveredTarget


_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(panel, gr, maxRecordTime)
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.panel = panel
    self.gr = gr
    self.maxRecordTime = maxRecordTime

    self.btnPressRecording.OnTouchDown:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(true)
        self.recorder:StartRecording(self.maxRecordTime)
    end)

    self.btnPressRecording.OnTouchUp:AddListener(function ()
        self.sliderPanel.gameObject:SetActive(false)
        if IsMouseCorveredTarget(self.btnPressRecording.gameObject, self.gr) then
            --send msg
            local clipData = self.recorder:GetSendDataBuff()
            if clipData ~= nil then
                print("OnTouchUp....发送消息")
                if self.onSendCallback then
                    self.onSendCallback(clipData)
                end
                self.recorder:CancelRecording()
            end
        else
            --松手时不在录音按钮上就取消
            self.recorder:CancelRecording()
        end
    end)
end

function Class:OnShow(isOn)
    self.panel:SetActive(isOn)
    self.sliderPanel.gameObject:SetActive(not isOn)
end

function Class:ByteToAudioClip(clipData)
    if clipData == nil then
        logError("ByteToAudioClip clipData is nil")
        return nil
    end

    return self.recorder:ByteToAudioClip(clipData)
end

return _ENV
