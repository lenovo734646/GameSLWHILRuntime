_STR_=_STR_ or function (str)
    return str
end
local Helpers = require'LuaUtil.Helpers'
SubGame_Env = SubGame_Env or {}
SubGame_Env.ConvertNumberToString = Helpers.GameNumberFormat

-- print = function() -- 屏蔽日志
-- end

SubGame_Env.ShowHintMessage = function(contentStr)
    if g_Env then
        g_Env.ShowHitMessage(contentStr)
    else
        print(contentStr)
    end
end
-- 显示一个短暂停留的提示
SubGame_Env.ShowHintMessageByErrCode = function (errTipTable, errcode)
    if errcode <= 0 then
        return
    end
    local errStr = errTipTable[errcode]
    if g_Env then
        g_Env.ShowHitMessage(errStr)
    else
        print(errStr)
    end
end

SubGame_Env.ShowErrorByHint = function (errcode,msgName)
    if g_Env then
        g_Env.ShowHitMessage(g_Env.GetServerErrorMsg(errcode,msgName))
    else
        print('服务器返回错误 errcode=',errcode,'msgName=',msgName)
    end
end

require "LuaUtil/LuaRequires"
local Config = Config or require'Rebuild.Config' -- 在大厅模式下会传给小游戏这个数值
local g_Env = g_Env
local GameConfig require'GameConfig'
local PBHelper = require'protobuffer.PBHelper'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local SceneView = require'View.Scene3DView'
local Loader = require 'Rebuild.LuaAssetLoader'
--
local yield = coroutine.yield
local CoroutineHelper = require 'CoroutineHelper'

local Sprite = UnityEngine.Sprite
local GameObject = UnityEngine.GameObject
if SUBGAME_EDITOR then
    -- 在大厅中将使用大厅的环境
    local playerRes = {diamond=0,currency=0,integral=0, selfUserID = 0, userName = "", headID = 0, headFrameID = 0}
    SubGame_Env.playerRes = playerRes

    SubGame_Env.GetHeadSprite = function (headID)
        return SubGame_Env.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/head_"..(headID+1)..".png", typeof(Sprite))
    end

    SubGame_Env.GetHeadFrameSprite = function (headFrameID)
        return SubGame_Env.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/headFrame_"..(headFrameID+1)..".png", typeof(Sprite))
    end
    print("SUBGAME_EDITOR!")
    -- PBHelper.AddListener('CLPF.ResChangedNtf', function (data)
    --     print("111111111111111111")
    --     if data.res_type == 2 then
    --         playerRes.currency = data.res_value
    --     end
    -- end)
end




local roomdata = {
    last_bet_id = 1,
    bet_config_array = {},
    state = 1,
    left_time = 0,
    room_tatol_bet_info_list = {},
    self_bet_list = {},
    self_score = 0,
    self_user_id = 0,
    self_user_name = "",
    self_user_Head = 0,
    self_user_HeadFrame = 0,

}
PBHelper.Init('CLSLWH')
PBHelper.AddPbPkg('CLPF')
PBHelper.AddPbPkg('CLCHATROOM')

local SceneList = {"MainScene"}
local AssetList = {
    "Assets/AssetsFinal/EmojiPics.prefab"
}
local SoundPkgList = {
    'Assets/AssetsFinal/SLWHSounds.prefab'
}
local LoadList = {AssetList, SoundPkgList, SceneList}
local GetLoadCount = function ()
    local count = 0
    for _, t in pairs(LoadList) do
        count = count + #t
    end
    return count
end


local loadMatTexByLangAsync = function(matpath,texpath_without_ext,texidname)
    local loader = SubGame_Env.loader
    local mat = loader:LoadAsync(matpath)
    local mask = SysDefines.curLanguage=='EN' and '_EN' or ''
    local texpath = texpath_without_ext .. mask .. '.png'
    local tex = loader:LoadAsync(texpath)
    return mat:SetTexture(texidname, tex)
end


local gameView
function OnSceneLoaded(scene, mode)
    if scene.name == "LoadingScene" then
        CoroutineHelper.StartCoroutine(function ()
            local data,err = CLSLWHSender.Send_EnterRoomReq_Async()
            if err then
                print('Send_EnterRoomAck:'..json.encode(data))
                if g_Env then
                    g_Env.MessageBox{
                        content = err,
                        onOK = function()
                            g_Env.SubGameCtrl.Leave()
                        end
                    }
                else
                    print('进入房间失败 data.errcode=', data.errcode)
                end
                return

            else
                roomdata = data
                for key, value in pairs(roomdata.bet_config_array) do
                    print("bet_config_array: "..key..",  "..value)
                end
                
                SubGame_Env.playerRes.currency = roomdata.self_score
                SubGame_Env.playerRes.selfUserID = roomdata.self_user_id
                SubGame_Env.playerRes.userName = roomdata.self_user_name
                SubGame_Env.playerRes.headID = roomdata.self_user_Head
                SubGame_Env.playerRes.headFrameID = roomdata.self_user_HeadFrame
                print("SelfUserID = ", SubGame_Env.playerRes.selfUserID, SubGame_Env.playerRes.headID, SubGame_Env.playerRes.headFrameID)
            end
            local sliderGo = GameObject.Find("Slider")
            local slider = sliderGo:GetComponent("Slider")
            slider.value = 0.25
            local loader = SubGame_Env.loader
            local allLoadCount = GetLoadCount()
            local loadedCount = 0
            local updateProgress = function ()
                loadedCount = loadedCount+1
                slider.value = (loadedCount/allLoadCount)
                --print("加载进度：", loadedCount, allLoadCount, slider.value)
            end
            --先加载和设置多语言纹理
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/庄1.mat','Assets/Dance/Xiazhu/Tex/Zhuang','_MainTex')
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/闲1.mat','Assets/Dance/Xiazhu/Tex/Xian','_MainTex')
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/和1.mat','Assets/Dance/Xiazhu/Tex/He','_MainTex')
            for k, v in pairs(LoadList) do
                if k == 1 then
                    for _, assetPath in pairs(v) do
                        print("加载Asset：path = ", assetPath)
                        loader:LoadAsync(assetPath)
                        updateProgress()
                    end
                elseif k == 2 then
                    for _, soundPkgPath in pairs(v) do
                        loader:LoadSoundsPackage(soundPkgPath)
                        updateProgress()
                    end
                elseif k == 3 then
                    for _, sceneName in pairs(v) do
                        print("loadScene", sceneName)
                        SceneManager.LoadSceneAsync(sceneName)
                        updateProgress()
                    end
                end
            end
            --#region
        end)
    end
    if scene.name == "MainScene" then
        gameView = SceneView.Create(roomdata)
    end
end
--TODO 目前没有被调用，需要在大厅下测试与调用
function OnNetWorkReConnect()
    gameView.ctrl:OnNetWorkReConnect()
end



local OnReceiveNetData = PBHelper.OnReceiveNetData
function OnReceiveNetDataPack(data, packname)
    OnReceiveNetData(data, packname)
    
end

-- 退出游戏时调用：如果有必要可用来清理场景，关闭UI等
function OnCloseSubGame()
    print("退出小游戏 OnCloseSubGame...")
end

SubGame_Env.loader = SubGame_Env.loader or Loader.Create(Config:GetSavePath("SLWH"), Config.debug)
SubGame_Env.loader:LoadScene('LoadingScene')



