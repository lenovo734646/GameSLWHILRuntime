SubGame_Env = {}
local LogW = CS.UnityEngine.Debug.LogWarning
local SysDefines, string = CS.SysDefines, string
local subGameLanguageConvert = require'Table.LanguageConvert' -- 查找小游戏语言转换表

local config = require 'Config'
local init = require 'Main'
local PBHelper = require 'protobuffer.PBHelper'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local LanguageHelper = require 'LuaUtil.LanguageHelper'

local DDOLGameObject = GS.GameObject.Find('DDOLGameObject')
if not DDOLGameObject then
    DDOLGameObject = GS.GameObject('DDOLGameObject')
end
DDOLGameObject:AddComponent(typeof(GS.MessageCenter))
DDOLGameObject:AddComponent(typeof(GS.AudioManager))
DDOLGameObject:AddComponent(typeof(GS.NetController))
AudioManager = GS.AudioManager.Instance
-- 独立运行小游戏设置
AudioManager:SetMusicMute(not config.playMusic)
AudioManager:SetEffectMute(not config.playEffect)


GS.UnityEngine.Object.DontDestroyOnLoad(DDOLGameObject)
GS.NetController.Instance.serverUrl = [[http://47.242.30.92:8000/router/rest]] --= [[http://101.36.116.254:8000/router/rest]]
PBHelper.Init('CLFQZS')
PBHelper.AddPbPkg('CLPF')
SEnv.loader = require'LuaAssetLoader'.Create()
local loginctrl = require'LuaLoginCtrl'.Create()
PBHelper.AddListener("CLGT.DisconnectNtf", function(ntf)
    local tips = LanguageHelper.GetDisconnectTips(ntf)
    print(tips)
end)
CoroutineHelper.StartCoroutine(function()
    local b, err = loginctrl:AutoLoginAsync()
    if not b then
        LogE('登录过程出错 ', err)
    else
        init()
    end
end)

local hintMessage = require'LuaHintMessage'.Create()
ShotHintMessage = function (...)
    print('HintMessage:',...)
    return hintMessage:ShowHintMessage(...)
end

_STR_ = _STR_ or function (str)
    local t = subGameLanguageConvert[str]
    if not t then
        -- LogW("_STR_: <"..str..">  没有对应的值")
        return str
    end

    local langStr = t[SysDefines.curLanguage] 
    if GF.string.IsNullOrEmpty(langStr) then
        if SysDefines.curLanguage ~='CN' then
            -- LogW('<'..str..'>'.." 没有对应语言版本的值！Language = ", SysDefines.curLanguage)
        end
    end
    return langStr or str
end