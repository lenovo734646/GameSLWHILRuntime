SubGame_Env = SubGame_Env or {}
SubGame_Env.ConvertNumberToString = function (n)
    if n == nil then
        return ""
    end
    local unit = ''
    if n >= 10000 then
        n = n / 10000
        n = math.floor(n*100)/100
        unit = '万'
    elseif n >= 100000000 then
        n = n / 100000000
        n = math.floor(n*100)/100
        unit = '亿'
    end
    return n..unit
end


require "LuaUtil/LuaRequires"
GameConfig = GameConfig or require'Rebuild.Config' -- 在大厅模式下会传给小游戏这个数值

local PBHelper = require'protobuffer.PBHelper'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local SceneView = require'View.Scene3DView'
local Loader = require 'Rebuild.LuaAssetLoader'

local Sprite = UnityEngine.Sprite
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

CLSLWHSender.Send_EnterRoomReq(function (data)
    print('Send_EnterRoomAck:'..json.encode(data))
    if data.errcode ~= 0 then
        if SUBGAME_EDITOR then
            assert(false, 'errcode='..data.errcode)
        else
            -- TODO 错误提示,返回大厅
        end
        return
    end
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
    --
    SubGame_Env.loader = Loader.Create(GameConfig:GetSavePath("BCBM"), GameConfig.debug)
    SceneManager.LoadScene("MainScene")
end)

local gameView

function OnSceneLoaded(scene, mode)
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






