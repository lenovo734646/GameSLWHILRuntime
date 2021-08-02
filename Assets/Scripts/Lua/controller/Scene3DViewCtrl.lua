
local _G, g_Env = _G, g_Env
local class = class
local print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE, LogW,tonumber =
      print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE, LogW,tonumber

local _STR_ = _STR_
local math,pairs = math,pairs
local Vector3 = CS.UnityEngine.Vector3
local DOTween = CS.DG.Tweening.DOTween
local RotateMode = CS.DG.Tweening.RotateMode
local table = table
local tinsert = table.insert
local tremove = table.remove
local PrintTable = PrintTable

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local WaitForSeconds = UnityEngine.WaitForSeconds
local yield = coroutine.yield

local PBHelper = require 'protobuffer.PBHelper'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local GameConfig = require 'GameConfig'
local Helpers = require'LuaUtil.Helpers'

local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject
local RandomInt = UnityHelper.RandomInt
local RandomFloat = UnityHelper.RandomFloat

local Input = UnityEngine.Input
local clock = os.clock

local AudioManager = AudioManager or CS.AudioManager
local SEnv=SEnv

_ENV = moduledef { seenamespace = CS }
local Stopwatch = System.Diagnostics.Stopwatch.StartNew()

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(ui,View,roomdata)
    print("3D View Ctrl Init...roomdata.last_bet_id = ", roomdata.last_bet_id)
    self.ui = ui
    self.View = View
    self.roomdata = roomdata
    
    View:GetComponent(typeof(LuaUnityEventListener)):Init(self)
    View:GetComponent(typeof(KeyEventListener)):Init(self)
    --
    self.bet_config_array = roomdata.bet_config_array
    self.self_user_id = roomdata.self_user_id
    self.normal_show_time = roomdata.normal_show_time / 1000    -- 毫秒转秒
    self.shark_more_show_time = roomdata.shark_more_show_time / 1000 -- 毫秒转秒
    self.betid = roomdata.last_bet_id or 0
    --

    self.lastSeletedToggleIndex = 1
    self.lastCurrecy = SEnv.playerRes.currency

    self.timeStamp = clock()

    --监听下注选择事件
    ui.betSelectBtnsEventListener:Init{
        OnCustumEvent2 = function (_,params)
            self:OnBetSelect(params[0])
        end,
        OnCustumEvent = function (_,params)
            local eventName = params[0]
            self[eventName](self)
        end
    }
    ui.betAreaBtnsEventListener:Init{
        OnCustumEvent2 = function (_,params)
            self:OnBetClicked(params[0])
        end
    }

    --
    self.betSnapShot = {} -- 上一局押注数据(续押使用)
    -- 玩家上一次下注总值
    self.selfTotalBet = {}
    self.TotalBet = {}
    self:__ResetBetScore()
    --
    self.ratioArray = {}
    self.resultPanelData = {}

    self.gameCount = 0   -- 本次进入游戏局数

    self:InitAnimalAnimation()

    ui.directionallight_animationhelper:PlayByIndex(1)
    ui.pointlight_animationhelper:PlayByIndex(1)
end

-- showRedNuber: 是否显示红色数字，下注状态就显示，这里其实是gameState
function Class:PlayCountDownSound(time)
    if time > 5 then
        AudioManager.Instance:PlaySoundEff2D("TimerTick")
    else
        if self:IsBetState() then
            AudioManager.Instance:PlaySoundEff2D("alert")
        else
            AudioManager.Instance:PlaySoundEff2D("TimerTick")
        end
    end
end

--当组件DisableGameObjectsOnSceneLoaded完成后，会调用此方法
function Class:OnSceneReady()
    print('OnSceneReady')
    local ui = self.ui
    self.lastSeletedToggleIndex = 1
    self:OnMoneyChange(SEnv.playerRes.currency)
    -- 当前局输赢结果数据, 临时保存数据，结算结束再更新，避免刚进入结算界面就更新分数
    self.curWinResultData = { win = 0, bet_score = 0, self_score = SEnv.playerRes.currency,}
    -- 网络消息监听
    -- 游戏状态变化
    PBHelper.AddListener('StateChangeNtf', function (data)
        --print("StateChangeNtf ", data.state)
        self:OnStateChangeNtf(data)
    end)

    PBHelper.AddListener('CaiJinNtf', function (data)
        print("彩金消息: caijin_count = ", data.caijin_count)
        ui.mainUI:SetCaiJinCount(data.caijin_count)
    end)
    
    -- 玩家资源变化(金币,钻石，点卷，道具数)
    PBHelper.AddListener('CLPF.ResChangedNtf', function (data)
        --print("分数变化ResChangedNtf...", data.res_type, data.res_value, data.res_delta, data.reason)
        if data.res_type == 2 and data.reason == 42 then  -- 金币改变且是从银行取出
            local win = 0
            if self.resultPanelData and self.resultPanelData.winScore then
                win = self.resultPanelData.winScore
            end
            self:OnMoneyChange(data.res_value - win)
            self.selfScore = data.res_value -- 结算阶段缓存的玩家分数也要同步，不然分数会不同步
        end
    end)

    PBHelper.AddListener('CLPF.ResSyncNtf', function (data)
        print("分数同步ResSyncNtf...", data.currency) -- 此消息暂时不能收到
    end)

    -- 本局自己输赢和庄家输赢
    PBHelper.AddListener('SelfWinResultNtf', function (data)
        print("结算：玩家分数: ", data.self_score, data.win_score, data.bet_score)
        self.resultPanelData.winScore = data.win_score -- 本局输赢
        self.resultPanelData.betScore = data.bet_score  -- 总输赢
        self.selfScore = data.self_score
        if self.resultPanelData.winScore > 0 then
            AudioManager.Instance:PlaySoundEff2D("win_bet")
        end
    end)

    -- 其他玩家下注广播
    PBHelper.AddListener('OtherPlayerSetBetNtf', function (data)
        local item_id = data.info.index_id
        
        --print("OtherPlayerSetBetNtf...", item_id)
        if item_id == -1 then   -- 清除筹码返回
            local totalBetInfoList = data.room_tatol_bet_info_list
            for key, betInfo in pairs(totalBetInfoList) do
                local id = betInfo.index_id
                local total_bet = betInfo.total_bet
                local betAreaData = self.ui.betAreaList[id]
                --print("清除下注 id = ", id, total_bet)
                self:__SetTotalBetScore(betAreaData, total_bet)
            end
        else
            local total_bet = data.info.total_bet or 0
            -- 同步总押分
            local betAreaData = self.ui.betAreaList[item_id]
            self:__SetTotalBetScore(betAreaData, total_bet)
        end
    end)

    -- 在线人数
    PBHelper.AddListener("OnlinePlayerCountNtf", function (data)
        print("OnlinePlayerCountNtf: ", data.online_count)
        self.ui.topUI:UpdateOnlinePlayerCount(data.online_count)
    end)


    -- 统计数据
    PBHelper.AddListener("StatisticDataNtf", function (data)
        --print("统计数据："..json.encode(data))
        self.ui.mainUI:SetStatisticData(data.SixiCount, data.SanYuanCount, data.ZhuangCount, 
                                        data.XianCount, data.HeCount, data.AllGameCount)
    end)
    --
    local roomdata = self.roomdata
    -- 根据上局中奖下标同步转盘和指针角度
    local zhizhenRot = (roomdata.last_color_index -1)*15
    local animalIndex = roomdata.last_color_index - roomdata.last_animal_index 
    if animalIndex < 0 then
        animalIndex = animalIndex + GameConfig.RunItemCount
    end
    local animalRot = (animalIndex)*15
    -- print("同步指针角度:", roomdata.last_color_index, zhizhenRot)
    -- print("同步动物角度:", roomdata.last_animal_index, animalIndex, animalRot)
    self.ui.arrow_transform.localEulerAngles = Vector3(0, zhizhenRot, 0)
    self.ui.animal_rotate_root_transform.localEulerAngles = Vector3(0, animalRot, 0)

    -- 状态处理
    local selfTotalBet = roomdata.self_bet_list
    local totalBet = roomdata.room_tatol_bet_info_list
    -- 同步下注
    for _, info in pairs(selfTotalBet) do
        local betAreaData = ui.betAreaList[info.index_id]
        self:__SetSelfBetScore(betAreaData, info.total_bet)
    end
    for _, info in pairs(totalBet) do
        local betAreaData = ui.betAreaList[info.index_id]
        self:__SetTotalBetScore(betAreaData, info.total_bet)
    end

    -- 发送请求历史路单数据
    CLSLWHSender.Send_HistoryReq(function (data)
        print('HistoryAck:'..json.encode(data))
        local record_list = data.record_list
        local list = {}
        for _,info in ipairs(record_list)do
            local result = info.ressult_info_list[1] 
            local songDengInfo = info.ressult_info_list[2]
            local songDengColorID = nil
            local songDengAnimalID = nil
            if songDengInfo ~= nil then
                songDengColorID = songDengInfo.winColor
                songDengAnimalID =  songDengInfo.winAnimal
            end
            local itemData = ui:GetHistoryIconData(result.winColor, result.winSanYuanColor, result.winAnimal, info.win_enjoyGameType, info.win_exType,
                                                    songDengColorID, songDengAnimalID)
            tinsert(list, itemData)
        end
        ui.roadScrollView:ReplaceItems(list)
    end)

    -- 主动请求游戏状态数据
    CLSLWHSender.Send_GetServerDataReq(function(ack)
        if ack._errmessage then
            g_Env.CreateHintMessage(ack._errmessage)
        else
            self:OnStateChangeNtf(ack)
        end
    end)
    -- --print("OnSceneReady: 状态 = ", state, left_time)
    -- --self:OnStateChangeNtf({ left_time = left_time, state = state })
    -- --需要下注阶段发来的倍率表和颜色表，
    -- --所以刚进入无论什么状态都要等到下一轮下注状态，才能正常进行游戏
    -- self.ui.mainUI:SetWaitNextStateTip(true)
 
    
    -- --修正时间差
    -- local passTime = clock()-self.timeStamp
    -- self.timeStamp = nil
    -- local left_time = left_time-passTime
    -- if left_time > 2 then
    --     self.ui.mainUI.timeCounter:StartCountDown(left_time, state, function (time)
    --         self:PlayCountDownSound(time)
    --     end)
    -- end

end


function Class:OnAnimalTrigger(index)
    self.curIconPosIndex = index
end



function Class:OnBetSelect(toggle)
    -- print('OnBetSelect',toggle)
    if toggle.isOn then
        -- local betSelectToggles = self.ui.betSelectToggles
        local betid = tonumber(toggle.name)
        self.betid = betid
        print('OnBetSelect ',toggle, ' betid ',betid)
        if not self.dontRecordPlayerSeletBet then
            self.lastSeletedToggleIndex = betid+1
            print('Record OnBetSelect',toggle, ' betid ',betid)
        end
    end
end

-- 加载完成，进入游戏，初始化创建各个动作方法
function Class:InitAnimalAnimation()
    local ui = self.ui
    local runItemDataList = ui.runItemDataList
    local len = #runItemDataList
    self.runItemDataList = runItemDataList
    self.runItemDataListLen = len
    for i=1,len do
        local data = runItemDataList[i]
        data.uictrl = self
        local winShowData = data.winShowData
        --动画控制，切换两个空闲状态动画
        data.PlayIdle = function () -- 播放空闲动画
            data.StopAnim()
            data.animco = CoroutineHelper.StartCoroutine(function ()
                while true do
                    local delayTime = RandomFloat(0,2)
                    yield(WaitForSeconds(delayTime))
                    data.animatorHelper:Play("Idel1")
                    yield(WaitForSeconds(data.animatorHelper:GetDuration("Idel1")))
                end
            end)
        end
        data.StopAnim = function () -- 停止动画
            if data.animco then
                CoroutineHelper.StopCoroutine(data.animco)
                data.animco = nil
            end
        end
        data.PlayShow = function () -- 跟中奖同时播放
            data.StopAnim()
            winShowData.gameObject:SetActive(true)
            winShowData.animatorHelper:Play("Victory")
            -- 播放声音
            local color_id = self.resultPanelData.color_id
            --print("播放声音：", self.resultPanelData.color_id)
            assert(color_id)
            local animal_id = self.resultPanelData.animal_id
            if color_id == GameConfig.ColorType.SanYuan then
                AudioManager.Instance:PlaySoundEff2D("dasanyuan")
            elseif color_id == GameConfig.ColorType.SiXi then
                AudioManager.Instance:PlaySoundEff2D("dasixi")
            else
                local audioIndex = self:__GetBetItemLuaIndex(color_id, animal_id)
                --print("PlayWin Sound ", color_id, animal_id, audioIndex)
                AudioManager.Instance:PlaySoundEff2D(GameConfig.WinSound[audioIndex])
            end
        end
        data.StopShow = function ()
            winShowData.gameObject:SetActive(false)-- 一直在显示，不需要隐藏
            data.PlayIdle()
        end

    end
end

function Class:OnCustumEvent(params)
    local eventName = params[0]
    if eventName=='CameraMoved' then
        print('CameraMoved')
    elseif eventName == 'On2_1Mode' then
        --针对超宽屏进行优化
        self.ui.gameObject.transform.localScale = _G.Vector3(1.03,1,1)
    end
end

function Class:IsBetState()
    return self.state == GameConfig.GameState.BET
end

function Class:IsShowState()
    return self.state == GameConfig.GameState.SHOW
end

function Class:IsFreeState()
    return self.state == GameConfig.GameState.FREE
end

function Class:OnStateChangeNtf(data, isReconnection)
    if isReconnection then
        self.ui.mainUI.resultPanel:HideResult()
    end
    local state = data.state
    self.state = state
    if self:IsBetState() then --下注
        self.ui.mainUI:SetWaitNextStateTip(false)
        self:OnBetState(data)
    elseif self:IsShowState() then --开奖
        self:OnShowState(data)
    else -- 空闲
        self:OnFreeState()
    end
    --
    self.ui.mainUI.timeCounter:StartCountDown(data.left_time, state, function (time)
        self:PlayCountDownSound(time)
    end)
end

function Class:PlayIdleStateAnim()
    for i=1,self.runItemDataListLen do
        local data = self.runItemDataList[i]
        data.PlayIdle()
    end
end

function Class:StopIdleStateAnim()
    for i=1,self.runItemDataListLen do
        local data = self.runItemDataList[i]
        data.StopAnim()
    end
end

function Class:OnBetClicked(luaInitHelper)
    local betAreaData = luaInitHelper.t
    local item_id = betAreaData.item_id

    if self.notEnoughMoney then
        SEnv.MessageBox({ content = _STR_"金币不足，是否打开银行取款?", 
            onOK = function()
                self.ui.mainUI:On_btn_Bank_Event()
            end,
            showCancel = true,
        })
        return
    end
    --发送下注
    self:OnSendBet(item_id, self.betid)
end

function Class:OnContinueBtnClicked()
    -- print('OnContinueBtnClicked 续押测试...1000')
    -- for i = 1, 8, 1 do
    --     self.betSnapShot[i] = 1000
    -- end
    if self:__GetContinueBetScore() <= 0 then
        _G.ShotHintMessage(_STR_"上局无下注")
        return 
    end
    for item_id, betScore in pairs(self.betSnapShot) do  -- 共有几个下注区域需要下注
        local betData = self:ConvertBetScoreToBetIndex(betScore)
        for _, data in pairs(betData) do    -- 共有几种筹码需要下注
            local betid = data.betid
            local count = data.count
            for i = 1, count, 1 do  -- 每个筹码下注次数
                self:OnSendBet(item_id, betid)
            end
        end
    end
end

function Class:OnClearBtnClicked()
    print('OnClearBtnClicked')
    self:OnSendBet(-1)
end

-- 把押注分数转换为筹码数量
function Class:ConvertBetScoreToBetIndex(betScore)
    local betScoreList = self.bet_config_array -- 下标 1-6

    local betData = {}
    for i = #betScoreList, 1, -1 do
        -- print("betScoreList[i] = ", betScoreList[i], i)
        if betScore >= betScoreList[i] then
            -- local aa = betScore/betScoreList[i]
            local c = math.floor(betScore / betScoreList[i])
            betScore = betScore - c * betScoreList[i]
            -- print("i = "..i.."  商"..c.."  剩余"..betScore)
            tinsert(betData, {betid = i - 1, count = c})
        end
    end
    return betData
end
-- 设置动物倍率和颜色（下注阶段或断线重连后）
function Class:SetColorAndRatio(colorArray, ratioArray)
    local ui = self.ui
    if #colorArray ~= 0 then
        -- 设置颜色
        print("颜色表：", json.encode(colorArray))
        for index, value in ipairs(colorArray) do
            ui.colorDataList[index].colorMesh.material = ui.colorMeshMaterialList[value]
        end
    end
    if #ratioArray ~= 0 then
        print("倍率表：", json.encode(ratioArray))
        self.ratioArray = ratioArray   
        -- 设置倍率（包含庄和闲）
        local count = #ui.betAreaList
        for i = 1, count, 1 do
            ui.betAreaList[i].ratioText.text = ratioArray[i]
        end
    end
end

-- 下注阶段
function Class:OnBetState(data)
    print("进入下注阶段....")
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('betState')
    AudioManager.Instance:PlaySoundEff2D("start_bet")
    self:DoCheckForBetButtonState()--判断并禁用钱不够的可选筹码按钮

    if data.color_array == nil or data.ratio_array == nil then
        LogE("OnBetState: data.color_array == nil or data.ratio_array == nil ")
        return
     end
     self:SetColorAndRatio(data.color_array, data.ratio_array)
end

-- 游戏阶段（转和显示结果）
function Class:OnShowState(data)
    print("进入结算阶段....")
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('showState')
    AudioManager.Instance:PlaySoundEff2D("stop") 
    ui.directionallight_animationhelper:PlayByIndex(1)
    ui.pointlight_animationhelper:PlayByIndex(1)
    --
    if #data.color_array == 0 or #data.ratio_array == 0 then
        if #self.ratioArray == 0 then
            LogE("OnShowState: data.color_array == nil or data.ratio_array == nil self.ratioArray = nil")
            return
        end
    else
        self:SetColorAndRatio(data.color_array, data.ratio_array)
        self.ratioArray = data.ratio_array
    end
    --
    local ColorType = GameConfig.ColorType
    local ExWinType = GameConfig.ExWinType
    local AnimalType = GameConfig.AnimalType
    --
    local resultInfo = data.anim_result_list[1]
    local songDengInfo = data.anim_result_list[2]
    local winColor = resultInfo.color_id
    local winSanYuanColor = resultInfo.sanyuan_color_id
    local winAnimal = resultInfo.animal_id
    local winEnjoyGameType = data.enjoy_game_ret
    local exType = data.ex_ret
    print("=====OnShowState=======:")
    print("庄和闲结果: ", winEnjoyGameType)
    print("颜色结果: ", winColor)
    print("动物结果: ", winAnimal)
    print("大三元颜色结果: ", winSanYuanColor)
    print("额外大奖结果：", exType)
    print("彩金倍率：", data.caijin_ratio)
    print("闪电倍率：", data.shandian_ratio)
    if exType == ExWinType.SongDeng then
        print("送灯奖励：", songDengInfo.color_id, songDengInfo.animal_id, self:__GetRatio(songDengInfo.color_id, songDengInfo.animal_id))
    end
    

    -- 统计结果
    -- 庄闲和小游戏
    local enjoyGameData = {
        enjoyGame_id = winEnjoyGameType,
        enjoyGameRatio = self:__GetEnjoyGameRatio(winEnjoyGameType),
    }
    self.resultPanelData.enjoyGameData = enjoyGameData
    -- 颜色(普通中奖+三元四喜)
    
    if winColor == ColorType.SanYuan then
        local animalRatioArray = {}
        for i = AnimalType.Lion, AnimalType.Rabbit, 1 do
            tinsert(animalRatioArray, self:__GetRatio(winSanYuanColor, i))
        end
        local sanyuanData = {
            sanyuanColor_id = winSanYuanColor,
            animalRatioArray = animalRatioArray,
        }
        self.resultPanelData.sanyuanData = sanyuanData

    elseif winColor == ColorType.SiXi then
        local animalRatioArray = {}
        for i = ColorType.Red, ColorType.Yellow, 1 do
            tinsert(animalRatioArray, self:__GetRatio(i, winAnimal))
        end
        local sixiData = {
            animal_id =  winAnimal,
            animalRatioArray = animalRatioArray,
        }
        self.resultPanelData.sixiData = sixiData
    else
        local normalData = {
        animal_id = winAnimal,
        ratio = self:__GetRatio(winColor, winAnimal)
        }
        self.resultPanelData.normalData = normalData
    end
    -- 额外大奖
    
    if exType == ExWinType.CaiJin then
        self.resultPanelData.caijin_ratio = data.caijin_ratio
    elseif exType == ExWinType.LiangBei or exType == ExWinType.SanBei then
        self.resultPanelData.shandian_ratio = data.shandian_ratio
    elseif exType == ExWinType.SongDeng then
        local songdengData = {
            songDengColorID = songDengInfo.color_id,
            songDengAnimalID = songDengInfo.animal_id,
            songDengRatio = self:__GetRatio(songDengInfo.color_id, songDengInfo.animal_id)
        }
        self.resultPanelData.songdengData = songdengData
    end
    self.resultPanelData.color_id = winColor
    assert(winColor)
    self.resultPanelData.animal_id = winAnimal
    self.resultPanelData.exType = exType
    
    -- 小老虎机转动
    ui.slot:Run111(winEnjoyGameType)
    -- 停止动物动画
    self:StopIdleStateAnim()
    local anim_result_list = data.anim_result_list
    if anim_result_list then
        -- -- 检查剩余时间是否足够进行动画（断线重连可能在任意状态中任意时间恢复，会导致状态剩余时间不同）
        -- -- 剩余时间小于(结算界面+动画展示 + 2)直接显示结果，不进行动画
        local bSkip = false -- 是否跳过跑马灯动画，如果时间不够就跳过
        local winItemCount = #anim_result_list -- 中奖动物数量
        local leftTime = data.left_time
         -- 跑马灯动画时间
        local ShowRunTime = leftTime - (GameConfig.ShowResultTime + GameConfig.ShowZhanShiTime*winItemCount)
        if ShowRunTime <= 1 then -- 跑马灯时间小于1 就不跑了
            bSkip = true
        end
        print("leftTime = ", leftTime, " bSkip = ", bSkip, "ShowRunTime = ", ShowRunTime, "winItemCount = ", winItemCount)
        --
        local ShowResultTime = GameConfig.ShowResultTime
        local ShowZhanShiTime = GameConfig.ShowZhanShiTime
        local ShowRunTime_Shark = self.shark_more_show_time - GameConfig.ShowZhanShiTime -- 减去展示时间，只要跑马灯时间
        if bSkip == false then
            if winItemCount > 1 then
                local t1 = ShowRunTime - ShowRunTime_Shark
                if t1 < 1 then -- 减掉送灯跑马灯时间，留给第一圈的时间小于 1 时间就平分
                    ShowRunTime = ShowRunTime/2
                    ShowRunTime_Shark = ShowRunTime
                else
                    ShowRunTime = t1
                end
            end
        else
            -- 结算界面显示时间
            if leftTime <= GameConfig.ShowResultTime then
                ShowZhanShiTime = 0
                ShowResultTime = leftTime
            else
                ShowZhanShiTime = leftTime - GameConfig.ShowResultTime
            end
        end
        --local winItemDataList = {} -- 记录本次所有中奖动物itemData
        CoroutineHelper.StartCoroutine(function ()
            for i=1, winItemCount do
                local indexdata = anim_result_list[i]
                local colorFrom,colorTo = indexdata.color_form,indexdata.color_to
                local animalFrom, animalTo = indexdata.animal_form, indexdata.animal_to
                local itemData = self.runItemDataList[animalTo]
                --print("data.left_time = ", data.left_time)
                if not bSkip then
                    local round = 2
                    local showTime = ShowRunTime
                    if i > 1 then -- 送灯
                        round = 0
                        showTime = ShowRunTime_Shark
                    end
                    yield(self:DoTweenShowResultAnim(colorFrom, colorTo, animalFrom, animalTo, round, showTime))--播放转盘动画
                    itemData.PlayShow() -- 播放动物胜利动画
                    yield(WaitForSeconds(GameConfig.ShowZhanShiTime))
                    ui.winStage_huaban_animatorhelper:SetBool("bClose", true) -- 播放花瓣关闭动画
                    ui.winStageAnimal:DOPlayBackwards()   -- 播放中奖动物收回动画
                    --
                    local colordata = self.ui.colorDataList[colorTo]
                    colordata.animator:Play("BaoshiFlash", 0, 0)
                    colordata.animator:Update(0)
                    colordata.animator.enabled = false  -- 停止中奖颜色播放闪烁动画
                else
                    -- 这里播放也看不到，需要把花瓣打开，舞台升起才能看到，但是时间可能不够，这里就暂时不显示了
                    --itemData.PlayShow() -- 播放动物胜利动画
                end
            end
            -- 如果跳过了跑马灯动画，并且扣除结算界面显示时间，还有剩余，就等一等，避免结算界面提前消失
            if bSkip then
                if ShowZhanShiTime > 0 then
                    yield(WaitForSeconds(ShowZhanShiTime))
                    --itemData.StopShow() -- 停止播放动物胜利动画
                end
            end
            
            -- 禁用聚光灯动画和宝石动画
            self.ui.SpotLight_Animal_animator.gameObject:SetActive(false)
            self.ui.SpotLight_Animal_animator.enabled = false
            self.ui.Baoshi_1_animator.enabled = false
            -- 显示中奖结算界面
            local resultPanel = self.ui.mainUI.resultPanel
            resultPanel:ShowResult(self.resultPanelData)
            yield(WaitForSeconds(ShowResultTime))
            resultPanel:HideResult()
            if winColor == GameConfig.ColorType.SanYuan or winColor == GameConfig.ColorType.SiXi then
                AudioManager.Instance:StopAllSoudEff()   -- 三元四喜音乐太长这里截断（或看情况做其他处理）
            end
            self.resultPanelData = {}   -- 清空结果数据避免冗余干扰

            -- 开启聚光灯动画和宝石动画
            self.ui.SpotLight_Animal_animator.enabled = true
            self.ui.Baoshi_1_animator.enabled = true
            self.ui.SpotLight_Animal_animator.gameObject:SetActive(true)
            -- 同步玩家分数
            print("同步玩家分数: ", self.selfScore)
            self:OnMoneyChange(self.selfScore)

            -- 开奖结束再更新record，避免剧透
            local sdColor, sdAnimal = nil,nil
            if songDengInfo ~= nil then
                sdColor = songDengInfo.color_id
                sdAnimal = songDengInfo.animal_id
            end
            ui.roadScrollView:InsertItem(ui:GetHistoryIconData(winColor, winSanYuanColor, winAnimal, winEnjoyGameType, exType,
                                                                sdColor, sdAnimal, data.caijin_ratio))
        end)
    end
end


-- 开奖逻辑（从开始转到显示结算界面）
function Class:DoTweenShowResultAnim(colorFromindex, colorToindex, animalFromindex, animalToindex, round, time)
    round = round or 3
    time = time or GameConfig.ShowAnimationTime
    local ui = self.ui

    local colorDataList = ui.colorDataList
    local len = #colorDataList
    local rotCount = colorFromindex - colorToindex  -- 逆时针转
    if rotCount < 0 then
        rotCount = rotCount + len
    end
    local colorTotalWillRunCount = rotCount + len*round
    if colorTotalWillRunCount < len then
        colorTotalWillRunCount=colorTotalWillRunCount+len
    end

    local arrow_transform = ui.arrow_transform
    local colorStartRot = (colorFromindex - 1)*15
    arrow_transform.eulerAngles = Vector3(0, colorStartRot, 0)
    local arrowTotalRot = colorTotalWillRunCount*15
    --

    local curve =  GameConfig.Ease[RandomInt(1,#GameConfig.Ease)]
    CoroutineHelper.StartCoroutine(function ()
        yield(arrow_transform:DORotate(Vector3(0, -arrowTotalRot, 0), time - 1, RotateMode.LocalAxisAdd)
        :SetEase(curve):WaitForCompletion())
        local colordata = colorDataList[colorToindex]
        colordata.animator.enabled = true  -- 播放中奖颜色闪烁动画
    end)

    -- 
    local realAnimalToIndex = colorToindex - animalToindex 
    if realAnimalToIndex < 0 then
        realAnimalToIndex = realAnimalToIndex + GameConfig.RunItemCount
    end
    local runItemDataList = ui.runItemDataList
    local len = #runItemDataList
    local animalTotalWillRunCount = realAnimalToIndex - animalFromindex + len*round
    if animalTotalWillRunCount < len then
        animalTotalWillRunCount=animalTotalWillRunCount+len
    end

    local animalStartRot = (animalFromindex)*15
    local animalRotRoot_transform = ui.animal_rotate_root_transform
    animalRotRoot_transform.eulerAngles = Vector3(0, animalStartRot, 0)
    local animalTotalRot = animalTotalWillRunCount*15
    
    local curve =  GameConfig.Ease[RandomInt(1,#GameConfig.Ease)]

    return CoroutineHelper.StartCoroutine(function ()
        local dur = time  -- 错开一点不同时停止
        --print("动物开转 = ", animalTotalRot, dur, time)
        yield(animalRotRoot_transform:DORotate(Vector3(0, animalTotalRot, 0), dur, RotateMode.LocalAxisAdd)
        :SetEase(curve):WaitForCompletion())
        local animaldata = runItemDataList[animalToindex]
        
        animaldata.animatorHelper:Play("Victory") -- 中奖动物播放胜利动画
        ui.winStage_huaban_animatorhelper:SetBool("bClose", false) -- 播放花瓣打开动画
        ui.winStageAnimal:DOPlayForward()   -- 播放中奖动物升起动画
        yield()
    end)

    
end

-- 空闲阶段
function Class:OnFreeState()
    if self.resultPanelData then
        self.resultPanelData.winScore = 0 -- 本局输赢
        self.resultPanelData.betScore = 0  -- 总输赢
    end
    self.selfScore = SEnv.playerRes.currency
    --
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('freeState')
    ui.directionallight_animationhelper:PlayByIndex(2)
    ui.pointlight_animationhelper:PlayByIndex(2)
    self:PlayIdleStateAnim()
    -- 如果上一局有下注，则刷新续押数据，否则不变
    if self:__GetSelfAllBetScore() > 0 then
        self.betSnapShot = {}   -- 清空原数据
        for key, value in pairs(self.selfTotalBet) do
            self.betSnapShot[key] = value
        end
    end
    self:__ResetBetScore()
    self.ui.mainUI:SetCurBetScore(0) -- 清0 UI下注分数
    AudioManager.Instance:PlaySoundEff2D("vs_alert")

    self.gameCount = self.gameCount +1
    self.ui.mainUI:SetGameCount(self.gameCount)
end

function Class:OnNetWorkReConnect()
    print("========OnNetWorkReConnect=======================")
    self.ui.mainUI:SetWaitNextStateTip(true)
end

function Class:OnMoneyChange(currency)
    SEnv.playerRes.currency = currency
    self:DoCheckForBetButtonState(currency)
    self.lastCurrecy = currency
    self.ui.mainUI.userInfo:OnChangeMoney(currency)
    
end

function Class:DoCheckForBetButtonState(currency)
    self.dontRecordPlayerSeletBet = true
    --逻辑思路：当金币不足以选择当前选择的下注的时候，选择可以下的最高的一个
    --         如果资金恢复到记录的选项，那么选择记录的选项
    local ui = self.ui
    local betSelectToggles = ui.betSelectToggles
    local bet_config_array = self.bet_config_array
    currency = currency or SEnv.playerRes.currency
    

    local toggleCanOnTable = {true, true, true, true, true, true}
    local len = #bet_config_array
    local endableCount = 0
    local maxCanEnableIndex = -1
    for i = len, 1, -1 do
        local value = bet_config_array[i]
        local canEndable = currency >= value
        toggleCanOnTable[i] = canEndable
        if maxCanEnableIndex < 0 and canEndable then
            endableCount = endableCount + 1
            maxCanEnableIndex = i
        end
    end
    local disableAllToggle = endableCount == 0
    for i = len, 1, -1 do
        local toggle = betSelectToggles[i]
        local canEndable = toggleCanOnTable[i]
        toggle.interactable = canEndable
        if not canEndable then
            if toggle.isOn then
                toggle.isOn = false
                if maxCanEnableIndex > 0 then
                    betSelectToggles[maxCanEnableIndex].isOn = true
                end
            end
        end
    end
    --print(self.lastSeletedToggleIndex)
    if self.lastSeletedToggleIndex <= maxCanEnableIndex then
        betSelectToggles[self.lastSeletedToggleIndex].isOn = true
    else
        if maxCanEnableIndex > 0 then
            betSelectToggles[maxCanEnableIndex].isOn = true
        end
    end
    ui.SelectEffect:SetActive(not disableAllToggle)

    -- 判断金币是否足够续押
    ui.continue_button.interactable = self:__GetContinueBetScore() <= currency
    self.notEnoughMoney = currency < bet_config_array[1]

    self.dontRecordPlayerSeletBet = false
end



-- 押注网络协议处理
function Class:OnSendBet(item_id, betid)
    -- 用下面这个StartCoroutineGo发送会导致ack顺序不能保证，会导致下注ack返回顺序错误，导致玩家分数错误
    -- CoroutineHelper.StartCoroutineGo(self.View, function()
    --     local data = CLSLWHSender.Send_SetBetReq_Async(item_id, betid, _G.ShowErrorByHintHandler)
    --     if data then
    --         self:OnReceiveBetAck(data)
    --     end
    -- end)
    -- 暂时改用下面这种方法发送
    CLSLWHSender.Send_SetBetReq(function (ack)
        if ack._errmessage then
            if g_Env then
                g_Env.ShowHitMessage(ack._errmessage)
            end
        else
            self:OnReceiveBetAck(ack)
        end
    end,item_id, betid)
end

function Class:OnReceiveBetAck(data)
    print("玩家下注返回：玩家分数: ", data.self_score)
    local betAreaList = self.ui.betAreaList
    local self_bet_info = data.self_bet_info
    local item_id = self_bet_info.index_id
    if item_id == -1 then
        for _, betAreaData in pairs(betAreaList) do
            self:__SetSelfBetScore(betAreaData, 0)
        end
    else
        local total_bet = self_bet_info.total_bet
        local betAreaData = betAreaList[item_id]
        --
        self:__SetSelfBetScore(betAreaData, total_bet)
        AudioManager.Instance:PlaySoundEff2D("betSound")
    end
    self:OnMoneyChange(data.self_score)
    local score = self:__GetSelfAllBetScore()
    self.ui.mainUI:SetCurBetScore(score)
end

-- 获取中奖动物倍率
function Class:__GetRatio(color_id, animal_id)
    color_id = color_id -1
    animal_id = animal_id -1
    local index = color_id * 4 + animal_id +1
    local ratio = self.ratioArray[index]
    return ratio
end

-- 获取中奖庄和闲倍率
function Class:__GetEnjoyGameRatio(ret)
    local index = 12 + ret
    local ratio = self.ratioArray[index]
    return ratio
end

-- 获取下注项的Index（lua数组下标从1开始）
-- color_id ： 下注颜色：GameConfig.ColorType，从1开始
-- animal_id : 下注动物：：GameConfig.AnimalType, 从1开始
function Class:__GetBetItemLuaIndex(color_id, animal_id)
    color_id = color_id -1
    animal_id = animal_id -1
    local index = color_id * GameConfig.AnimalCount + animal_id;
    return index +1;
end

-- 设置自己下注分数
function Class:__SetSelfBetScore(betAreaData, total_bet)
    assert(betAreaData)
    betAreaData.selfBetScore.text = Helpers.GameNumberFormat(total_bet)
    local item_id = betAreaData.item_id
    self.selfTotalBet[item_id] = total_bet
end
-- 设置全体下注分数
function Class:__SetTotalBetScore(betAreaData, total_bet)
    assert(betAreaData)
    betAreaData.totalBetScore.text = Helpers.GameNumberFormat(total_bet)
    local item_id = betAreaData.item_id
    self.TotalBet[item_id] = total_bet
end

-- 重置所有下注分数
function Class:__ResetBetScore()
    for _, betAreadata in pairs(self.ui.betAreaList)do
        self:__SetSelfBetScore(betAreadata, 0)
        self:__SetTotalBetScore(betAreadata, 0)
    end
end

-- 获取自己当前总下注
function Class:__GetSelfAllBetScore()
    local score = 0
    for key, value in pairs(self.selfTotalBet) do
        score = score + value
    end
    return score
end


-- 获取续押需要消耗的总分
function Class:__GetContinueBetScore()
    local score = 0
    for _,v in pairs(self.betSnapShot) do
        score=score+v
    end
    return score
end


return _ENV