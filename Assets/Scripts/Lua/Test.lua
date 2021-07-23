SEnv = SEnv or {}
RUN_IN_TEST_MODE = true
print('运行在无网络测试模式')
GameConfig = GameConfig or require'Config' -- 在大厅模式下会传给小游戏这个数值
require "LuaUtil/LuaRequires"


local SceneView = require'View.Scene3DView'
local CoroutineHelper = require'LuaUtil.CoroutineHelper'

local GameConfig = require'GameConfig'

if SUBGAME_EDITOR then
    local playerRes = {diamond=0,currency=0,integral=0}
    SEnv.playerRes = playerRes
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
        local KeyListener = View.gameObject:GetComponent(typeof(CS.KeyListener))
        KeyListener.keyDownList:Add(UnityEngine.KeyCode.A)

        local index = 1
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
                -- print('freeState')
                -- View.eventBroadcaster:Broadcast('freeState')
                -- coroutine.yield()
                -- View.eventBroadcaster:Broadcast('betState')
                -- coroutine.yield()
                -- View.eventBroadcaster:Broadcast('showState')
                -- coroutine.yield()
                -- 动物音效测试
                --AudioManager.Instance:PlaySoundEff2D(GameConfig.WinSound[index])
                index = index +1
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
            end
        }
    end
end









