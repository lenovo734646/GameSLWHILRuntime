SubGame_Env = SubGame_Env or {}
RUN_IN_TEST_MODE = true
print('运行在无网络测试模式')
GameConfig = GameConfig or require'Config' -- 在大厅模式下会传给小游戏这个数值
require "LuaUtil/LuaRequires"


local SceneView = require'View.Scene3DView'
local CoroutineHelper = require'CoroutineHelper'

if SUBGAME_EDITOR then
    local playerRes = {diamond=0,currency=0,integral=0}
    SubGame_Env.playerRes = playerRes
end

SceneManager.LoadScene("MainScene")


local roomdata = {
    last_bet_id = 1,
    bet_config_array = {1000,10000,100000,500000,1000000,5000000},
    state = 2,
    left_time = 0,
    room_tatol_bet_info_list = {},
    self_bet_list = {},
    result_list = {},
    self_score = 0,
}
function OnSceneLoaded(scene, mode)
    if scene.name == "MainScene" then
        local View = SceneView.Create(roomdata)
        local ctrl = View.ctrl

        local TimerCounterUI = require'UI.TimerCounterUI'
                local timeCounter = TimerCounterUI.Create(View.GameTimeCounterInitHelper)

        local KeyListener = View.gameObject:GetComponent(typeof(CS.KeyEventListener))
        KeyListener.keyDownList:Add(UnityEngine.KeyCode.A)
        local co = coroutine.create(function ()
            -- ctrl:OnBetState()
            while true do
                -- ctrl:OnMoneyChange(100000000)
                -- coroutine.yield()
                -- ctrl:OnMoneyChange(100000)
                -- coroutine.yield()
                -- ctrl:OnMoneyChange(100000000)
                -- coroutine.yield()
                -- ctrl:OnMoneyChange(0)
                print('freeState')
                View.viewEventBroadcaster:Broadcast('freeState')
                coroutine.yield()
                View.viewEventBroadcaster:Broadcast('betState')
                coroutine.yield()
                View.viewEventBroadcaster:Broadcast('showState')
                coroutine.yield()
            end
            -- ctrl:OnFreeState()
            -- coroutine.yield()
        end)
        KeyListener:Init{
            OnKeyDown = function (t, params)
                local code = params[0]
                -- print(code)
                coroutine.resume(co)
                
                
                --timeCounter:StartCountDown(5, true)
            end
        }
    end
end









