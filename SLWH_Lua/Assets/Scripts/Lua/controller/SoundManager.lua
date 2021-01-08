
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local AudioClip = CS.UnityEngine.AudioClip
local AudioSource = CS.UnityEngine.AudioSource

local CoroutineHelper = require'CoroutineHelper'
local WaitForSeconds = UnityEngine.WaitForSeconds
local yield = coroutine.yield
      
_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(soundMgrInitHelper)
    local sounds = {}
    soundMgrInitHelper:ObjectsSetToLuaTable(sounds)
    self.soundClips = {}
    for key, clip in pairs(sounds) do
        self.soundClips[clip.name] = clip
    end
    soundMgrInitHelper:Init(self)

end

function Class:PlayBGMusic()
     -- 背景音乐循环
     if self.musicAudioSource.clip == nil then
        LogE("BGMusic Clip is nil")
        return
     end
     if self.musicAudioSource.isPlaying then
         return
     end
    self.musicCo = CoroutineHelper.StartCoroutine(function ()
        self.musicAudioSource:Play()
        while true do
            yield(WaitForSeconds(self.musicAudioSource.clip.length+1))
            self.musicAudioSource:Play()
        end
    end)
end

function Class:StopBGMusic()
    CoroutineHelper.StopCoroutine(self.musicCo)
    self.musicAudioSource:Stop()
end

function Class:PlaySound(name)
    if not self.soundClips[name] then
        LogE("SoundManager:PlaySound 音频不存在:", name)
        return
    end
    self.soundAudioSource:PlayOneShot(self.soundClips[name])
end

function Class:SetMusicMute(b)
    self.musicAudioSource.mute = b
end

function Class:SetSoundMute(b)
    self.soundAudioSource.mute = b
end


return _ENV