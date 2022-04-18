local GS = GS
local GF = GF
local g_Env = g_Env or {}
local AssertUnityObjValid = AssertUnityObjValid or {}

local math, Log, tostring, typeof, debug, string, assert, coroutine, tonumber
    = math, Log, tostring, typeof, debug, string, assert, coroutine, tonumber

local luaItemInfo = require 'UI.Item.LuaItemInfo'
local ItemT = require 'Table.Item'

local Class = class(nil, {
    UserID = 0,
    NickName = "",
    Gender = 0, -- 0保密 1男 2女
    Head = 0,
    HeadFrame = 0,
    Level = 0,
    LevelExp = 0,
    VIPLevel = 0,
    VIPLevelExp = 0,
    Phone = "",
    Currency = 0,
    BindCurrency = 0,
    Diamond = 0,
    integral = 0,
    ItemList = {},
    IsChangeName = 0, -- 0未改过名字 1改过
    GuildId = 0,
    GuildJoinListState = false,
    UnLockGun = 0, -- 最大炮倍
    GunId = 0,
    MonthCardExpireTime = 0, -- 月卡过期时间（时间戳，单位秒）
    MonthCardHasFetched = false, -- 月卡是否领取
    FinishFirstRecharge = false, -- 首冲购买
    ReliefFinishCount = 0, -- 救济金领取次数
    HasUnReadMail = false, -- 有没有未读邮件
    HasUnReadFeedback = false, -- 有没有未读的反馈回复
    HasOnlineService = false, -- 有没有在线客服回复消息
    HasNewQA = false, -- 常见问题配置表有没有更新
    FetchedFirstPackage = false,
    MultipleHit = 0, -- 倍击倍数
    BankPasswordFlag = false, -- 银行密码是否重置过
    LaserGunEnergy = 0, -- 激光炮能量
    RunningGameServer = "", -- 当前进入的游戏服务器名称
    RankRewardGold = false, -- 排行榜金币奖励是否领取
    RankRewardWarhead = false, -- 排行榜弹头奖励是否领取
    MagicValue = 0, -- 魔力值
    MagicItemId = 0,
    MagicFactor = 0,
    BankCurrency = 0, -- 银行资产
    customHeadData = {},
    HeadUrl = '',
    Token = '',
})

function Class:SetData(ack)
    self:__init(ack)
    Log("GamePlayer SetData NickName = ", self.NickName, self.Level)
end

function Class:__init(ack)
    if ack == nil then
        return
    end
    self.UserID = ack.user_id
    self.NickName = ack.nickname
    self.IsChangeName = ack.nickname_mdf and 1 or 0
    self.Gender = ack.gender
    self.Head = ack.head
    self.HeadFrame = ack.head_frame
    self.Level = ack.level
    self.LevelExp = ack.level_exp
    self.VIPLevel = ack.vip_level
    self.VIPLevelExp = ack.vip_level_exp
    self.Phone = ack.phone
    self.Currency = ack.currency
    self.BankCurrency = ack.bank_currency
    self.BindCurrency = ack.bind_currency
    self.Diamond = ack.diamond
    self.integral = ack.integral
    self.HeadUrl = ack.head_url
    for i = 1, #(ack.items) do
        local item = ack.items[i]
        local itemInfo = luaItemInfo(item.item_id, item.item_sub_id, item.item_count)
        table.insert(self.ItemList, itemInfo)
    end
    GS.TimeHelper.SetServerTimestamp(ack.server_timestamp * 1000)
    self.GuildId = ack.guild_id
    self.GuildJoinListState = ack.guild_join_list_state
    self.MonthCardExpireTime = ack.month_card_expire_time
    self.MonthCardHasFetched = ack.month_card_has_fetched
    self.FinishFirstRecharge = ack.finish_first_recharge
    self.ReliefFinishCount = ack.relief_finish_count
    self.HasUnReadMail = ack.has_unread_mail
    self.FetchedFirstPackage = ack.fetched_first_package
    local max_gun_value = ack.max_gun_value
    -- local fistGun = GF.table.FindBy(FishGunForgeT, function(g)
    --     return g.Id == 1
    -- end)
    self.UnLockGun = max_gun_value --math.max(max_gun_value, fistGun.GunValue)
    self.BankPasswordFlag = ack.bank_password_flag
    self.RankRewardGold = ack.rank_reward_gold
    self.RankRewardWarhead = ack.rank_reward_warhead
    self.MagicValue = ack.magic_value
    self.MagicItemId = ack.magic_item_id
    self.MagicItemSubId = ack.magic_item_sub_id
    self.MagicFactor = ack.magic_factor
    -- Log("打印出luagamePlayer:"..GF.table.Log(self))
end
-- 设置金币
function Class:SetCurrency(currency)
    if self.Currency ~= currency then
        local _oldValue = self.Currency
        self.Currency = currency
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.Currency
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_CURRENCY_CHANGED", msg)
    end
end
-- 设置银行资产
function Class:SetBankCurrency(bankCurrency)
    if self.BankCurrency ~= bankCurrency then
        local _oldValue = self.BankCurrency
        self.BankCurrency = bankCurrency
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.BankCurrency
        }
        g_Env.messageCenter:SendMessage("CLIENT_BANK_CURRENCY_CHANGED", msg)
    end
end

-- 设置钻石
function Class:SetDiamond(diamond)
    if self.Diamond ~= diamond then
        local _oldValue = self.Diamond
        self.Diamond = diamond
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.Diamond
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_DIAMOND_CHANGED", msg)
    end
end
-- 道具变化
function Class:SetItem(items)
    if GF.table.nums(items) > 0 then
        for i = 1, #items do
            local t = luaItemInfo(items[i].item_id, items[i].item_sub_id, items[i].item_count)
            local item = GF.table.FindBy(self.ItemList, function(a)
                return a.ItemID == t.ItemID and a.ItemSubID == t.ItemSubID
            end)
            if item ~= nil then
                item.ItemCount = t.ItemCount
            else
                table.insert(self.ItemList, t)
            end
            local _content = ItemT[items[i].item_id][items[i].item_sub_id]

            g_Env.messageCenter:SendMessage("CLIENT_PLAYER_ITEM_CHANGED", {
                sender = self,
                content = _content
            })
        end
    end
end
-- 获取背包道具
function Class:GetItem(id, subId)
    if #(self.ItemList) == 0 then
        return nil
    else
        local item = GF.table.FindBy(self.ItemList, function(a)
            return a.ItemID == id and a.ItemSubID == subId
        end)
        return item
    end
end
-- 解锁最大炮倍变化
function Class:SetUnLockGun(unLockGun, delta)
    if self.UnLockGun ~= unLockGun then
        local _oldValue = self.UnLockGun
        self.UnLockGun = unLockGun
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = unLockGun,
            delta = delta
        }
        Log("玩家炮台倍数:" .. tostring(self.UnLockGun))
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_UNLOCKGUN_CHANGED", msg)
    end
end

-- 切换炮台
function Class:SwitchGun(gunId)
    if self.GunId ~= gunId then
        self.GunId = gunId
    end
end
-- 强同步
function Class:SyncResource(diamond, currency, integral)
    if self.Diamond ~= diamond then
        self.Diamond = diamond
    end
    if self.Currency ~= currency then
        self.Currency = currency
    end
    if self.integral ~= integral then
        self:DeltaIntegral(integral - self.integral)
    end
end

-- 钻石变化
function Class:DeltaDiamond(delta, _reason)
    if delta ~= 0 then
        if _reason == nil then
            _reason = 0
        end
        local _oldValue = self.Diamond
        self.Diamond = self.Diamond + delta
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.Diamond,
            delta = delta,
            reason = _reason
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_DIAMOND_CHANGED", msg)
    end
end
-- 金币变化
function Class:DeltaCurrency(delta, _reason)
    if delta ~= 0 then
        if _reason == nil then
            _reason = 0
        end
        local _oldValue = self.Currency
        self.Currency = self.Currency + delta
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.Currency,
            delta = delta,
            reason = _reason
        }

        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_CURRENCY_CHANGED", msg)

        --给小游戏发送(兼容措施)
        if GS.MessageCenter and GS.MessageCenter.instance then
            local ppt = {
                Reason = _reason,
                Delta = delta,
                NewValue = self.Currency,
                OldValue = _oldValue,
            }
            msg.get_Item = function (_,param)
                if param=="Params" then
                    return {
                        get_Item = function (_,p)
                            if p=='0' then
                                return {
                                    get_Item = function (_,pp)
                                        return ppt[pp]
                                    end
                                }
                            end
                        end
                    }
                end
                
            end
            GS.MessageCenter.instance:SendMessage("CLIENT_PLAYER_CURRENCY_CHANGED", msg)
        end
    end
end

function Class:DeltaBankCurrency(delta, _reason)
    if delta ~= 0 then
        local _oldValue = self.BankCurrency
        self.BankCurrency = self.BankCurrency + delta
        -- Log("玩家增加的银行金币数:" .. tostring(delta))
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.BankCurrency,
            delta = delta
        }
        g_Env.messageCenter:SendMessage("CLIENT_BANK_CURRENCY_CHANGED", msg)
    end
end
-- 绑定金币变化
function Class:DeltaBindCurrency(delta, _reason)
    if delta ~= 0 then
        if _reason == nil then
            _reason = 0
        end
        local _oldValue = self.BindCurrency
        self.BindCurrency = self.BindCurrency + delta
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.BindCurrency,
            delta = delta,
            reason = _reason
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_BINDCURRENCY_CHANGED", msg)
    end
end
-- 积分变化
function Class:DeltaIntegral(delta, _reason)
    if delta ~= 0 then
        if _reason == nil then
            _reason = 0
        end
        local _oldValue = self.integral
        self.integral = self.integral + delta
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.integral,
            delta = delta,
            reason = _reason
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_INTEGRAL_CHANGED", msg)
    end
end

-- 设置头像
function Class:SetNewHead(headId)
    if headId ~= self.Head then
        local _oldValue = self.Head
        self.Head = headId
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = headId
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_HEADID", msg)
        g_Env.accountListManager:UpdateAccountHead(headId)
    end
end
-- 设置头像框
function Class:SetNewFrame(frameId)
    if frameId ~= self.HeadFrame then
        local _oldValue = self.HeadFrame
        self.HeadFrame = frameId
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = frameId
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_FRAMEID", msg)
        g_Env.accountListManager:UpdateAccountFrame(frameId)
    end
end
-- 设置昵称
function Class:SetNickName(nickName)
    if nickName ~= self.NickName then
        local _oldValue = self.NickName
        self.NickName = nickName
        self.IsChangeName = 1
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = nickName
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_NICKNAME", msg)
        g_Env.accountListManager:UpdateAccountNickname(nickName)
    end
end
-- vip经验变化
function Class:SetVipLevel(vipLevel, vipLevelExp)
    local vipLevelChange = (self.VIPLevel ~= vipLevel)
    self.VIPLevel = vipLevel
    self.VIPLevelExp = vipLevelExp
    local msg = {
        sender = self,
        VIPLevel = vipLevel,
        VIPLevelExp = vipLevelExp,
        VIPLevelChange = vipLevelChange
    }
    g_Env.messageCenter:SendMessage("CLIENT_PLAYER_VIPLEVEL", msg)
end
-- 经验变化
function Class:SetLevelExp(exp)
    self.LevelExp = exp
    local msg = {
        sender = self,
        Exp = exp
    }
    g_Env.messageCenter:SendMessage("CLIENT_PLAYER_LEVELEXP", msg)
end
-- 等级变化
function Class:SetLevel(level, items)
    self.Level = level
    local msg = {
        sender = self,
        Level = level,
        Items = items
    }
    g_Env.messageCenter:SendMessage("CLIENT_PLAYER_LEVEL", msg)
end

-- 设置倍击倍数
function Class:SetMultipleHitRate(rate)
    self.MultipleHit = rate
    g_Env.messageCenter:SendMessage("ROOM_MUILTIPLE_HIT_CHANGE", {
        sender = self
    })
end

-- 设置激光炮能量
function Class:SetLaserEnergy(value)
    self.LaserGunEnergy = value
    g_Env.messageCenter:SendMessage("ROOM_PLAYER_LASER_ENERGY_CHANGE", {
        sender = self
    })
end

-- 能量值变化
function Class:DeltaLaserEnergy(delta)
    if delta ~= 0 then
        self.LaserGunEnergy = self.LaserGunEnergy + delta
        if self.LaserGunEnergy < 0 then
            self.LaserGunEnergy = 0
        end
        g_Env.messageCenter:SendMessage("ROOM_PLAYER_LASER_ENERGY_CHANGE", {
            sender = self
        })
    end
end
-- 设置魔力值
function Class:SetMagicValue(value)
    if self.MagicValue ~= value then
        local _oldValue = self.MagicValue
        self.MagicValue = value
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = value
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_MAGIC_CHANGED", msg)
    end
end
-- 能量值变化
function Class:DeltaMagicValue(delta, _reason)
    if delta ~= 0 then
        if _reason == nil then
            _reason = 0
        end
        local _oldValue = self.MagicValue
        self.MagicValue = self.MagicValue + delta
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = self.MagicValue,
            delta = delta,
            reason = _reason
        }
        g_Env.messageCenter:SendMessage("CLIENT_PLAYER_MAGIC_CHANGED", msg)
    end
end

-- 月卡时间变化
function Class:SetMonthCardExpireTime(value)
    if self.MonthCardExpireTime ~= value then
        local _oldValue = self.MonthCardExpireTime
        self.MonthCardExpireTime = value
        local msg = {
            sender = self,
            oldValue = _oldValue,
            newValue = value
        }
        Log("发送月卡时间变化消息: ",self.MonthCardExpireTime, value)
        g_Env.messageCenter:SendMessage("CLIENT_MONTHCARD_REFRESH", msg)
    end
end

function Class:Release()
    self.UserID = 0
    self.NickName = ""
    self.IsChangeName = 0
    self.Gender = 0
    self.Head = 0
    self.HeadFrame = 0
    self.Level = 0
    self.LevelExp = 0
    self.VIPLevel = 0
    self.VIPLevelExp = 0
    self.Phone = ""
    self.Currency = 0
    self.BankCurrency = 0
    self.BindCurrency = 0
    self.Diamond = 0
    self.integral = 0
    GS.TimeHelper.SetServerTimestamp(0)
    self.GuildId = 0
    self.GuildJoinListState = false
    self.MonthCardExpireTime = 0
    self.MonthCardHasFetched = false
    self.FinishFirstRecharge = false
    self.ReliefFinishCount = 0
    self.HasUnReadMail = false
    self.FetchedFirstPackage = false
    self.UnLockGun = 0
    self.BankPasswordFlag = false
    self.RankRewardGold = false
    self.RankRewardWarhead = false
    self.MagicValue = 0
    self.MagicItemId = 0
    self.MagicItemSubId = 0
    self.MagicFactor = 0
end

return Class
