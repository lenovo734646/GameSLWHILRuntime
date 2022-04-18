SEnv = SubGame_Env --必须放到文件第一行
SEnv.roomCfg = {}
require'Prepare'
require "LuaUtil/LuaRequires"
SEnv.CountDownTimerManager = GG.CountDownTimerManager
SEnv.messageCenter = GG.MessageCenter()
--
function Main()
    Log("SLWH Lua Main")

    GG.PBHelper.Init('CLSLWH')
    GG.PBHelper.AddPbPkg('CLCHATROOM')
    _WaitSubGameLoadDone = true

    if g_Env == nil then
        -- 在大厅中将使用大厅的环境
        -- local playerRes = {diamond=0,currency=0,integral=0, selfUserID = 0, userName = "", headID = 0, headFrameID = 0}
        -- SEnv.playerRes = playerRes
        SEnv.playerRes = {}
        SEnv.AutoUpdateHeadImage = function (img, headID, selfUserID)
            img.sprite = SEnv.GetHeadSprite(headID)
        end
    
        SEnv.GetHeadSprite = function (headID)
            return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/head_"..(headID+1)..".png", typeof(GS.Sprite))
        end
    
        SEnv.GetHeadFrameSprite = function (headFrameID)
            return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/headFrame_"..(headFrameID+1)..".png", typeof(GS.Sprite))
        end
        local commonSounds = SEnv.loader:Load("Assets/Resources/commonSounds.prefab")
        GS.UnityEngine.Object.DontDestroyOnLoad(GS.Instantiate(commonSounds)) -- 公共音频资源
        Log("SUBGAME_EDITOR!")
    end
    SEnv.loader:LoadScene('RoomSelectScene')
    _WaitSubGameLoadDone = false
end


--
local SceneList = {"MainScene"}
local AssetList = {
    "Assets/AssetsFinal/EmojiPics.prefab"
}
local SoundPkgList = {
    'Assets/AssetsFinal/commonSound.prefab',
    'Assets/AssetsFinal/voice_'..GS.SysDefines.curLanguage..'.prefab',
    'Assets/AssetsFinal/phrase_'..GS.SysDefines.curLanguage..'_Sound.prefab',
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
    local mask = GS.SysDefines.curLanguage=='EN' and '_EN' or ''
    local texpath = texpath_without_ext .. mask .. '.png'
    local tex = loader:LoadAsync(texpath)
    return mat:SetTexture(texidname, tex)
end

-- EnterRoomReq 回应处理
local OnEnterRoomAck = function(enterRoomAckData)
    Log('Send_EnterRoomAck:'..json.encode(enterRoomAckData))
    -- 重新申请当前房间的配置信息，避免房间配置更新之后玩家在游戏内各个房间进出无法拿到最新的房间配置信息
    local roomCfgData, err = GG.CLSLWHSender.Send_RoomConfigReq_Async(enterRoomAckData.room_id)
    Log("roomCfgData:", json.encode(roomCfgData))
    if err then
        -- 获取房间信息失败 返回房间选择列表
        local errmsg = _STR_("获取房间信息失败"..":roomid:"..tostring(enterRoomAckData.room_id).."err:"..tostring(err))
        ShowErrMsgBoxAndExitGame(errmsg)
        return false
    else
        local roomCfg = roomCfgData.room_config
        SEnv.roomCfg.banker_condition = roomCfg.banker_condition
        SEnv.roomCfg.room_bet_limit = roomCfg.room_bet_limit
        SEnv.roomCfg.user_area_bet_limit = roomCfg.user_area_bet_limit
        SEnv.roomCfg.user_all_bet_limit = roomCfg.user_all_bet_limit
        SEnv.roomCfg.bet_list = roomCfg.bet_list
        SEnv.roomCfg.free_time = roomCfg.free_time
        SEnv.roomCfg.bet_time = roomCfg.bet_time
        SEnv.roomCfg.wait_show_time = roomCfg.wait_show_time
        SEnv.roomCfg.show_time = roomCfg.show_time
        SEnv.roomCfg.more_show_time = roomCfg.more_show_time
        Log("SEnv.roomCfg.more_show_time = ", SEnv.roomCfg.more_show_time, "SEnv.roomCfg.show_time = ", SEnv.roomCfg.show_time)
    end

    for key, value in pairs(roomCfgData.room_config.bet_list) do
        Log("bet_list: "..key..",  "..value)
    end
    -- 获取房间成功之后再赋值
    SEnv.self_bet_info_list = enterRoomAckData.self_bet_info_list
    SEnv.room_total_bet_info_list = enterRoomAckData.room_total_bet_info_list

    SEnv.playerRes.currency = enterRoomAckData.self_score
    SEnv.playerRes.selfUserID = enterRoomAckData.self_user_id
    SEnv.playerRes.userName = enterRoomAckData.self_user_name
    SEnv.playerRes.headID = enterRoomAckData.self_user_Head
    SEnv.playerRes.headFrameID = enterRoomAckData.self_user_HeadFrame
    SEnv.playerRes.last_bet_id = enterRoomAckData.last_bet_id
    Log("进入房间成功:UserID = ", SEnv.playerRes.selfUserID, SEnv.playerRes.headID, "currency:", SEnv.playerRes.currency, "headID:", SEnv.playerRes.headID)
    return true
end

local gameView
function OnSceneLoaded(scene, mode)
    if scene.name == "RoomSelectScene" then
        gameView = nil
        GG.CoroutineHelper.StartCoroutine(function ()
            local data, err = GG.CLSLWHSender.Send_AllRoomConfigReq_Async()
            Log('111Send_AllRoomConfigReq_Async:', json.encode(data))
            -- Log("data.errcode:", data.errcode)
            if data.errcode ~= 0 then
                if g_Env then
                    g_Env.MessageBox{
                        content = err,
                        onOK = function()
                            g_Env.SubGameCtrl.Leave()
                        end
                    }
                else
                    Log('获取房间信息失败: ', err)
                end
                return false
            else
                -- 根据房间信息创建房间界面
                -- local data = {
                --     errcode = 0,
                --     game_config = {repeated_room = 0},
                --     room_config_list = {
                --         {room_id = 1, room_name = "初级房1", min_enter_score = 100},
                --         {room_id = 2, room_name = "初级房2", min_enter_score = 100},
                --         {room_id = 3, room_name = "初级房3", min_enter_score = 100},
                --         {room_id = 4, room_name = "初级房4", min_enter_score = 100},
                --         {room_id = 5, room_name = "初级房5", min_enter_score = 100},
                --         {room_id = 11, room_name = "中级房1", min_enter_score = 200},
                --         {room_id = 12, room_name = "中级房2", min_enter_score = 200},
                --         {room_id = 13, room_name = "中级房3", min_enter_score = 200},
                --         {room_id = 14, room_name = "中级房4", min_enter_score = 200},
                --         {room_id = 15, room_name = "中级房5", min_enter_score = 200},
                --         {room_id = 21, room_name = "高级房1", min_enter_score = 300},
                --         {room_id = 22, room_name = "高级房2", min_enter_score = 300},
                --         {room_id = 23, room_name = "高级房3", min_enter_score = 300},
                --         {room_id = 24, room_name = "高级房4", min_enter_score = 300},
                --         {room_id = 25, room_name = "高级房5", min_enter_score = 300},
                --     },
                -- }
                local OnRoomEnterSuccess = function (enterRoomAckData)
                    local success = OnEnterRoomAck(enterRoomAckData)
                    if not success then
                        Log("非重连进入房间失败....")
                        return 
                    end
                    Log("进入房间成功 room_id = ", data.room_id, "开始加载 LoadingScene")
                    SEnv.loader:LoadScene('LoadingScene')
                end
                GG.FQZS_RoomSelectView.Create(data, OnRoomEnterSuccess)
            end
        end)
    end

    if scene.name == "LoadingScene" then
        GG.CoroutineHelper.StartCoroutine(function ()
            -- 进度处理和资源加载
            local sliderGo = GS.GameObject.Find("Slider")
            local slider = sliderGo:GetComponent("Slider")
            slider.value = 0.25
            local loader = SEnv.loader
            local allLoadCount = GetLoadCount()
            local loadedCount = 0
            local updateProgress = function ()
                loadedCount = loadedCount+1
                slider.value = (loadedCount/allLoadCount)
                --Log("加载进度：", loadedCount, allLoadCount, slider.value)
            end
            --先加载和设置多语言纹理
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/庄1.mat','Assets/Dance/Xiazhu/Tex/Zhuang','_MainTex')
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/闲1.mat','Assets/Dance/Xiazhu/Tex/Xian','_MainTex')
            loadMatTexByLangAsync('Assets/Dance/Xiazhu/Tex/和1.mat','Assets/Dance/Xiazhu/Tex/He','_MainTex')
            for k, v in pairs(LoadList) do7
                if k == 1 then
                    for _, assetPath in pairs(v) do
                        Log("加载Asset：path = ", assetPath)
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
                        Log("加载场景：", sceneName)
                        GS.SceneManager.LoadSceneAsync(sceneName)
                        updateProgress()
                    end
                end
            end
            --#region
        end)
    end
    if scene.name == "MainScene" then
        gameView = GG.FQZS_View.Create(SEnv.roomCfg)
        if SEnv.isLostConnect then
            OnNetworkLost()
        end
    end
end

local TEST_IsNetConnectLost = nil   -- 模拟断网收不到消息
local OnReceiveNetData = GG.PBHelper.OnReceiveNetData
function OnReceiveNetDataPack(data, packname)
    -- if TEST_IsNetConnectLost then
    --     return
    -- end
    OnReceiveNetData(data, packname)
    
end

-- 退出游戏时调用：如果有必要可用来清理场景，关闭UI等
function OnCloseSubGame()
    Log("退出小游戏 OnCloseSubGame...")
    GG.PBHelper.RemoveAllListener()
    if gameView then
        gameView:Release()
        gameView = nil
        SEnv.messageCenter:RemoveAllListener()
        SEnv = SubGame_Env
        SEnv.roomCfg = {}
    end
    if SEnv.CountDownTimerManager then
        SEnv.CountDownTimerManager.Clear()
    end
end

-- 返回选房间界面
function ReturnToSelectRoom()
    Log("============>ReturnToSelectRoom<============")
    GS.AudioManager.Instance:StopMusic()
    GS.AudioManager.Instance:StopEffect()
    OnCloseSubGame()
    SEnv.loader:LoadScene('RoomSelectScene') -- 返回选房间界面
end

function ShowErrMsgBoxAndExitGame(_errmessage)
    if g_Env then
        g_Env.MessageBox{
            content = _errmessage,
            onOK = function()
                g_Env.SubGameCtrl.Leave()
            end
        }
    else
        Log('进入房间失败: ', _errmessage)
    end
end

local LogW = LogW
-- 网络断开时调用，此时小游戏应该立即停止所有正在进行的协程和游戏进程，等待网络恢复
-- 这里的网络中断和g_Env._SubGameReconnection并不相同
-- g_Env._SubGameReconnection是在玩家强制退出游戏或者意外退出游戏时恢复用
-- 这里的中断是在游戏过程中网络中断，是互联网断开，不是与服务器断开
function OnNetworkLost()
    SEnv.isLostConnect = true
    SEnv.gamePause = true
    if gameView then
        local LoadingUI = g_Env.uiManager:OpenUI('LoadingUI')
        if GS.Application.internetReachability == GS.UnityEngine.NetworkReachability.NotReachable then
            LoadingUI:SetTipText(_G._STR_ '网络已断开，网络恢复将继续游戏...')
            GG.CoroutineHelper.StopAllCoroutines()
            if SEnv.CountDownTimerManager then
                SEnv.CountDownTimerManager.Clear()
            end
            LogW("网络连接断开...")
        else
            LoadingUI:SetTipText(_G._STR_ '与服务器断开连接，等待恢复中...')
            GG.CoroutineHelper.StopAllCoroutines()
            LogW("与服务器断开连接...")
        end
    end
end

-- 网络恢复时调用
-- 与OnNetworkLost相对
function OnNetworkReConnect()
    SEnv.isLostConnect = nil
    LogW("网络连接恢复...")
    if gameView then
        GG.PBHelper.Reset() -- 一定要重置网络模块
        g_Env.uiManager:CloseUI('LoadingUI')
        GG.CoroutineHelper.StopAllCoroutines()
        -- 先重新请求进入房间
        GG.CLSLWHSender.Send_EnterRoomReq(function (data)
            if not data._errmessage then
                OnEnterRoomAck(data)
            else
                ShowErrMsgBoxAndExitGame(data._errmessage)
            end
        end)
        -- 再请求路单(这里防止加载的时候断网，导致OnSceneReady中的请求发送失败，这里补上)
        GG.CLSLWHSender.Send_HistoryReq(function (data)
            gameView.ctrl:OnHistroyAck(data)
        end)
        -- 再请求服务器数据
        GG.CLSLWHSender.Send_GetServerDataReq(function(ack)
            if ack._errmessage then
                g_Env.CreateHintMessage(ack._errmessage)
            else
                SEnv.gamePause = nil
                gameView.ctrl:OnStateChangeNtf(ack, true)
            end
        end)
    end

end
-- 进入后台事件
local pauseTimestamp = 0
local lastStateLeftTime = nil
function OnApplicationPause(b)
    if b then -- 进入后台
        Log("SLWH 进入后台...")
        SEnv.gamePause = true
        pauseTimestamp = UnityHelper.GetTimeStampSecond()
        if gameView then
            if gameView.mainUI then
                gameView.mainUI:OnCancelInput()-- 取消语音输入和文字输入
            end
            lastStateLeftTime = gameView.mainUI.timeCounter.time -- 保存进入后台前的状态剩余时间
            Log("lastStateLeftTime = ", lastStateLeftTime)
        end
    else
        Log("SLWH 进入前台...")
        local tempTime = UnityHelper.GetTimeStampSecond()
        local passTime = tempTime - pauseTimestamp + 1 -- 加一秒冗余，避免小数情况判断不到 
        Log("passTime = ", passTime, "lastStateLeftTime = ", lastStateLeftTime)
        if passTime > lastStateLeftTime or passTime > 3 then
            GG.CoroutineHelper.StopAllCoroutines() -- 确定要重新刷新数据才停止所有协程
            GG.CLSLWHSender.Send_HistoryReq(function (data)
                gameView.ctrl:OnHistroyAck(data)
            end)
            GG.CLSLWHSender.Send_GetServerDataReq(function(ack)    -- 这里短时间内不能多次请求，应记录游戏状态和时间，同一状态判断时间间隔（避免转一轮过去），不同状态直接请求
                if ack._errmessage then
                    g_Env.CreateHintMessage(ack._errmessage)
                else
                    SEnv.gamePause = nil
                    gameView.ctrl:OnStateChangeNtf(ack, true)
                end
            end)
        else
            SEnv.gamePause = nil
        end
    end
end

function OnApplicationFocus(b)
    Log("SLWH 失去焦点...")
    if not b then -- 失去焦点，手机上切到后台不会调用这个函数而是调用 OnApplicationPause
        if gameView then
            if gameView.mainUI then
                gameView.mainUI:OnCancelInput()-- 取消语音输入和文字输入
            end
        end
    else
        -- 有焦点
        Log("SLWH 获得焦点...")
    end
    -- 测试模拟切后台行为
    -- OnApplicationPause(not b)
end

-- 这里可以自定义滚动公告栏的位置和宽度
if g_Env then
    g_Env.systemNoticeCtrl:SetSystemNoticePosition(0, -120)
    g_Env.systemNoticeCtrl:SetSystemNoticeWidth(840)
end
-- 根据协议错误码和协议名获取错误描述
GetServerErrorMsg = function (errcode, msgName)
    if IsRunInHall then
        return g_Env.GetServerErrorMsg(errcode, msgName)
    else
        return "小游戏独立运行:".. tostring(msgName).. "errcode:".. tostring(errcode)
    end
end

local hintMessage = GG.LuaHintMessage.Create()
-- 小游戏统一提示函数
ShowTips = function(...)
    if IsRunInHall then
        g_Env.ShowTips(...)
    else
        hintMessage:CreateHintMessage(...)
    end
end
if IsRunInHall then
    Main()
else
    local bPause = false
    -- 测试函数
    function _OnAKeyDown()
        if gameView then
            -- OnApplicationPause(true)
            -- TEST_IsNetConnectLost = true
            gameView.cameraCtrl:ToShowPoint()
        end
    end

    function _OnSKeyDown()
        if gameView then
            -- OnApplicationPause(false)
            -- TEST_IsNetConnectLost = nil
            gameView.cameraCtrl:ToNormalPoint()
        end
    end
    return function ()
        Main()
    end
end




