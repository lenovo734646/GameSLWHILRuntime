SubGame_Env = SubGame_Env or {}
SubGame_Env.ConvertNumberToString = function (n)
    if n == nil then
        return ""
    end
    local unit = ''
    if n >= 100000000 then
        n = n / 100000000
        n = math.floor(n*100)/100
        unit = '亿'
    elseif n >= 10000 then
        n = n / 10000
        n = math.floor(n*100)/100
        unit = '万'
    end
    return n..unit
end

SubGame_Env.ShowHitMessage = function (contentStr)
    if g_Env then
        g_Env.ShowHitMessage(contentStr)
    else
        print(contentStr)
    end
end


RUN_IN_TEST_MODE = true
print('运行在无网络测试模式')

require "LuaUtil/LuaRequires"
Config = Config or require'Rebuild.Config' -- 在大厅模式下会传给小游戏这个数值
local GameConfig = require'GameConfig'
local Loader = require 'Rebuild.LuaAssetLoader'


local SceneView = require'View.Scene3DView'
local CoroutineHelper = require'CoroutineHelper'

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
end
SubGame_Env.loader = SubGame_Env.loader or Loader.Create(Config:GetSavePath("SLWH"), Config.debug)
SubGame_Env.loader:LoadSoundsPackage('Assets/AssetsFinal/SLWHSounds.prefab')
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
    normal_show_time = 13000,
    shark_more_show_time = 5000,

    last_color_index = 2,
    last_animal_index = 1,
}
function OnSceneLoaded(scene, mode)
    if scene.name == "MainScene" then
        local View = SceneView.Create(roomdata)
        local ctrl = View.ctrl

        local KeyListener = View.gameObject:GetComponent(typeof(CS.KeyListener))
        KeyListener.keyDownList:Add(UnityEngine.KeyCode.A)
        local co = coroutine.create(function ()
            while true do
                local betStateData = {
                    left_time = 5000,
                    state = 1,
                 -- animal_Array = 2,1,3,4,2,  1,3,4,2,1,   3,4,2,1,3,   4,2,1,3,4,   2,1,3,4
                    color_array = {3,3,1,2,3,  3,2,1,2,2,   2,3,1,2,3,   3,1,3,1,3,   1,3,2,3},
                    ratio_array = {10,20,30,40, 11,22,33,44,     111,222,333,444,  110,220,330},
                }
                ctrl:OnStateChangeNtf(betStateData)
                
                coroutine.yield()
    
                local resultAnimIndex = {
                    {
                        color_form = 2,
                        color_to = 3,
                        animal_form = 1,
                        animal_to = 2,

                        color_id = 1,
                        animal_id = 1,
                        sanyuan_color_id = 0,
                    },
                    -- 送灯
                    {
                        color_form = 3,
                        color_to = 23,
                        animal_form = 2,
                        animal_to = 24,

                        color_id = 2,
                        animal_id = 4,
                    }
                }
    
                local showStateData = {
                    left_time = 13000,
                    state = 2,
                    anim_result_list = resultAnimIndex,
                    enjoy_game_ret = 2,
                    ex_ret = GameConfig.ExWinType.SongDeng,
                    caijin_ratio = 0,
                    shandian_ratio = 0,
    
                }
    
                ctrl:OnStateChangeNtf(showStateData)
                coroutine.yield()
            end
            
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









