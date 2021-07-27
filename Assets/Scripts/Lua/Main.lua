SEnv = SubGame_Env
-- if g_Env then
--     print = function (...)--日志屏蔽
--     end
-- end

ShowErrorByHint = function (msgName,errcode)
    if g_Env then
        g_Env.ShowTips(g_Env.GetServerErrorMsg(errcode,msgName))
    else
        print('服务器返回错误代码','msgName=',msgName,'errcode=',errcode)
    end
end

ShowErrorByHintHandler = function (errcode, msgName)
    if g_Env then
        g_Env.ShowHitMessage(g_Env.GetServerErrorMsg(errcode,msgName))
    else
        print('服务器返回错误 errcode=',errcode,'msgName=',msgName)
    end
end
require'Prepare'
require "LuaUtil/LuaRequires"
local PBHelper = require'protobuffer.PBHelper'
local MessageCenter = require'Message.MessageCenter'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local SceneView = require'View.Scene3DView'
--
local yield = coroutine.yield
local CoroutineHelper = require'LuaUtil.CoroutineHelper'

local Sprite = UnityEngine.Sprite
local GameObject = UnityEngine.GameObject



function Main()
    print("SLWH Lua Main")
    PBHelper.Init('CLSLWH')
    PBHelper.AddPbPkg('CLCHATROOM')
    _WaitSubGameLoadDone = true

    if g_Env == nil then
        -- 在大厅中将使用大厅的环境
        local playerRes = {diamond=0,currency=0,integral=0, selfUserID = 0, userName = "", headID = 0, headFrameID = 0}
        SEnv.playerRes = playerRes
    
        SEnv.GetHeadSprite = function (headID)
            return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/head_"..(headID+1)..".png", typeof(Sprite))
        end
    
        SEnv.GetHeadFrameSprite = function (headFrameID)
            return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/headFrame_"..(headFrameID+1)..".png", typeof(Sprite))
        end
        local commonSounds = SEnv.loader:Load("Assets/Resources/commonSounds.prefab")
        CS.UnityEngine.Object.DontDestroyOnLoad(_G.Instantiate(commonSounds)) -- 公共音频资源
        print("SUBGAME_EDITOR!")
    end
    SEnv.loader:LoadScene('LoadingScene')
    _WaitSubGameLoadDone = false
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
    local loader = SEnv.loader
    local mat = loader:LoadAsync(matpath)
    local mask = SysDefines.curLanguage=='EN' and '_EN' or ''
    local texpath = texpath_without_ext .. mask .. '.png'
    local tex = loader:LoadAsync(texpath)
    return mat:SetTexture(texidname, tex)
end

-- EnterRoomReq 回应处理
local OnEnterRoomAck = function(data, err)
    err = err or data.errcode
    if err ~= 0 then
        print('Send_EnterRoomAck:'..json.encode(data))
        if g_Env then
            g_Env.MessageBox{
                content = err,
                onOK = function()
                    g_Env.SubGameCtrl.Leave()
                end
            }
        else
            print('进入房间失败: ', err)
        end
        return false
    else
        roomdata = data
        for key, value in pairs(roomdata.bet_config_array) do
            print("bet_config_array: "..key..",  "..value)
        end
        
        SEnv.playerRes.currency = roomdata.self_score
        SEnv.playerRes.selfUserID = roomdata.self_user_id
        SEnv.playerRes.userName = roomdata.self_user_name
        SEnv.playerRes.headID = roomdata.self_user_Head
        SEnv.playerRes.headFrameID = roomdata.self_user_HeadFrame
        print("进入房间成功:UserID = ", SEnv.playerRes.selfUserID, SEnv.playerRes.headID, SEnv.playerRes.headFrameID)
    end
    return true
end

local gameView
function OnSceneLoaded(scene, mode)
    if scene.name == "LoadingScene" then
        CoroutineHelper.StartCoroutine(function ()
            -- 进入房间请求
            local data, err = CLSLWHSender.Send_EnterRoomReq_Async()
            OnEnterRoomAck(data, err)
            -- 进度处理和资源加载
            local sliderGo = GameObject.Find("Slider")
            local slider = sliderGo:GetComponent("Slider")
            slider.value = 0.25
            local loader = SEnv.loader
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
        SEnv.messageCenter = MessageCenter()
        gameView = SceneView.Create(roomdata)
    end
end


local OnReceiveNetData = PBHelper.OnReceiveNetData
function OnReceiveNetDataPack(data, packname)
    OnReceiveNetData(data, packname)
    
end

-- 退出游戏时调用：如果有必要可用来清理场景，关闭UI等
function OnCloseSubGame()
    print("退出小游戏 OnCloseSubGame...")
    --gameView:Release()
end

local LogW = LogW
-- 网络断开时调用，此时小游戏应该立即停止所有正在进行的协程和游戏进程，等待网络恢复
-- 这里的网络中断和g_Env._SubGameReconnection并不相同
-- g_Env._SubGameReconnection是在玩家强制退出游戏或者意外退出游戏时恢复用
-- 这里的中断是在游戏过程中网络中断，是互联网断开，不是与服务器断开
function OnNetworkLost()
    local LoadingUI = g_Env.uiManager:OpenUI('LoadingUI')
    if Application.internetReachability == UnityEngine.NetworkReachability.NotReachable then
        LoadingUI:SetTipText(_STR_ '网络已断开，网络恢复将继续游戏...')
        CoroutineHelper.StopAllCoroutines()
        LogW("网络连接断开...")
    else
        LoadingUI:SetTipText(_STR_ '与服务器断开连接，等待恢复中...')
        CoroutineHelper.StopAllCoroutines()
        LogW("与服务器断开连接...")
    end
end

-- 网络恢复时调用
-- 与OnNetworkLost相对
function OnNetworkReConnect()
    LogW("网络连接恢复...")
    PBHelper.Reset() -- 一定要重置网络模块
    g_Env.uiManager:CloseUI('LoadingUI')
    -- 先重新请求进入房间
    CLSLWHSender.Send_EnterRoomReq(OnEnterRoomAck)
    -- 再请求服务器数据
    CLSLWHSender.Send_GetServerDataReq(function(ack)
        if ack._errmessage then
            g_Env.CreateHintMessage(ack._errmessage)
        else
            gameView.ctrl:OnStateChangeNtf(ack)
        end
    end)
end

if IsRunInHall then
    Main()
else
    return function ()
        Main()
    end
end




