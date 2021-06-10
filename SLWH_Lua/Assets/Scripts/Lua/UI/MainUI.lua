local _G, g_Env = _G, g_Env
local class = class
local print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs =
      print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs

local DOTween = CS.DG.Tweening.DOTween

local tinsert = table.insert
local tremove = table.remove
local tonumber = tonumber

local CoroutineHelper = require'CoroutineHelper'
local yield = coroutine.yield

local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject

local SubGame_Env = SubGame_Env
local ChatPanel = require'ChatSystem.ChatPanel'
local ResultPanel = require'UI.ResultPanel'
local UserInfo = require'UI.UserInfo'
local TimerCounterUI = require 'UI.TimerCounterUI'
local PlayerListPanel = require'PlayerList.PlayerListPanel'
local AudioManager = AudioManager or CS.AudioManager

_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(panel, roomdata, loader)
    self.panel = panel
    panel:GetComponent(typeof(LuaInitHelper)):Init(self)
    self.eventListener:Init(self)

    -- 聊天界面
    self.chatPanel = ChatPanel.Create(self.ChatPanel, SubGame_Env.loader, SubGame_Env.playerRes)
    -- 玩家列表界面
    self.playerListPanel = PlayerListPanel.Create(self.playerListPanel)

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
    
    self.tog_Music.isOn = AudioManager.Instance.MusicVolum ~= 0
    self.tog_Effect.isOn = AudioManager.Instance.EffectVolm ~= 0

    self.gameStateSpineHelper.gameObject:SetActive(true)

end

-- 设置统计数据
function Class:SetStatisticData(sixiCount, sanyuanCount, zhuangCount, xianCount, heCount, allGameCount)
    print("设置统计数据：", sixiCount, sanyuanCount, zhuangCount, xianCount, heCount, allGameCount)
    self.statisicalData.sixiText.text =  string.Format2(_STR_" 大四喜x{1} ",(sixiCount))
    self.statisicalData.sanyuanText.text =  string.Format2(_STR_" 大三元x{1} ",(sanyuanCount))
    self.statisicalData.zhuangText.text =  string.Format2(_STR_" 庄x{1} ",(zhuangCount))
    self.statisicalData.xianText.text =  string.Format2(_STR_" 闲x{1} ",(xianCount))
    self.statisicalData.heText.text =  string.Format2(_STR_" 和x{1} ",(heCount))
    self.statisicalData.allText.text =  string.Format2(_STR_" 总局数x{1} ",(allGameCount))
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
    self.betText.text = SubGame_Env.ConvertNumberToString(betScore)
end

-- 设置当前局数（自己游戏局数非服务器总局数）
function Class:SetGameCount(count)
    self.gameCountText.text = SubGame_Env.ConvertNumberToString(count)
end

-- 以下代码为自动生成代码，请勿更改
function Class:On_tog_PlayerListPanel_Event(tog_PlayerList)
    print("发送玩家列表请求")
    self.playerListPanel:OnSendPlayerListReq()
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

function Class:On_tog_Music_Event(tog_Music)
    AudioManager.Instance.MusicVolum = tog_Music.isOn and 1 or 0
end

function Class:On_tog_Effect_Event(tog_Effect)
    AudioManager.Instance.EffectVolm = tog_Effect.isOn and 1 or 0
end



return _ENV