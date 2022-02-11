local _G, g_Env = _G, g_Env
local class = class
local print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs =
      print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs

local GameObject = GameObject
local Screen = UnityEngine.Screen
local Vector2 = UnityEngine.Vector2
local ChatPanel = require'ChatSystem.ChatPanel'
local ResultPanel = require'UI.ResultPanel'
local UserInfo = require'UI.UserInfo'
local TimerCounterUI = require 'UI.TimerCounterUI'
local PlayerListPanel = require'PlayerList.PlayerListPanel'
local AudioManager = AudioManager or CS.AudioManager
local Helpers = require'LuaUtil.Helpers'
local GameConfig = require 'GameConfig'
local CLSLWHSender = require'protobuffer.CLSLWHSender'
local SEnv = SEnv
_ENV = moduledef { seenamespace = CS }



local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(roomdata, loader)
    local View = GameObject.Find('UIRoot/Canvas/MainPanel')
    self.panel = View
    View:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

    -- 聊天界面
    self.chatPanel = ChatPanel.Create(self.ChatPanel, SEnv.loader, SEnv.playerRes, SEnv.CoroutineMonoBehaviour)
    -- 玩家列表界面
    self.playerListPanel = PlayerListPanel.Create(self.playerListPanel, SEnv.CoroutineMonoBehaviour)

    -- 结算界面
    self.resultPanel = ResultPanel.Create(self.resultPanelGameObject)
    -- 玩家信息
    self.userInfo = UserInfo.Create(self.userinfo_luainithelper, roomdata)

    -- 计时器
    self.timeCounter = TimerCounterUI.Create(self.timecounter_luainithelper)

    -- 统计数据
    self.statisicalData  = {}
    self.statisticalInitHelper:Init(self.statisicalData)

    self.betText.text = "0"
    self:SetStatisticData(0, 0, 0, 0, 0, 0)
    
    -- 统一使用大厅设置界面
    -- self.tog_Music.isOn = not AudioManager.Instance.MusicAudio.mute
    -- self.tog_Effect.isOn = not AudioManager.Instance.EffectAudio.mute

    self.gameStateSpineHelper.gameObject:SetActive(true)
    -- 刘海屏适配
    local offsetX = Screen.safeArea.x
    local mainUIRectTransform = View:GetComponent("RectTransform")
    local dstLeft = mainUIRectTransform.offsetMin.x + offsetX
    local dstRight = mainUIRectTransform.offsetMax.x + offsetX

    mainUIRectTransform.offsetMin = Vector2(dstLeft, mainUIRectTransform.offsetMin.y)
    mainUIRectTransform.offsetMax = Vector2(-dstRight, mainUIRectTransform.offsetMax.y)
end

-- 设置统计数据
function Class:SetStatisticData(sixiCount, sanyuanCount, zhuangCount, xianCount, heCount, allGameCount)
    self.statisicalData.sixiText.text =  string.Format2(_STR_" 大四喜x{1} ",(sixiCount))
    self.statisicalData.sanyuanText.text =  string.Format2(_STR_" 大三元x{1} ",(sanyuanCount))
    self.statisicalData.zhuangText.text =  string.Format2(_STR_" 庄x{1} ",(zhuangCount))
    self.statisicalData.xianText.text =  string.Format2(_STR_" 闲x{1} ",(xianCount))
    self.statisicalData.heText.text =  string.Format2(_STR_" 和x{1} ",(heCount))
    self.statisicalData.allText.text =  string.Format2(_STR_" 总局数x{1} ",(allGameCount))
end

function Class:SetCaiJinCount(caijin_count)
    self.caiJinText.text = tostring(caijin_count)
end


-- 设置等待下局提示
function Class:SetWaitNextStateTip(bShow)
    if bShow then
        self.WaitNextStateTipSpineHelper.gameObject:SetActive(true)
        self.WaitNextStateTipSpineHelper:PlayByName("dengdai")
    else
        self.WaitNextStateTipSpineHelper:StopByName("dengdai", true)
        self.WaitNextStateTipSpineHelper.gameObject:SetActive(false)
    end
end

-- 设置当前下注
function Class:SetCurBetScore(betScore)
    self.betText.text = Helpers.GameNumberFormat(betScore)
end

-- 设置当前局数（自己游戏局数非服务器总局数）
function Class:SetGameCount(count)
    self.gameCountText.text = Helpers.GameNumberFormat(count)
end

function Class:OnStateChange(state)
    if state == 1 or state == 3 then
        self.tog_OpenBet.interactable = true
    else
        self.tog_OpenBet.interactable = false
    end
end

function Class:ResetUI()
    self.tog_OpenBet.isOn = false
    self.resultPanel:HideResult()
end

-- 设置当前在线人数
function Class:UpdateOnlinePlayerCount(count)
    if self.playerListPanel.panel.activeSelf then
        self.playerListPanel:OnSendPlayerListReq(CLSLWHSender)
    end
end

-- 更新玩家胜利次数
function Class:UpdatePlayersWinCount(player_winCount_info_list)
    if self.playerListPanel.panel.activeSelf then
        self.playerListPanel:UpdatePlayersWinCount()
    end
end
-- 更新玩家本局下注
function Class:UpdatePlayerTotalBets(user_id, totalBets)
    if self.playerListPanel.panel.activeSelf then
        self.playerListPanel:UpdatePlayerTotalBets(user_id, totalBets)
    end
end

-- 重置玩家本局下注
function Class:ResetAllPlayerTotalBets()
    if self.playerListPanel.panel.activeSelf then
        self.playerListPanel:ResetAllPlayerTotalBets()
    end
end
function Class:OnCancelInput()
    if self.chatPanel then
        self.chatPanel:OnCancelInput()
    end
end

function Class:Release()
    print("MainUI Release")
    if self.chatPanel then
        self.chatPanel:Release()
        self.chatPanel = nil
    end
    if self.playerListPanel then
        self.playerListPanel:Release()
        self.playerListPanel = nil
    end
end

-- 以下代码为自动生成代码，请勿更改
function Class:On_tog_PlayerListPanel_Event(tog_PlayerList)
    print("发送玩家列表请求")
    self.playerListPanel:OnSendPlayerListReq(CLSLWHSender)
end

function Class:On_btn_Set_Event(btn_Set)
    print(" on btn_set click! ")
    if g_Env then
        g_Env.uiManager:OpenUI("Setting.SettingPanelUI")
    else
        LogW("独立小游戏无法打开设置界面...")
    end
end

function Class:On_btn_Bank_Event(btn_Bank)
    print("打开银行...")
    if g_Env then
        if g_Env.gamePlayer.Phone == nil then
            g_Env.hintMessage:CreateHintMessage(_STR_"请先到个人中心绑定手机号")
        else
            local isLogined = g_Env.mainModule:GetBankLogined()
            if isLogined then
                g_Env.uiManager:OpenUI("BankMain.BankMainPanelUI")
            else
                g_Env.uiManager:OpenUI("BankLogin.BankLoginPanelUI")
            end
        end
    else
        LogW("独立小游戏无法打开银行...")
    end
end

function Class:On_btn_Exit_Event(btn_Exit)
    print("OnExitClick...", g_Env)
    if g_Env then
        g_Env.MessageBox {
            content = _STR_"您正在游戏中，确定要退出游戏吗？",
            showCancel = true,
            onOK = function()
                g_Env.SubGameCtrl.Leave()
            end,
            onCancel = function ()
                print("OnExitClick...Cancel")
            end
        }
        
    end
end

-- function Class:On_tog_Music_Event(tog_Music)
--     AudioManager.Instance.MusicAudio.mute = not tog_Music.isOn
-- end

-- function Class:On_tog_Effect_Event(tog_Effect)
--     AudioManager.Instance.EffectAudio.mute = not tog_Effect.isOn
-- end



return _ENV