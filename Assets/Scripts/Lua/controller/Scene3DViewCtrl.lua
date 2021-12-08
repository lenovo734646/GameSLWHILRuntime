
local _G, g_Env = _G, g_Env
local class = class
local print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE, LogW,tonumber =
      print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE, LogW,tonumber

local _STR_ = _STR_
local math,pairs = math,pairs
local Vector3 = CS.UnityEngine.Vector3
local DOTween = CS.DG.Tweening.DOTween
local Ease = CS.DG.Tweening.Ease
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

local ColorType = GameConfig.ColorType
local ExWinType = GameConfig.ExWinType
local AnimalType = GameConfig.AnimalType

local Stopwatch = System.Diagnostics.Stopwatch.StartNew()
local winItemDataList = {} -- 记录本次所有中奖动物itemData
local bSkip = false -- 是否跳过跑马灯动画，如果时间不够就跳过
--
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
    self.normal_show_time = roomdata.normal_show_time / 1000 -- 毫秒转秒
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
    self.selfBetMap = {} -- 自己下注
    self.totalBetMap = {} -- 总下注
    self:__ResetBetScore()
    --
    self.ratioArray = {} -- 缓存当前局的动物倍率表，结算时获取倍率用
    self.resultPanelData = {} -- 缓存当前局的结算信息，方便结算和显示

    self.gameCount = 0   -- 本次进入游戏局数

    self:InitAnimalAnimation()

    ui.directionallight_animationhelper:PlayByIndex(1)
    ui.pointlight_animationhelper:PlayByIndex(1)
end

-- showRedNuber: 是否显示红色数字，下注状态就显示，这里其实是gameState
function Class:PlayCountDownSound(time)
    if self:IsBetState() then
        if time == 5 then
            AudioManager.Instance:PlaySoundEff2D("alert")
        end
        if time < 5 then
            AudioManager.Instance:PlaySoundEff2D("TimerTick")
        end
    end
    -- if time > 5 then
    --     AudioManager.Instance:PlaySoundEff2D("TimerTick")
    -- else
    --     if self:IsBetState() then
    --         AudioManager.Instance:PlaySoundEff2D("alert")
    --     else
    --         AudioManager.Instance:PlaySoundEff2D("TimerTick")
    --     end
    -- end
end

--当组件DisableGameObjectsOnSceneLoaded完成后，会调用此方法
function Class:OnSceneReady()
    print('OnSceneReady')
    local ui = self.ui
    self.lastSeletedToggleIndex = 1
    self:OnMoneyChange(SEnv.playerRes.currency)
    -- 当前局输赢结果数据, 临时保存数据，结算结束再更新，避免刚进入结算界面就更新分数
    -- self.curWinResultData = { win = 0, bet_score = 0, self_score = SEnv.playerRes.currency,}
    -- 网络消息监听
    -- 游戏状态变化
    PBHelper.AddListener('StateChangeNtf', function (data)
        --print("StateChangeNtf ", data.state)
        self:OnStateChangeNtf(data)
    end)

    PBHelper.AddListener('CaiJinNtf', function (data)
        -- print("彩金消息: caijin_count = ", data.caijin_count)
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
        self:OnSelfWinResultNtf(data)
    end)

    -- 其他玩家下注广播
    PBHelper.AddListener('OtherPlayerSetBetNtf', function (data)
        local item_id = data.info.index_id
        
        --print("OtherPlayerSetBetNtf...", item_id)
        if item_id == -1 then   -- 清除筹码返回
            local totalBetInfoList = data.room_total_bet_info_list
            for key, betInfo in pairs(totalBetInfoList) do
                local id = betInfo.index_id
                local total_bet = betInfo.total_bet
                self:__SetTotalBetScore(id, total_bet)
            end
        else
            -- 同步总押分
            local total_bet = data.info.total_bet or 0
            self:__SetTotalBetScore(item_id, total_bet)
        end
        -- 更新玩家列表的本局下注
        self.ui.mainUI:UpdatePlayerTotalBets(data.user_id, data.total_bets)
    end)

    -- 在线人数  
    PBHelper.AddListener("OnlinePlayerCountNtf", function (data)
        self.ui.mainUI:UpdateOnlinePlayerCount(data.online_count)
    end)
    -- 玩家列表胜利次数
    PBHelper.AddListener("PlayerWinCountInfoNtf", function (data)
        self.mainUI:UpdateOnlinePlayerCount(data.player_winCount_info_list)
    end)



    -- 统计数据
    PBHelper.AddListener("StatisticDataNtf", function (data)
        --print("统计数据："..json.encode(data))
        self.ui.mainUI:SetStatisticData(data.SixiCount, data.SanYuanCount, data.ZhuangCount, 
                                        data.XianCount, data.HeCount, data.AllGameCount)
    end)
    --
    local roomdata = self.roomdata
    self:__SetArrowAndAnimalRot(roomdata.last_color_index, roomdata.last_animal_index)
    --
    self:SendHistoryReq()
    self:ResetView(roomdata)
    self:PlayIdleStateAnim() -- 开启空闲动画，避免中途加入时动物都是不动的
    -- 主动请求游戏状态数据
    CLSLWHSender.Send_GetServerDataReq(function(ack)
        if ack._errmessage then
            g_Env.CreateHintMessage(ack._errmessage)
        else
            self:OnStateChangeNtf(ack)
        end
    end)
end


function Class:OnAnimalTrigger(index)
    self.curIconPosIndex = index
end



function Class:OnBetSelect(toggle)
    if toggle.isOn then
        local betid = tonumber(toggle.name)
        self.betid = betid
        if not self.dontRecordPlayerSeletBet then
            self.lastSeletedToggleIndex = betid+1
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
                    -- local delayTime = RandomFloat(0,2)
                    -- yield(WaitForSeconds(delayTime))
                    data.animatorHelper:Play("Idel")
                    yield(WaitForSeconds(data.animatorHelper:GetDuration("Idel")))
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
            winShowData.animatorHelper:Play("Victory") -- 中间领奖台动物胜利动画
            -- 播放声音
            local color_id = self.resultPanelData.color_id
            local animal_id = self.resultPanelData.animal_id
            if color_id and animal_id then
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
        end
        data.StopShow = function ()
            winShowData.gameObject:SetActive(false)
            data.PlayIdle()
        end
        -- 跳到中间领奖台
        -- bSkipAnim 是否跳过DOTween动画（断线重连时间不够需要跳过动画）
        data.JumpToWinStage = function (winItemCount, index, bSkipAnim)
            data.StopAnim()
            local jumpTargetPos = ui.JumpTarget_Transform.localPosition
            local jumpTargetRot = ui.JumpTarget_Transform.localEulerAngles - self.ui.animal_rotate_root_transform.localEulerAngles
            -- local offset = 5.0
            -- local itemPos = jumpTargetPos
            -- local c = (index -1 ) - (winItemCount-1)/2 -- 计算每个item的偏移
            -- itemPos.x = pos.x+c*offset
            data.OriginalPos = data.transform.localPosition -- 记录一下原始位置，以便返回
            data.OriginalRot = data.transform.localEulerAngles -- 记录一下原始角度
            data.bJump = true
            if bSkipAnim then
                data.transform.localPosition = jumpTargetPos
                data.transform.localEulerAngles = jumpTargetRot
                data.animatorHelper:Play("Idel1") -- 避免结算时进入动物不动
            else
                data.transform:DOLocalMove(jumpTargetPos, 0.9):SetDelay(0.2):SetEase(Ease.InOutQuad)
                data.transform:DOLocalRotate(jumpTargetRot, 0.2):SetDelay(1)
                data.animatorHelper:Play("Jump")
                data.animatorHelper:SetBool("bJumpToCenter", true)
                data.animatorHelper:SetBool("tResultVictoryToIdel1", true)
                data.animatorHelper:SetTrigger("tVictory")
            end
            -- 播放声音
            local color_id = self.resultPanelData.color_id
            local animal_id = self.resultPanelData.animal_id
            if color_id and animal_id then
                if index > 1 and self.resultPanelData.songdengData then
                    color_id = self.resultPanelData.songdengData.songDengColorID
                    animal_id = self.resultPanelData.songdengData.songDengAnimalID
                end
                
                if color_id == GameConfig.ColorType.SanYuan then
                    AudioManager.Instance:PlaySoundEff2D("dasanyuan")
                elseif color_id == GameConfig.ColorType.SiXi then
                    AudioManager.Instance:PlaySoundEff2D("dasixi")
                else
                    local audioIndex = self:__GetBetItemLuaIndex(color_id, animal_id)
                    AudioManager.Instance:PlaySoundEff2D(GameConfig.WinSound[audioIndex])
                end
            end

        end
        data.JumpToOriginal = function (bSkipAnim)
            data.StopAnim()
            data.animatorHelper:SetBool("bJumpToCenter", false)
            data.animatorHelper:SetBool("tResultVictoryToIdel1", false)
            data.bJump = false
            if bSkipAnim then
                data.transform.localPosition = data.OriginalPos
                data.transform.localEulerAngles = data.OriginalRot
            else
                data.transform:DOLocalMove(data.OriginalPos, 0.9):SetDelay(0.2):SetEase(Ease.InOutQuad)
                data.transform:DOLocalRotate(data.OriginalRot, 0.2):SetDelay(1)
                data.animatorHelper:Play("Jump")
                -- data.animatorHelper:SetBool("bJumpToCenter", false)
            end
        end
        

    end
end

function Class:OnCustumEvent(params)
    local eventName = params[0]
    LogE("使用了  OnCustumEvent：  ", eventName)
    
    -- if eventName=='CameraMoved' then
    --     print('CameraMoved')
    -- elseif eventName == 'On2_1Mode' then
    --     --针对超宽屏进行优化
    --     self.ui.gameObject.transform.localScale = _G.Vector3(1.03,1,1)
    -- end
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
    print("11111self.showCO = ", self.showCO)
    if isReconnection then
        self:ResetView(data)
    end
    if SEnv.gamePause then
        return
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
        if g_Env then
            g_Env.OnUserCurrencyNotEnough()
        else
            print("金币不足....")
        end
        return
    end
    --发送下注
    self:OnSendBet(item_id, self.betid)
end

function Class:OnContinueBtnClicked()
    if self:__GetContinueBetScore() <= 0 then
        SEnv.ShowHintMessage("上局没有下注记录")
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
        -- print("颜色表：", json.encode(colorArray))
        for index, value in ipairs(colorArray) do
            ui.colorDataList[index].colorMesh.material = ui.colorMeshMaterialList[value]
            ui.colorDataList[index].color_id = value
            --print("index = ", index, "color_id = ", value, " animal_id = ", ui.runItemDataList[index].item_id)
        end
    end
    if #ratioArray ~= 0 then
        -- print("倍率表：", json.encode(ratioArray))
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
    -- print("进入下注阶段....")
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('betState')
    AudioManager.Instance:PlaySoundEff2D("start_bet")
    self:DoCheckForBetButtonState()--判断并禁用钱不够的可选筹码按钮

    if data.color_array == nil or data.ratio_array == nil then
        LogE("OnBetState: data.color_array == nil or data.ratio_array == nil ")
        return
     end
    --  print("颜色表：", json.encode(data.color_array))
    --  print("倍率表: ", json.encode(data.ratio_array))
     self:SetColorAndRatio(data.color_array, data.ratio_array)
end

-- 游戏阶段（转和显示结果）
function Class:OnShowState(data)
    -- print("进入结算阶段....")
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('showState')
    AudioManager.Instance:PlaySoundEff2D("stop") 
    ui.directionallight_animationhelper:PlayByIndex(1)
    ui.pointlight_animationhelper:PlayByIndex(1)
    --
    if #data.color_array == 0 or #data.ratio_array == 0 then
        if #self.ratioArray == 0 then
            print("OnShowState: data.color_array == nil or data.ratio_array == nil self.ratioArray = nil")
            return
        end
    else
        self:SetColorAndRatio(data.color_array, data.ratio_array)
        self.ratioArray = data.ratio_array
    end
    --
    local resultInfo = data.anim_result_list[1]
    if resultInfo == nil then -- 初次进入游戏不清楚为什么这里偶尔会是nil
        return
    end
    -- -- 测试三元四喜
    -- resultInfo.color_id = 5 
    -- resultInfo.sixi_color_id = 2
    -- resultInfo.animal_id = 4 -- 兔子

    -- 送灯测试
    -- data.ex_ret = 2
    -- data.left_time = data.left_time +5
    -- data.anim_result_list[2] = {color_form = data.anim_result_list[1].color_to, color_to = 1, animal_form = data.anim_result_list[1].animal_to,animal_to = 1,
    --                             color_id = 1, animal_id = 1}
    --
    local songDengInfo = data.anim_result_list[2]
    local winColor = resultInfo.color_id
    local winSiXiColor = resultInfo.sixi_color_id
    local winAnimal = resultInfo.animal_id
    local winEnjoyGameType = data.enjoy_game_ret
    local exType = data.ex_ret
    print("=====OnShowState=======:")
    print("颜色结果: ", winColor, "动物结果: ", winAnimal, "大四喜颜色结果: ", winSiXiColor, "庄和闲结果: ", winEnjoyGameType)
    print("额外大奖结果：", exType, "彩金倍率：", data.caijin_ratio, "闪电倍率：", data.shandian_ratio)
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
    
    if winColor == ColorType.SiXi then
        local animalRatioArray = {}
        for i = AnimalType.Lion, AnimalType.Rabbit, 1 do
            tinsert(animalRatioArray, self:__GetRatio(winSiXiColor, i))
        end
        local sixiData = {
            sixiColor_id = winSiXiColor,
            animalRatioArray = animalRatioArray,
        }
        self.resultPanelData.sixiData = sixiData

    elseif winColor == ColorType.SanYuan then
        local animalRatioArray = {}
        for i = ColorType.Red, ColorType.Yellow, 1 do
            tinsert(animalRatioArray, self:__GetRatio(i, winAnimal))
        end
        local sanyuanData = {
            animal_id =  winAnimal,
            animalRatioArray = animalRatioArray,
        }
        self.resultPanelData.sanyuanData = sanyuanData
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
    -- self:StopIdleStateAnim()

    local anim_result_list = data.anim_result_list
    if anim_result_list then
        -- -- 检查剩余时间是否足够进行动画（断线重连可能在任意状态中任意时间恢复，会导致状态剩余时间不同）
        -- -- 剩余时间小于(结算界面+动画展示 + 2)直接显示结果，不进行动画
        local ShowRunTime = 0
        local ShowRunTime_Shark = 0
        local JumpTime = GameConfig.JumpTime
        local ShowZhanShiTime = GameConfig.ShowZhanShiTime
        local ShowResultTime = GameConfig.ShowResultTime

        bSkip = false -- 是否跳过跑马灯动画，如果时间不够就跳过
        local winItemCount = #anim_result_list -- 中奖动物数量
        local leftTime = data.left_time
        --
        print("data.left_time = ", data.left_time)
        if leftTime < GameConfig.ShowResultTime + GameConfig.JumpTime then
            bSkip = true
            ShowResultTime = leftTime
            leftTime = 0
        else
            leftTime = leftTime - GameConfig.ShowResultTime + GameConfig.JumpTime
        end
        print("leftTime = ", leftTime, bSkip, "ShowResultTime = ", ShowResultTime)
        -- 
        local timedataList = {}
        for i = 1, winItemCount, 1 do
            if leftTime <= 0 then
                break
            end
            --
            local timedata = {}
            if leftTime < GameConfig.JumpTime and i ~= 1 then -- 跳回时间,最后一个不需要跳回，逆序插入的
                timedata.jumpToOriginalTime = leftTime
                timedata.skipJumpToOriginal = true
            else
                timedata.jumpToOriginalTime = GameConfig.JumpTime
                leftTime = leftTime - GameConfig.JumpTime
                -- 跳入+展示放一起
                local tJumpAndVictory = GameConfig.ShowZhanShiTime + GameConfig.JumpTime
                if leftTime < tJumpAndVictory then -- 展示时间
                    timedata.jumpToWinStageAndVictoryTime = leftTime
                    timedata.skipJumpToWinStageAndVictory = true
                else
                    timedata.jumpToWinStageAndVictoryTime = tJumpAndVictory
                    leftTime = leftTime - tJumpAndVictory
                    -- 跑马灯时间
                    if leftTime < 1 then        
                        -- 跳过跑马灯
                    else
                        local tShowRunTime = GameConfig.ShowRunTime
                        if i ~= winItemCount then
                            tShowRunTime = GameConfig.ShowSharkRunTime
                        end
                        if leftTime < tShowRunTime then
                            timedata.showRunTime = leftTime
                        else
                            timedata.showRunTime = tShowRunTime
                            leftTime = leftTime - tShowRunTime
                        end
                    end
                end
            end
            tinsert(timedataList, 1, timedata)
        end
        --
        winItemDataList = {} 
        ui.cameraCtrl:ToRotatePoint() -- 摄像机到转动位置
        print("ShowRunTime = ", ShowRunTime, "winItemCount = ", winItemCount)
        self.showCO = CoroutineHelper.StartCoroutine(function ()
            for i=1, winItemCount do
                local indexdata = anim_result_list[i]
                local colorFrom,colorTo = indexdata.color_form,indexdata.color_to
                local animalFrom, animalTo = indexdata.animal_form, indexdata.animal_to
                local itemData = self.runItemDataList[animalTo]
                table.insert(winItemDataList, itemData)
                local timeData = timedataList[i]
                print("timeData =", timeData, " i = ", i )
                if timeData ~= nil then
                    -- 跑马灯
                    if timeData.showRunTime ~= nil then 
                        local round = 2
                        if timeData.showRunTime < 2 then
                            round = 1
                        end
                        yield(self:DoTweenShowResultAnim(colorFrom, colorTo, animalFrom, animalTo, round, timeData.showRunTime))--播放跑马灯动画
                    else -- 直接设置结果
                        self:__SetArrowAndAnimalRot(colorTo, animalTo)
                    end
                    ui.cameraCtrl:ToShowPoint()
                    ui.winStage_huaban_animatorhelper:Play("Open") -- 播放花瓣打开动画
                    -- 跳入和展示
                    if timeData.jumpToWinStageAndVictoryTime ~= nil then
                        if timeData.skipJumpToWinStageAndVictory then
                            print("跳过跳入动画", timeData.jumpToWinStageAndVictoryTime, timeData.skipJumpToWinStageAndVictory)
                            itemData.JumpToWinStage(winItemCount, i, true) -- 跳过跳入动画直接设置位置到中间奖台
                        else
                            print("不跳过跳入动画并且播放胜利动画", timeData.jumpToWinStageAndVictoryTime, timeData.skipJumpToWinStageAndVictory)
                            itemData.JumpToWinStage(winItemCount, i, false) -- false 不跳过跳入动画
                        end
                        yield(WaitForSeconds(timeData.jumpToWinStageAndVictoryTime))
                    else
                        print("直接设置结果到讲台.....")
                        itemData.JumpToWinStage(winItemCount, i, true) -- 跳过跳入动画直接设置位置到中间奖台
                    end

                    -- 多个结果轮流跳入
                    if winItemCount > 1 and i ~= winItemCount then   -- 有多个结果且不是最后一个
                        if timeData.jumpToOriginalTime ~= nil then
                            if timeData.skipJumpToOriginal then
                                itemData.JumpToOriginal(true)  
                            else
                                itemData.JumpToOriginal(false)  
                            end
                            yield(WaitForSeconds(timeData.jumpToOriginalTime))
                        end
                        ui.cameraCtrl:ToRotatePoint() -- 摄像机位置还原到转动位置，准备转下一个               
                    end
                    local colordata = self.ui.colorDataList[colorTo]
                    colordata.animator:Play("BaoshiFlash", 0, 0)
                    colordata.animator:Update(0)
                    colordata.animator.enabled = false  -- 停止中奖颜色播放闪烁动画
                else
                    -- 跳过
                end
            end
            -- 禁用聚光灯动画和宝石动画
            self.ui.SpotLight_Animal_animator.gameObject:SetActive(false)
            self.ui.SpotLight_Animal_animator.enabled = false
            self.ui.Baoshi_1_animator.enabled = false
            -- 显示中奖结算界面
            -- print("显示结算....中奖动物数：", #winItemDataList)
            local resultPanel = self.ui.mainUI.resultPanel
            resultPanel:ShowResult(self.resultPanelData)
            -- 以下挪到FreeState试试看
            yield(WaitForSeconds(ShowResultTime))
            resultPanel:HideResult()
            if winColor == GameConfig.ColorType.SanYuan or winColor == GameConfig.ColorType.SiXi then
                AudioManager.Instance:StopAllSoudEff()   -- 三元四喜音乐太长这里截断（或看情况做其他处理）
            end
            self.resultPanelData = {}   -- 清空结果数据避免冗余干扰
            -- 结算界面消失后动物再跳回，如果不调整结算状态时间，这里会占用空闲状态时间，看起来也问题不大，有时间考虑优化一下
            for _, itemData in pairs(winItemDataList) do
                -- print("动物是否跳出:", itemData.bJump)
                if itemData.bJump then
                    -- print("动物跳回....")
                    itemData.JumpToOriginal(bSkip)
                end
            end
            if bSkip == false then
                yield(WaitForSeconds(GameConfig.JumpTime))
            end
            -- print("关闭花瓣....")
            ui.winStage_huaban_animatorhelper:Play("Close") -- 播放花瓣关闭动画
            -- 开启聚光灯动画和宝石动画
            self.ui.SpotLight_Animal_animator.enabled = true
            self.ui.Baoshi_1_animator.enabled = true
            self.ui.SpotLight_Animal_animator.gameObject:SetActive(true)
            -- 同步玩家分数
            -- print("同步玩家分数: ", self.selfScore)
            self:OnMoneyChange(self.selfScore)
            self.selfScore = SEnv.playerRes.currency
            -- 开奖结束再更新record，避免剧透
            local info  = {
                ressult_info = {winColor = resultInfo.color_id, winSiXiColor = resultInfo.sixi_color_id, winAnimal = resultInfo.animal_id},
                win_enjoyGameType = winEnjoyGameType,
                win_exType = exType,
                ressult_info_songdeng = self.resultPanelData.songdengData,
                caijin_ratio = data.caijin_ratio,
                shandian_ratio = data.shandian_ratio,
            }
            ui.roadScrollView:InsertItem(ui:GetHistoryIconData(info))
            SEnv.TestProcessEnd = true
            print("测试结束self.showCO = ", SEnv.TestProcessEnd, self.showCO)
        end)
        
        
    end
end


-- 开奖逻辑（从开始转到显示结算界面）
function Class:DoTweenShowResultAnim(colorFromindex, colorToindex, animalFromindex, animalToindex, round, time)
    round = round or 2
    time = time or GameConfig.ShowAnimationTime
    local ui = self.ui
    local RunItemCount = GameConfig.RunItemCount
    --print("colorFromindex = ", colorFromindex, "  colorToindex = ", colorToindex, "  animalFromindex = ", animalFromindex, " animalToindex = ", animalToindex)
    --print("箭头角度：", ui.arrow_transform.eulerAngles, " 动物角度：", ui.animal_rotate_root_transform.eulerAngles)
    
    -- 箭头(颜色)
    local colorDataList = ui.colorDataList
    local rotCount = colorFromindex - colorToindex  -- 逆时针转
    if rotCount < 0 then
        rotCount = rotCount + RunItemCount
    end
    local colorTotalWillRunCount = rotCount + RunItemCount*round
    if colorTotalWillRunCount < RunItemCount then   -- 与上一局同一个结果就转一圈，防止同一个结果原地不动的情况, 送灯除外，
        colorTotalWillRunCount=colorTotalWillRunCount+RunItemCount
    end

    local arrow_transform = ui.arrow_transform
    local colorStartRot = (colorFromindex - 1)*15
    arrow_transform.eulerAngles = Vector3(0, colorStartRot, 0)
    local arrowTotalRot = colorTotalWillRunCount*15
    --print("箭头转动数量：", colorTotalWillRunCount)
    --
    local curve =  GameConfig.Ease[RandomInt(1,#GameConfig.Ease)]
    CoroutineHelper.StartCoroutine(function ()
        local fixTime = time - 1 -- 避免重连时间不够，指针直接跳到结束点
        if fixTime < 0.5 then
            fixTime = time
        end
        yield(arrow_transform:DORotate(Vector3(0, -arrowTotalRot, 0), fixTime, RotateMode.LocalAxisAdd)
        :SetEase(curve):WaitForCompletion())
        local colordata = colorDataList[colorToindex]
        colordata.animator.enabled = true  -- 播放中奖颜色闪烁动画
        local name = "BaoshiFlash_"..colordata.color_id
        colordata.animator:Play(name, 0, 0)
        -- print("colorAnimName = ", name)
    end)

    -- 动物
    local temp = colorFromindex - colorToindex 
    if temp < 0 then
        temp = temp + RunItemCount
    end
    local realFrom = animalFromindex - temp
    if realFrom <= 0 then
        realFrom = realFrom + RunItemCount
    end

    local animalRotCount = realFrom - animalToindex -- 顺时针转
    if animalRotCount < 0 then
        animalRotCount = animalRotCount + RunItemCount
    end
    --print("temp = ", temp, " realFrom = ", realFrom, " animalRotCount = ", animalRotCount)
    local animalTotalWillRunCount = animalRotCount + RunItemCount*round
    if animalTotalWillRunCount < RunItemCount then
        animalTotalWillRunCount=animalTotalWillRunCount+RunItemCount
    end
    local tIndex = colorFromindex - animalFromindex
    if tIndex < 0 then
        tIndex =  tIndex + RunItemCount
    end
    local animalStartRot = (tIndex)*15
    --print("动物转动数量：", animalTotalWillRunCount)
    local animalRotRoot_transform = ui.animal_rotate_root_transform
    animalRotRoot_transform.eulerAngles = Vector3(0, animalStartRot, 0)
    local animalTotalRot = animalTotalWillRunCount*15
    local curve =  GameConfig.Ease[RandomInt(1,#GameConfig.Ease)]
    return CoroutineHelper.StartCoroutine(function ()
        local dur = time  -- 错开一点不同时停止
        --print("动物开转 = ", animalTotalRot, dur, time)
        yield(animalRotRoot_transform:DORotate(Vector3(0, animalTotalRot, 0), dur, RotateMode.LocalAxisAdd)
        :SetEase(curve):WaitForCompletion())
        yield()
    end)
end
-- 把场景重置到初始状态（重连或后台切回还原用）
function Class:ResetView(data)
    -- 同步玩家分数
    self:OnMoneyChange(data.self_score)
    -- 重置上一局结果残留
    self:__ResetCurWinResultData()
    -- 关闭下注界面隐藏结算界面
    self.ui.mainUI:ResetUI()
    -- 同步下注信息和筹码
    local selfBetMap = data.self_bet_info_list
    local totalBetMap = data.room_total_bet_info_list
    for _, info in pairs(selfBetMap) do
        self:__SetSelfBetScore(info.index_id, info.total_bet)
    end
    --
    for _, info in pairs(totalBetMap) do
        self:__SetTotalBetScore(info.index_id, info.total_bet)
    end
    -- 恢复镜头
    self.ui.cameraCtrl:ToNormalPoint()
    self.ui.winStage_huaban_animatorhelper:Play("Close") -- 播放花瓣关闭动画
    -- 开启聚光灯动画和宝石动画
    self.ui.SpotLight_Animal_animator.enabled = true
    self.ui.Baoshi_1_animator.enabled = true
    self.ui.SpotLight_Animal_animator.gameObject:SetActive(true)
    -- 所有中奖动物跳回
    for _, itemData in pairs(winItemDataList) do
        -- print("动物是否跳出:", itemData.bJump)
        if itemData.bJump then
            -- print("动物跳回....")
            itemData.JumpToOriginal(bSkip)
        end
    end
    -- 所有宝石动画闪烁停止
    for i = 1, #self.ui.colorDataList do
        local colordata = self.ui.colorDataList[i]
        colordata.animator:Play("BaoshiFlash", 0, 0)
        colordata.animator:Update(0)
        colordata.animator.enabled = false  -- 停止中奖颜色播放闪烁动画
    end
    -- 路单同步(独立协议处理)
end
-- 目前可能会出现 结算流程未结束就进入  OnFreeState 的问题，因为是按时间计算的
-- 可以考虑把结算状态的最后逻辑处理放到 OnFreeState 中
-- 空闲阶段 
function Class:OnFreeState()
    -- -- 结算状态清理
    -- local ui = self.ui
    -- local winColor = self.resultPanelData.color_id
    -- local winAnimal = self.resultPanelData.animal_id
    -- local exType = self.resultPanelData.exType
    -- local caijin_ratio = self.resultPanelData.caijin_ratio
    -- local shandian_ratio = self.resultPanelData.shandian_ratio 
    -- local winSiXiColor = nil
    -- if self.resultPanelData.sixiData then
    --     winSiXiColor = self.resultPanelData.sixiData.winSiXiColor
    -- end
    -- local winEnjoyGameType = nil
    -- if self.resultPanelData.enjoyGameData then
    --     winEnjoyGameType = self.resultPanelData.enjoyGameData.enjoyGame_id
    -- end

    -- ui.mainUI.resultPanel:HideResult()
    -- if winColor == GameConfig.ColorType.SanYuan or winColor == GameConfig.ColorType.SiXi then
    --     AudioManager.Instance:StopAllSoudEff()   -- 三元四喜音乐太长这里截断（或看情况做其他处理）
    -- end
    -- -- 结算界面消失后动物再跳回，如果不调整结算状态时间，这里会占用空闲状态时间，看起来也问题不大，有时间考虑优化一下
    -- for _, itemData in pairs(winItemDataList) do
    --     -- print("动物是否跳出:", itemData.bJump)
    --     if itemData.bJump then
    --         -- print("动物跳回....")
    --         itemData.JumpToOriginal(bSkip)
    --     end
    -- end
    -- -- print("关闭花瓣....")
    -- ui.winStage_huaban_animatorhelper:Play("Close") -- 播放花瓣关闭动画
    -- -- 开启聚光灯动画和宝石动画
    -- self.ui.SpotLight_Animal_animator.enabled = true
    -- self.ui.Baoshi_1_animator.enabled = true
    -- self.ui.SpotLight_Animal_animator.gameObject:SetActive(true)
    -- -- 同步玩家分数
    -- -- print("同步玩家分数: ", self.selfScore)
    -- self:OnMoneyChange(self.selfScore)
    -- self.selfScore = SEnv.playerRes.currency
    -- -- 开奖结束再更新record，避免剧透
    -- local info  = {
    --     ressult_info = {winColor = winColor, winSiXiColor = winSiXiColor, winAnimal = winAnimal},
    --     win_enjoyGameType = winEnjoyGameType,
    --     win_exType = exType,
    --     ressult_info_songdeng = self.resultPanelData.songdengData,
    --     caijin_ratio = caijin_ratio,
    --     shandian_ratio = shandian_ratio,
    -- }
    -- ui.roadScrollView:InsertItem(ui:GetHistoryIconData(info))
    -- self.resultPanelData = {}   -- 清空结果数据避免冗余干扰
    -- -- print("进入空闲阶段....玩家分数重置")
    -- self:__ResetCurWinResultData()
    --
    local ui = self.ui
    self.ui.cameraCtrl:ToNormalPoint()
    ui.viewEventBroadcaster:Broadcast('freeState')
    ui.directionallight_animationhelper:PlayByIndex(2)
    ui.pointlight_animationhelper:PlayByIndex(2)
    self:PlayIdleStateAnim()
    -- 如果上一局有下注，则刷新续押数据，否则不变
    if self:__GetSelfAllBetScore() > 0 then
        self.betSnapShot = {}   -- 清空原数据
        for key, value in pairs(self.selfBetMap) do
            self.betSnapShot[key] = value
        end
    end
    self:__ResetBetScore()
    self.ui.mainUI:SetCurBetScore(0) -- 清0 UI下注分数
    AudioManager.Instance:PlaySoundEff2D("vs_alert")

    self.gameCount = self.gameCount +1
    self.ui.mainUI:SetGameCount(self.gameCount)

    -- 重置玩家列表中玩家的下注分数，这里自己做了，不必服务端同步
    self.ui.mainUI:ResetAllPlayerTotalBets()
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
    -- print("玩家下注返回：玩家分数: ", data.self_score)
    local betAreaList = self.ui.betAreaList
    local self_bet_info = data.self_bet_info
    local item_id = self_bet_info.index_id
    if item_id == -1 then
        for _, betAreaData in pairs(betAreaList) do
            self:__SetSelfBetScore(betAreaData.item_id, 0)
        end
    else
        local total_bet = self_bet_info.total_bet
        self:__SetSelfBetScore(item_id, total_bet)
        AudioManager.Instance:PlaySoundEff2D("betSound")
    end
    self:OnMoneyChange(data.self_score)
    local score = self:__GetSelfAllBetScore()
    self.ui.mainUI:SetCurBetScore(score)
end

-- 发送请求历史路单数据
function Class:SendHistoryReq()
    print('SendHistoryReq:')
    CLSLWHSender.Send_HistoryReq(function (data)
        self:OnHistroyAck(data)
    end)
end

function Class:OnHistroyAck(data)
    -- print('HistoryAck:'..json.encode(data))
    if data.errcode ~= 0 then
        _G.ShotHintMessage(_G._STR_("获取历史记录出错"))
    else
        local ui = self.ui
        local record_list = data.record_list
        local list = {}
        for _,info in ipairs(record_list)do
            local itemData = ui:GetHistoryIconData(info)
            tinsert(list, itemData)
        end
        ui.roadScrollView:ReplaceItems(list)
        ui.roadScrollView:SmoothScrollToEnd()
    end
end

function Class:OnSelfWinResultNtf(data)
    -- print("结算：玩家分数: ", data.self_score, data.win_score, data.bet_score)
    self.resultPanelData.winScore = data.win_score -- 本局输赢
    self.resultPanelData.betScore = data.bet_score  -- 总输赢
    self.selfScore = data.self_score
    if self.resultPanelData.winScore > 0 then
        AudioManager.Instance:PlaySoundEff2D("win_bet")
    end
end

function Class:TTT()
    TestProcessEnd = true
    SEnv.TestProcessEnd = true
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
function Class:__SetSelfBetScore(id, score)
    self.selfBetMap[id] = score
    self.ui.betAreaList[id].selfBetScore.text = Helpers.GameNumberFormat(score)
end
-- 设置全体下注分数
function Class:__SetTotalBetScore(id, score)
    self.totalBetMap[id] = score
    self.ui.betAreaList[id].totalBetScore.text = Helpers.GameNumberFormat(score)
end

-- 重置所有下注分数
function Class:__ResetBetScore()
    for _, betAreadata in pairs(self.ui.betAreaList)do
        self:__SetSelfBetScore(betAreadata.item_id, 0)
        self:__SetTotalBetScore(betAreadata.item_id, 0)
    end
end

-- 获取自己当前总下注
function Class:__GetSelfAllBetScore()
    local score = 0
    for key, value in pairs(self.selfBetMap) do
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
-- 清除当前局结算缓存
function Class:__ResetCurWinResultData()
    if self.resultPanelData then
        self.resultPanelData.winScore = 0 -- 本局输赢
        self.resultPanelData.betScore = 0  -- 总输赢
    end
end

-- 根据下标设置动物和指针角度
function Class:__SetArrowAndAnimalRot(color_index, animal_index)
    -- 根据上局中奖下标同步转盘和指针角度 0° 是第一格的位置所以 index-1
    local zhizhenRot = (color_index -1)*15
    local animalIndex = color_index - animal_index
    if animalIndex < 0 then
        animalIndex = animalIndex + GameConfig.RunItemCount
    end
    local animalRot = (animalIndex)*15
    -- print("同步指针角度:", roomdata.last_color_index, zhizhenRot)
    -- print("同步动物角度:", roomdata.last_animal_index, animalRot)
    self.ui.arrow_transform.localEulerAngles = Vector3(0, zhizhenRot, 0)
    self.ui.animal_rotate_root_transform.localEulerAngles = Vector3(0, animalRot, 0)
end

-- function Class:__SetAnimalRot(color_index, animal_index)
    
-- end


function Class:Release()

end

function Class:OnDestroy()
    print("3DViewCtrl Destroy")
    self.ui:Release()
end

return _ENV