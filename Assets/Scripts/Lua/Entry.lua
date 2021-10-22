SubGame_Env = {}
_STR_ = _STR_ or function (str)
    return str
end
local init = require 'Main'
local PBHelper = require 'protobuffer.PBHelper'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local LanguageHelper = require 'LuaUtil.LanguageHelper'

local DDOLGameObject = GameObject.Find('DDOLGameObject')
if not DDOLGameObject then
    DDOLGameObject = GameObject('DDOLGameObject')
end
DDOLGameObject:AddComponent(typeof(CS.MessageCenter))
DDOLGameObject:AddComponent(typeof(CS.AudioManager))
DDOLGameObject:AddComponent(typeof(CS.NetController))
AudioManager = CS.AudioManager.Instance
UnityEngine.Object.DontDestroyOnLoad(DDOLGameObject)
CS.NetController.Instance.serverUrl = [[http://47.104.147.168:8000/router/rest]]
PBHelper.Init('CLSLWH')
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
