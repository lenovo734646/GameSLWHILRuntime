
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE,tonumber =
      print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE,tonumber

local logError = logError
local math,pairs = math,pairs

local DOTween = CS.DG.Tweening.DOTween
local table = table
local tinsert = table.insert
local tremove = table.remove

local CoroutineHelper = require'CoroutineHelper'
local WaitForSeconds = UnityEngine.WaitForSeconds
local yield = coroutine.yield

local PBHelper = require 'protobuffer.PBHelper'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local GameConfig = require 'GameConfig'
local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject
local RandomInt = UnityHelper.RandomInt
local RandomFloat = UnityEngine.Random.Range

local Input = UnityEngine.Input
local clock = os.clock

local SoundManager = require'controller.SoundManager'

local SubGame_Env=SubGame_Env

_ENV = moduledef { seenamespace = CS }
local Stopwatch = System.Diagnostics.Stopwatch.StartNew()

local convertNumberToString = function (n)
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

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(ui,View,roomdata)
    print("3D View Ctrl Init...roomdata.last_bet_id = ", roomdata.last_bet_id)
    self.ui = ui
    self.roomdata = roomdata
    _G.PrintTable(self.histroyList)
    View:GetComponent(typeof(LuaUnityEventListener)):Init(self)
    View:GetComponent(typeof(KeyListener)):Init(self)
    --
    self.bet_config_array = roomdata.bet_config_array
    self.self_user_id = roomdata.self_user_id
    self.normal_show_time = roomdata.normal_show_time
    self.shark_more_show_time = roomdata.shark_more_show_time
    self.betid = roomdata.last_bet_id
    --
    self.betSnapShot = {} -- 上一局押注数据

    self.lastSeletedToggleIndex = 1
    self.lastCurrecy = SubGame_Env.playerRes.currency

    self:OnMoneyChange(SubGame_Env.playerRes.currency)

    self.timeStamp = clock()
    -- 音乐音效管理
    self.soundMgr = SoundManager.Create(self.ui.soundManagerInitHelper)
    self.soundMgr:PlayBGMusic()

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

    -- 玩家上一次下注总值
    self.selfTotalBet = {}
    self.TotalBet = {}
    self:__ResetBetScore()

    self:InitAnimalAnimation()
end

-- showRedNuber: 是否显示红色数字，下注状态就显示，这里其实是gameState
function Class:PlayCountDownSound(time)
    if time > 5 then
        self.soundMgr:PlaySound("countdown")
    else
        if self:IsBetState() then
            self.soundMgr:PlaySound("alert")
        else
            self.soundMgr:PlaySound("countdown")
        end
    end
end

--当组件DisableGameObjectsOnSceneLoaded完成后，会调用此方法
function Class:OnSceneReady()
    print('OnSceneReady')
    local ui = self.ui
    -- 网络消息监听
    -- 游戏状态变化
    PBHelper.AddListener('StateChangeNtf', function (data)
        --print("StateChangeNtf ", data.state)
        self:OnStateChangeNtf(data)
    end)
    
    -- 玩家资源变化(金币,钻石，点卷，道具数)
    PBHelper.AddListener('CLPF.ResChangedNtf', function (data)
        --print("分数变化ResChangedNtf...", data.res_type, data.res_value, self.state)

    end)

    PBHelper.AddListener('CLPF.ResSyncNtf', function (data)
        print("分数同步ResSyncNtf...", data.currency) -- 此消息暂时不能收到
    end)

    -- 本局自己输赢和庄家输赢
    PBHelper.AddListener('SelfWinResultNtf', function (data)
        print("SelfWinResultNtf", data.self_score, data.banker_score)
        self.win = data.win -- 本局输赢
        self.totalWin = data.total_win  -- 总输赢
        self.selfScore = data.self_score

        self.bankerWin = data.banker_win
        self.bankerTotalWin = data.banker_total_win
        self.bankerScore = data.banker_score

        if self.win > 0 then
            self.soundMgr:PlaySound("win_bet")
        end
    end)

    -- 其他玩家下注广播
    PBHelper.AddListener('OtherPlayerSetBetNtf', function (data)
        local item_id = data.info.animal_id
        
        --print("OtherPlayerSetBetNtf...", item_id, total_bet)
        if item_id == -1 then   -- 清除筹码返回
            local totalBetInfoList = data.room_tatol_bet_info_list
            for key, betInfo in pairs(totalBetInfoList) do
                local id = betInfo.animal_id
                local total_bet = betInfo.total_bet
                --print("清除下注 id = ", id, total_bet)
                self.TotalBet[id] = total_bet
                local betAreaData = self.ui.betAreaList[id]
                betAreaData.totalBetScore.text = convertNumberToString(total_bet)
            end
        else
            local total_bet = data.info.total_bet or 0
            -- -- 飞筹码
            -- local totalBet = self.TotalBet[item_id] or 0 -- 清除下注判断，避免item_id == -1 报错
            -- local gapScore = total_bet - totalBet
            -- if gapScore > 0 then    -- 清除下注效果不同步
            --     local user_id = data.user_id
            --     local bSelf = false
            --     if user_id == self.self_user_id then
            --         bSelf = true
            --     end
            --     --self.choumaFly:FlyIn(item_id, gapScore, bSelf)
            -- end
            -- 同步总押分
            self.TotalBet[item_id] = total_bet or 0 
            local betAreaData = self.ui.betAreaList[item_id]
            betAreaData.totalBetScore.text = convertNumberToString(total_bet)
        end
    end)

    -- 在线人数
    PBHelper.AddListener("OnlinePlayerCountNtf", function (data)
        print("OnlinePlayerCountNtf: ", data.online_count)
        self.ui.topUI:UpdateOnlinePlayerCount(data.online_count)
    end)

    -- 状态处理
    local roomdata = self.roomdata
    local state = roomdata.state
    local left_time = roomdata.left_time
    local selfTotalBet = roomdata.self_bet_list
    local totalBet = roomdata.room_tatol_bet_info_list
    for _, info in pairs(selfTotalBet) do
        self.selfTotalBet[info.animal_id] = info.total_bet
    end
    for _, info in pairs(totalBet) do
        self.TotalBet[info.animal_id] = info.total_bet
    end

    self:OnStateChangeNtf({ left_time = left_time, state = state })
    if state == 2 then
        self.ui.mainUI:SetWaitNextStateTip(true)
    end
 
    
    --修正时间差
    local passTime = clock()-self.timeStamp
    self.timeStamp = nil
    local left_time = left_time-passTime
    if left_time > 2 then
        self.ui.mainUI.timeCounter:StartCountDown(left_time, state, function (time)
            self:PlayCountDownSound(time)
        end)
    end
    
    -- 发送请求历史路单数据
    CLSLWHSender.Send_HistoryReq(function (data)
        print('HistoryAck:'..json.encode(data))
        local icon_list = data
        local list = {}
        for _,animalID in ipairs(icon_list)do
            local spr = ui.histroyIconSprites[animalID]
            tinsert(list, {sprite = spr})
        end
        ui.roadScrollView:ReplaceItems(list)
    end)
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
        data.PlayShowAsync = function () -- 跟中奖同时播放
            data.StopAnim()
            winShowData.gameObject:SetActive(true)
            self.soundMgr:PlaySound("SLWH_"..GameConfig.WinSound[winShowData.item_id])
            -- 等待显示中奖结算
            yield(WaitForSeconds(self.ui.resultPanel:ShowResult(winShowData.item_id, GameConfig.Ratio[winShowData.item_id], 
                                                                self.win, self.totalWin, self.bankerWin, self.bankerTotalWin)))
            self.ui.resultPanel:HideResult()
            -- 同步玩家分数
            self:OnMoneyChange(self.selfScore)
            winShowData.gameObject:SetActive(false)
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
    return self.state == 1
end

function Class:IsShowState()
    return self.state == 2
end

function Class:IsFreeState()
    return self.state == 3
end

function Class:OnStateChangeNtf(data)
    local state = data.state
    self.state = state
    self.ui.mainUI:SetWaitNextStateTip(false)
    if state == 1 then --下注
        self:OnBetState()
    elseif state == 2 then --开奖
        self:OnShowState(data)
    else -- state == 3 空闲
        self:OnFreeState()
    end
    --
    self.ui.mainUI.timeCounter:StartCountDown(data.left_time, state, function (time)
        self:PlayCountDownSound(time)
    end)
end

-- 开奖（从开始转到显示结算界面）
function Class:DoTweenShowResultAnim(fromindex, toindex, round, time)
    round = round or 3
    time = time or GameConfig.ShowAnimationTime
    --print('DoTweenShowResultAnim round:'..round..' time:'..time)
    local ui = self.ui
    print("TODO：开转")
    -- local runItemDataList = ui.runItemDataList
    -- local len = #runItemDataList
    -- local totalWillRunCount = toindex - fromindex + len*round
    -- if totalWillRunCount < len then
    --     totalWillRunCount=totalWillRunCount+len
    -- end

    -- local poslist = {}
    -- local startindex = fromindex
    -- self.curIconPosIndex = startindex
    -- local data = runItemDataList[startindex]
    -- local lastHitIndex = startindex
    -- iconPos.position = data.position
    -- tinsert(poslist,data.position)
    -- for i=1, totalWillRunCount do
    --     startindex = startindex + 1
    --     if startindex > len then
    --         startindex = 1
    --     end
    --     local data = runItemDataList[startindex]
    --     tinsert(poslist,data.position)
    -- end

    -- local Ease = {
    --     DG.Tweening.Ease.InOutSine, DG.Tweening.Ease.InOutQuad,
    --     DG.Tweening.Ease.InOutQuad, DG.Tweening.Ease.InOutCubic,
    --     DG.Tweening.Ease.InOutCubic, DG.Tweening.Ease.InOutQuart,
    --     DG.Tweening.Ease.InOutQuart, DG.Tweening.Ease.InOutQuint,
    --     DG.Tweening.Ease.InOutExpo, DG.Tweening.Ease.InOutFlash,
    --     DG.Tweening.Ease.InOutCirc, DG.Tweening.Ease.InOutFlash
    -- }
    -- local curve =  Ease[RandomInt(1,#Ease)]
    -- local move = true


    -- --紧跟播放头
    -- CoroutineHelper.StartCoroutine(function ()
    --     while move do
    --         local count = 0
    --         while lastHitIndex ~= self.curIconPosIndex do
    --             lastHitIndex = lastHitIndex + 1
    --             if lastHitIndex > len then
    --                 lastHitIndex = 1
    --             end
    --             runItemDataList[lastHitIndex].Play()
    --             count = count + 1
    --             if count > len then
    --                 LogE('count > len')
    --                 break
    --             end
    --         end
    --         yield()
    --     end
    --     -- print('move end')
    -- end)


    -- return CoroutineHelper.StartCoroutine(function ()
    --     yield(iconPos:DOPath(poslist, time-GameConfig.ShowResultTime)
    --     :SetEase(curve):WaitForCompletion())
    --     local animaldata = runItemDataList[toindex]
    --     --
    --     self.ui.winParticleTransform.localPosition = animaldata.transform.localPosition
    --     self.ui.winParticleTransform.gameObject:SetActive(true)
    --     yield()
    --     move = false

    --     yield(animaldata.PlayShowAsync())
    --     -- 
    --     self.ui.winParticleTransform.gameObject:SetActive(false)
    -- end)
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
        if _G.ShotHitMessage then
            local errorstr = ''
            _G.ShotHitMessage(errorstr)
        else
            if _G.HALL then
                print('TODO 没有实现全局方法ShotHitMessage')
            else
                print('金币不足,当前金币:',SubGame_Env.playerRes.currency)
            end
        end
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

function Class:ResetBetSnapShot()
    self.betSnapShot = {}
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

-- 下注阶段
function Class:OnBetState(data)
    self.ui.viewEventBroadcaster:Broadcast('betState')
    self.soundMgr:PlaySound("start")
    self:DoCheckForBetButtonState()--判断并禁用不能下注的按钮
    -- 判断是否自动续押
    --print("是否自动续押:", self.ui.autoContinueBet.isOn)
    -- if self.ui.autoContinueBet.isOn then
    --     self:OnContinueBtnClicked()
    -- end
end

-- 游戏阶段（转和显示结果）
function Class:OnShowState(data)
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('showState')
    self.soundMgr:PlaySound("stop")
    self:StopIdleStateAnim()
    local cur_result_list = data.cur_result_list
    local anim_result_list = data.anim_result_list
    if anim_result_list then
        CoroutineHelper.StartCoroutine(function ()
            for i=1,#anim_result_list do
                local indexdata = anim_result_list[i]
                local from,to = indexdata.from,indexdata.to
                --print('indexs:',from,' ',to)
                local round = 2
                local showTime = self.normal_show_time
                if i > 1 then
                    round = 0
                    showTime = self.shark_more_show_time
                end
                yield(self:DoTweenShowResultAnim(from, to, round, showTime/1000))--播放转盘动画
                --print('show one end item_id = ', cur_result_list[1])
                ui.roadScrollView:InsertItem(ui:GetHistoryIconData(cur_result_list[1]))
                tremove(cur_result_list, i)
            end
        end)
    end
end

-- 空闲阶段
function Class:OnFreeState()
    local ui = self.ui
    ui.viewEventBroadcaster:Broadcast('freeState')
    self:PlayIdleStateAnim()
    self:__ResetBetScore()
    self.soundMgr:PlaySound("vs_alert")
end

function Class:__ResetBetScore()
    for _, betAreadata in pairs(self.ui.betAreaList)do
        betAreadata.selfBetScore.text = '0'
        betAreadata.totalBetScore.text = '0'
        self.selfTotalBet[betAreadata.item_id] = 0
        self.TotalBet[betAreadata.item_id] = 0
    end
end

function Class:OnNetWorkReConnect()
    print("========OnNetWorkReConnect=======================")
    self.ui.mainUI:SetWaitNextStateTip(true)
end

function Class:OnMoneyChange(currency)
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
    currency = currency or SubGame_Env.playerRes.currency
    

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
    ui.continue_button.interactable = self:GetContinueBetScore() <= currency
    self.notEnoughMoney = currency < bet_config_array[1]

    self.dontRecordPlayerSeletBet = false
end

-- 获取续押需要消耗的总分
function Class:GetContinueBetScore()
    local totalBetScore = 0
    for _,v in pairs(self.betSnapShot) do
        totalBetScore=totalBetScore+v
    end
    return totalBetScore
end

-- 押注网络协议处理
function Class:OnSendBet(item_id, betid)
    CLSLWHSender.Send_SetBetReq(function (data)
        self:OnReceiveBetAck(data)
    end, item_id, betid)
end

function Class:OnReceiveBetAck(data)
    --print("OnReceiveBetAck"..json.encode(data))
    local betAreaList = self.ui.betAreaList
    if data.errcode == 0 then
        local self_bet_info = data.self_bet_info
        local item_id = self_bet_info.animal_id
        if item_id == -1 then
            for _, betAreaData in pairs(betAreaList) do
                betAreaData.selfBetScore.text = '0'
                self.selfTotalBet[betAreaData.item_id] = 0
            end
            self:ResetBetSnapShot()
        else
            local betAreaData = betAreaList[item_id]
            --
            local total_bet = self_bet_info.total_bet
            betAreaData.selfBetScore.text = convertNumberToString(total_bet)
            self.betSnapShot[item_id] = total_bet
            self.selfTotalBet[item_id] = 0
            self.soundMgr:PlaySound("bet")
        end
        print("下注成功返回玩家当前分数：data.self_score")
        self:OnMoneyChange(data.self_score)
    else
        if _G.ShotHitMessage then
            local errorstr = '' -- TODO 获取错误提示
            _G.ShotHitMessage(errorstr)
        else
            print('TODO 获取错误提示 data.errcode=', data.errcode)
        end
    end
end

return _ENV