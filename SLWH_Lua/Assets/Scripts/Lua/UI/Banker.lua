local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local DOTween = CS.DG.Tweening.DOTween

local tinsert = table.insert
local tremove = table.remove
local tonumber = tonumber

local CoroutineHelper = require'CoroutineHelper'
local yield = coroutine.yield

local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject

local CLBCBMSender = require'protobuffer.CLBCBMSender'
local GameConfig = require'GameConfig'

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(bankerInitHelper, selfUserID)
    self.selfUserID = selfUserID
    bankerInitHelper:Init(self)
    self.bankerEventListener:Init(self)

    --self.bankerHeadImg.sprite = nil
    --self.bankerHeadFrame.sprite = nil
    self.bankerUserID = -1
    self.bankerMoneyText.text = "999999"
    self.bankerNameText.text = "系统坐庄"
    self.waitingBankerName.text = ""
    
    -- 
    self.btnBankerText.text = "上庄"
    -- 我的上庄状态：0没上庄，1庄家队列排队中， 2 庄家
    self.state = 0 

end

-- 0成功 1不在房间中, 2分数不足 3vip等级不够 4 已经是庄家
local ErrMsg = {"上庄失败,不在房间中", "上庄失败,分数不足,至少需要100W分", "上庄失败,VIP等级不够,至少需要VIP3", "已经是庄家"}
function Class:On_btnToBanker_Event(btnToBanker)
    if self.state == 0 then
        print("申请上庄...")
        CLBCBMSender.Send_ApplyBankerReq(function (data)
            print("Send_ApplyBankerAck errCode = ", data.errcode)
            local errcode = data.errcode
            if errcode ~= 0 then
                print(ErrMsg[errcode])
            else
                print("申请上庄成功...")
                self:SetState(1)
            end
        end)
    else
        self:On_btnCancelBanker_Event()
    end

end

--0成功  1 不在房间中 2已经是庄家，本局结束自动下庄 
function Class:On_btnCancelBanker_Event()
    print("客户端发送申请下庄...")
    CLBCBMSender.Send_CancelApplyBankerReq(function (data)
        print("服务端返回申请下庄...", data.errcode)
        if data.errcode == 0 then
            print("申请下庄成功...")
            self:SetState(0)
        elseif data.errcode == 1 then
            print("不在房间中")
        elseif data.errcode == 2 then
            print("已经是庄家，本局结束自动下庄")
        else
            print("未知错误：", data.errcode)
        end
    end)
end

function Class:OnChangeBanker(bankerUserID, bankerName, bankerMoney, head, headFrame, nextName)
    self.bankerUserID = bankerUserID
    if bankerUserID < 0 then
        -- 系统坐庄
        self.bankerNameText.text = "系统坐庄"
    else
        -- 玩家坐庄
        self.bankerNameText.text = bankerName
    end
    print("切换庄家 ", bankerUserID, self.state)
    if self:IsBanker() then
        self:SetState(2)
    else
        if self.state == 2 then
            self:SetState(0)
        end
    end
    --self.bankerHeadImg.sprite = nil
    --self.bankerHeadFrame.sprite = nil
    self.bankerMoneyText.text = tostring(bankerMoney)
    self.waitingBankerName.text = nextName
end

function Class:ChangeMoney(bankerMoney)
    if self.bankerUserID > 0 then
        self.bankerMoneyText.text = tostring(bankerMoney)
    end
end

-- 上庄状态：0没上庄，1庄家队列排队中， 2 庄家
function Class:SetState(state)
    self.state = state
    if state == 0 then
        self.btnBankerText.text = "上庄"
    elseif state == 1 then
        self.btnBankerText.text = "离开上庄队列"
    elseif state == 2 then
        self.btnBankerText.text = "下庄"
    end
end
-- 自己是否为庄家
function Class:IsBanker()
    return self.bankerUserID == self.selfUserID
end



return _ENV