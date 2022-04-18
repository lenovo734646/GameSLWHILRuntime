SEnv = SEnv or {}
RUN_IN_TEST_MODE = true
Log('运行在无网络测试模式')
GG.GameConfig = GG.GameConfig or require'Config' -- 在大厅模式下会传给小游戏这个数值

local hintMessage = GG.LuaHintMessage.Create()
-- 小游戏统一提示函数
ShowTips = function(...)
    if IsRunInHall then
        g_Env.ShowTips(...)
    else
        hintMessage:CreateHintMessage(...)
    end
end
-- require'Prepare'
_STR_ = _STR_ or function(str)
    return str
end

_ERR_STR_ = _ERR_STR_ or function (errStr)
    return errStr
end


require "LuaUtil/LuaRequires"
local SceneView = require'View.Scene3DView'
local MessageCenter = require "Message.MessageCenter"
SEnv.LanguageConvert = require'Table.LanguageConvert'
SEnv.messageCenter = MessageCenter()


local GameObject = GS.UnityEngine.GameObject
local DDOLGameObject = GameObject.Find('DDOLGameObject')
if not DDOLGameObject then
    DDOLGameObject = GameObject('DDOLGameObject')
end
DDOLGameObject:AddComponent(typeof(GS.MessageCenter))
DDOLGameObject:AddComponent(typeof(GS.AudioManager))
DDOLGameObject:AddComponent(typeof(GS.NetController))
GS.UnityEngine.Object.DontDestroyOnLoad(DDOLGameObject)
AudioManager = GS.AudioManager



SEnv.loader = require'LuaAssetLoader'.Create()
if 1 then
        -- 在大厅中将使用大厅的环境
        local playerRes = {diamond=0,currency=0,integral=0, selfUserID = 0, userName = "", headID = 0, headFrameID = 0}
        SEnv.playerRes = playerRes

        SEnv.AutoUpdateHeadImage = function (img, headID, selfUserID)
            img.sprite = SEnv.GetHeadSprite(headID)
        end
    
        SEnv.GetHeadSprite = function (headID)
            -- return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/head_"..(headID+1)..".png", typeof(Sprite))
        end
    
        SEnv.GetHeadFrameSprite = function (headFrameID)
            -- return SEnv.loader:Load("Assets/ForReBuild/Res/PlazaUI/Common/Head/headFrame_"..(headFrameID+1)..".png", typeof(Sprite))
        end
        -- local commonSounds = SEnv.loader:Load("Assets/Resources/commonSounds.prefab")
        -- CS.UnityEngine.Object.DontDestroyOnLoad(_G.Instantiate(commonSounds)) -- 公共音频资源
        -- Log("SUBGAME_EDITOR!")
end

GS.SceneManager.LoadScene("MainScene")

local roomCfg = {
    room_id = 1,
    room_name = "初级房",
    free_time = 3,
    bet_time = 15,
    wait_show_time = 3,
    show_time = 13,
    more_show_time = 5,
    min_enter_score = 0,
    kick_out_score = -1,
    kick_out_no_bet_count = 0,
    tax_rate = 0,
    room_bet_limit = -1,
    user_area_bet_limit = -1,
    user_all_bet_limit = -1,
    bet_list = {1000,10000,100000,500000,1000000,5000000},
}

SEnv.self_bet_info_list = {}
SEnv.room_total_bet_info_list = {}

SEnv.playerRes = {
    currency = 9999000,
    selfUserID = 1000001,
    userName = "本地测试",
    headID = 1,
    headFrameID = 1,
    last_bet_id = nil,
}

local gameView
function OnSceneLoaded(scene, mode)
    if scene.name == "MainScene" then
        gameView = SceneView.Create(roomCfg)
        local ctrl = gameView.ctrl
    end
end

function _OnAKeyDown()
    if gameView then
        local data = {
            state = 2,
            left_time = 3,
        }
        if gameView.ctrl.carRunTween then
            gameView.ctrl.carRunTween:Kill()
        end
        gameView.ctrl:OnWaitShowState(data)
    end
end

function _OnSKeyDown()
    if gameView then
        -- if gameView.ctrl.carRunTween then
        --     gameView.ctrl.carRunTween:Kill()
        -- end
    end
end

function OnCloseSubGame()
    
end








