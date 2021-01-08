SubGame_Env = SubGame_Env or {}
GameConfig = GameConfig or require'Config' -- 在大厅模式下会传给小游戏这个数值
require "LuaUtil/LuaRequires"
local PBHelper = require'protobuffer.PBHelper'
local CLBCBMSender = require'protobuffer.CLBCBMSender'
local SceneView = require'View.Scene3DView'


if SUBGAME_EDITOR then
    -- 在大厅中将使用大厅的环境
    local playerRes = {diamond=0,currency=0,integral=0}
    SubGame_Env.playerRes = playerRes
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
}
PBHelper.Init('CLBCBM')
PBHelper.AddPbPkg('CLPF')

CLBCBMSender.Send_EnterRoomReq(function (data)
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
    print("SelfUserID = ", roomdata.self_user_id)
    SubGame_Env.playerRes.currency = roomdata.self_score
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






