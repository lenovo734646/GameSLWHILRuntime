-- 小游戏启动入口
SubGame_Env = {}

local init = require 'Main'

local DDOLGameObject = GS.GameObject.Find('DDOLGameObject')
DDOLGameObject:AddComponent(typeof(GS.MessageCenter))
DDOLGameObject:AddComponent(typeof(GS.AudioManager))
DDOLGameObject:AddComponent(typeof(GS.NetController))
AudioManager = GS.AudioManager.Instance
-- 独立运行小游戏设置
AudioManager:SetMusicMute(not GG.Config.playMusic)
AudioManager:SetEffectMute(not GG.Config.playEffect)


GS.UnityEngine.Object.DontDestroyOnLoad(DDOLGameObject)
GS.NetController.Instance.serverUrl = [[http://47.101.62.170:8000/router/rest]]
-- GS.NetController.Instance.serverUrl = [[http://47.242.30.92:8000/router/rest]]
-- GS.NetController.Instance.serverUrl = [[http://8.210.210.249:8000/router/rest]]

GG.PBHelper.Init('CLSLWH')
GG.PBHelper.AddPbPkg('CLPF')

SEnv.loader = GG.LuaAssetLoader.Create()

GG.PBHelper.AddListener("CLGT.DisconnectNtf", function(ntf)
    local tips = GG.LanguageHelper.GetDisconnectTips(ntf)
    Log(tips)
end)

-- 游戏自启动登录
GG.CoroutineHelper.StartCoroutine(function()
    local loginctrl = GG.LuaLoginCtrl.Create()

    local b, err = loginctrl:AutoLoginAsync()
    if not b then
        LogE('登录过程出错 ', err)
    else
        init()
    end
end)
