SubGame_Env = {}
RUN_IN_TEST_MODE = true
print('运行在无网络测试模式')
GameConfig = GameConfig or require'Config' -- 在大厅模式下会传给小游戏这个数值
require'Prepare'
require "LuaUtil/LuaRequires"
SEnv.CountDownTimerManager = require 'controller.CountDownTimerManager'

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local Helpers = require 'LuaUtil.Helpers'
local GameConfig = require'GameConfig'
local floor = math.floor

local DDOLGameObject = GameObject.Find('DDOLGameObject')
if not DDOLGameObject then
    DDOLGameObject = GameObject('DDOLGameObject')
end
DDOLGameObject:AddComponent(typeof(CS.AudioManager))
AudioManager = CS.AudioManager

SUBGAME_EDITOR = true
if SUBGAME_EDITOR then
    SEnv.loader = require'LuaAssetLoader'.Create()
    local playerRes = {diamond=0,currency=9000000,integral=0, selfUserID = 11111, userName = "Test", headID = 1, headFrameID = 1}
    SEnv.playerRes = playerRes

    SEnv.AutoUpdateHeadImage = function (img, headID, selfUserID)
        img.sprite = SEnv.GetHeadSprite(headID)
    end

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

local SceneView = require'View.Scene3DView'
local CameraCtrl = require'controller.CameraCtrl'


-- -- 测试下载
-- local download_url = "https://game-oss-hotupdate-test.oss-cn-beijing.aliyuncs.com/HotUpdate_TEST/111.txt"
-- CoroutineHelper.StartCoroutine(function ()
--     local request = Helpers.WebRequestGet(download_url)
--     request:SendWebRequest()
--     while (not request.isDone) do
--         yield()
--         -- TODO: 显示正在下载提示 和 下载进度
--         -- req.ui:SetTipText(_G._STR_ '正在同步...' .. floor2(request.downloadProgress * 100) .. '%')
--         print("正在下载...")
--     end
--     if not string.IsNullOrEmpty(request.error) then
--         --_G.ShotHintMessage(_ERR_STR_(request.error))
--         print("下载出错:", request.error)
--         return
--     end
--     local data = request.downloadHandler.data
--     print("下载成功...", #data, data)
--     -- -- 下载成功 转换成 audioClip
--     -- audioClip = self.voicePanel:ByteToAudioClip(request.downloadHandler.data)
--     -- --audioClip = self.voicePanel:ByteToAudioClip(content)
--     -- print("语音数据转换成AudioClip:", audioClip)
-- end)


-- 定时器测试
local CountDownTimerManager = require 'controller.CountDownTimerManager'
local timerID = nil
local countDownFinishCallback = function (time, b)
        print("Tick time = ", time, "bFinish = ", b)
        if b then
            if time <= 0 then
                print("倒计时完成结束")
            else
                print("倒计时中途停止结束,剩余时间", time)
            end
        end
end

-- 测试函数
function _OnAKeyDown()
    if SUBGAME_EDITOR then
        print("CountDownTimerManager = ", CountDownTimerManager)
        timerID = CountDownTimerManager.StartCountDown(10, countDownFinishCallback, 0.1)
        -- CoroutineHelper.StartCoroutine(function ()
        --     while not bFinish do
        --         yield(WaitForSeconds(0.5))
        --         local timer = CountDownTimerManager.GetTimer(id)
        --         if timer then
        --             print("timer.id = "..timer.id, "leftTime = "..timer.leftTime)
        --         end
        --     end
        --     print("22222222222倒计时结束")
        --     local timer = CountDownTimerManager.GetTimer(id)
        --     print("timer = ", timer)
        --     print("222222222222timer.id = ", timer.id, "timer.isFinish = ", timer.isFinish, "timer.co = ", timer.co)
        -- end)

        -- OnTestShowState(8)
        -- local data = { -- 空闲状态
        --     left_time = 3,                            -- 此状态的剩余时间 2开奖状态时间应该是不固定的
        --     state = 3,  
        -- }
        -- gameView.ctrl:OnStateChangeNtf(data)
    end
end

SEnv.TestProcessEnd = true
function _OnSKeyDown()
    if SUBGAME_EDITOR then
        print("SEnv.CountDownTimerManager = ", SEnv.CountDownTimerManager)
        SEnv.CountDownTimerManager.Clear()
        -- CountDownTimerManager.Clear()
        -- if gameView then
        --     -- gameView.mainUI:OnStateChange(2)
        --     AutoTest()
        -- end
    end
end

-- local id, co = CountDownTimerManager.StartCountDown(10, function (time, b)
--     print("Tick time = ", time, "bFinish = ", bFinish)
--     bFinish = b
--     if b then
--         print("倒计时结束")
--     end
-- end)
-- local timer = CountDownTimerManager.GetTimer(id)
-- print("111111111111111timer.id = ", timer.id, "timer.isFinish = ", timer.isFinish, "timer.co = ", timer.co)




-- 小游戏测试
-- SceneManager.LoadScene("MainScene")
-- local roomdata = {
--     bet_config_array = {1000,10000,100000,500000,1000000,5000000},
--     state = 1,
--     left_time = 0,
--     last_bet_id = 1,
--     normal_show_time = 20,
--     shark_more_show_time = 25,
--     self_score = 0,
--     online_player_count = 1,

--     room_total_bet_info_list = {},
--     self_bet_info_list = {},

--     self_user_id = 0,
--     self_user_name = "测试111",
--     self_user_Head = 0,
--     self_user_HeadFrame = 0,

--     last_color_index = 1,
--     last_animal_index = 1,
-- }
-- local gameView
-- local cameraco
-- local itemData
-- function OnSceneLoaded(scene, mode)
--     if scene.name == "MainScene" then

--         gameView = SceneView.Create(roomdata)
--         local ctrl = gameView.ctrl
--         local KeyListener = gameView.gameObject:GetComponent(typeof(CS.KeyListener))
--         KeyListener.keyDownList:Add(UnityEngine.KeyCode.A)

--         local index = 1
--         local co = coroutine.create(function ()
--             -- ctrl:OnBetState()
--             while true do
--                 -- ctrl:OnMoneyChange(100000000)
--                 -- coroutine.yield()
--                 -- ctrl:OnMoneyChange(100000)
--                 -- coroutine.yield()
--                 -- ctrl:OnMoneyChange(100000000)
--                 -- coroutine.yield()
--                 -- ctrl:OnMoneyChange(0)
--                 -- print('freeState')
--                 -- View.eventBroadcaster:Broadcast('freeState')
--                 -- coroutine.yield()
--                 -- View.eventBroadcaster:Broadcast('betState')
--                 -- coroutine.yield()
--                 -- View.eventBroadcaster:Broadcast('showState')
--                 -- coroutine.yield()
--                 -- 动物音效测试
--                 --AudioManager.Instance:PlaySoundEff2D(GameConfig.WinSound[index])
--                 index = index +1
--                 coroutine.yield()
--             end
--             -- ctrl:OnFreeState()
--             -- coroutine.yield()
--         end)
--         KeyListener:Init{
--             OnKeyDown = function (t, params)
--                 local code = params[0]
--                 -- print(code)
--                 coroutine.resume(co)
--             end
--         }

--         cameraco = coroutine.create(function ()
--             while true do
--                 gameView.cameraCtrl:ToNormalPoint()
--                 coroutine.yield()
--                 gameView.cameraCtrl:ToRotatePoint()
--                 coroutine.yield()
--                 gameView.cameraCtrl:ToShowPoint()
--                 coroutine.yield()
--             end
--         end)
--         gameView.cameraCtrl:ToNormalPoint()
--         itemData = gameView.runItemDataList[1]
--         print("22gameView = ", gameView, cameraco)
--     end
-- end
-- print("11gameView = ", gameView, cameraco)


-- local OnTestShowState = function (time)
--     if gameView and cameraco then
--         -- coroutine.resume(cameraco)
--         -- gameView.cameraCtrl:ToNormalPoint()

--         local SelfWinResultNtfData = {
--             win_score = 0,         --本局输赢
--             bet_score = 0,    -- 本局下注
--             self_score = SEnv.playerRes.currency   -- 自己分数
--         }
--         gameView.ctrl:OnSelfWinResultNtf(SelfWinResultNtfData)
--         --
--         local data = {
--             left_time = time,                            -- 此状态的剩余时间 2开奖状态时间应该是不固定的
--             state = 2,                                -- 状态 1=下注 2=开奖 3=空闲 
--             color_array = {3,2,3,3,1,3,2,3,3,1,1,1,2,3,1,2,2,2,3,1,3,2,2,3},                          -- 颜色列表1-24
--             ratio_array = {46,23,13,8,35,17,10,6,28,14,8,5,2,8,2},                 -- 倍率列表1-12动物 13-15庄和闲
--             anim_result_list = {
--                 -- 第一个结果
--                 {
--                     color_form = 1,
--                     color_to = 10,
                
--                     animal_form = 1,
--                     animal_to = 10,
                
--                     color_id = 1,       -- 中奖颜色ID（红、绿、黄、三元、四喜） 
--                     animal_id = 1,      -- 中奖动物ID
--                     sixi_color_id = nil,-- 四喜的中奖颜色ID
--                 }, 
--                 -- 第二个结果
--                 {
--                     color_form = 10,
--                     color_to = 1,
                
--                     animal_form = 10,
--                     animal_to = 1,
                
--                     color_id = 3,       -- 中奖颜色ID（红、绿、黄、三元、四喜） 
--                     animal_id = 2,      -- 中奖动物ID
--                     sixi_color_id = nil,-- 四喜的中奖颜色ID
--                 }, 

--                 -- -- 第三个结果
--                 -- {
--                 --     color_form = 1,
--                 --     color_to = 10,
                
--                 --     animal_form = 1,
--                 --     animal_to = 10,
                
--                 --     color_id = 1,       -- 中奖颜色ID（红、绿、黄、三元、四喜） 
--                 --     animal_id = 1,      -- 中奖动物ID
--                 --     sixi_color_id = nil,-- 四喜的中奖颜色ID
--                 -- }, 
--                 -- -- 第四个结果
--                 -- {
--                 --     color_form = 10,
--                 --     color_to = 1,
                
--                 --     animal_form = 10,
--                 --     animal_to = 1,
                
--                 --     color_id = 3,       -- 中奖颜色ID（红、绿、黄、三元、四喜） 
--                 --     animal_id = 2,      -- 中奖动物ID
--                 --     sixi_color_id = nil,-- 四喜的中奖颜色ID
--                 -- }, 

--             },                       --开奖结果列表（RunItem起始点和结束点），正常只有一个，如果有送灯会有多个
--             enjoy_game_ret = 1,                       -- 庄闲和开奖结果
--             -- ex_ret = 5,                               -- 额外中奖结果（1彩金，2送灯，3两倍，4三倍，5没中）
--             ex_ret = 2, 
--             caijin_ratio = 0,                         -- 彩金倍数
--             shandian_ratio = 0,                        -- 闪电翻倍倍数
--             --int64 betMaxLimit = 10;                          -- 本局下注最大限制（防止超过庄家分数）
--             --int64 time_stamp = 10;          -- 消息时间戳

--         }
--         gameView.ctrl:OnStateChangeNtf(data)
--     else

--     end
-- end

-- function AutoTest()
--     local time = 15
--     local count = 0 
--     CoroutineHelper.StartCoroutine(function ()
--         while time > 0 do
--             -- print("SEnv.TestProcessEnd = ", SEnv.TestProcessEnd)
--             if SEnv.TestProcessEnd == true then
--                 time = time -1
--                 count =  count +1
--                 print("开始测试:time = ", time, count)
--                 OnTestShowState(time)
--                 SEnv.TestProcessEnd = false
--             end
--             yield()
--         end
--         print("时间为0 测试结束....")
--     end)
-- end

-- -- 退出游戏时调用：如果有必要可用来清理场景，关闭UI等
-- function OnCloseSubGame()

-- end






