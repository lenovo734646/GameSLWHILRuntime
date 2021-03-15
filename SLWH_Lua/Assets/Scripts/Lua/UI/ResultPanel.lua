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

local GameConfig = require'GameConfig'

_ENV = moduledef { seenamespace = CS }


local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(resultPanelGameObject)
    self.resultPanel = resultPanelGameObject
    -- 结算界面
    local resultInitHelper = self.resultPanel:GetComponent(typeof(LuaInitHelper))
    resultInitHelper:Init(self)
    self.resultWinSprs = {}
    resultInitHelper:ObjectsSetToLuaTable(self.resultWinSprs)
    --
    
    self:HideResult()
end

-- 返回等待时间可供协程调用
function Class:ShowResult(resultPanelData)
    print("显示结算界面，功能待实现")
    local ColorType = GameConfig.ColorType
    local ExWinType = GameConfig.ExWinType

    local winScore = resultPanelData.winScore or 0
    local betScore = resultPanelData.betScore or 0
    local color_id = resultPanelData.color_id
    local win_enjoyGameType = resultPanelData.win_enjoyGameType
    local win_exType = resultPanelData.win_exType
    if color_id == ColorType.SanYuan then   -- 同一颜色四种动物都中奖
        color_id = resultPanelData.winSanYuanColor
        self.animalRabbit:SetActive(true)
        self.animalPanda:SetActive(true)
        self.animalLion:SetActive(true)
        self.animalMonky:SetActive(true)
    elseif color_id == ColorType.SiXi then  -- 同一动物三种颜色都中奖
        
    end


    -- winScore = winScore or 0
    -- if winScore > 0 then
    --     self.winBG:SetActive(true)
    -- else
    --     self.loseBG:SetActive(true)
    -- end
    -- self.winIcon.sprite = self.resultWinSprs[winID]
    -- self.winRatio.text = "x"..tostring(winRatio)
    -- self.selfName.text = "我"

    -- self.selfWinScore.text = self:__GetNumString(winScore)
    -- self.selfTotalWinScore.text = self:__GetNumString(totalWinScore)
    -- -- 庄家
    -- self.bankerName = "庄家"

    -- local bankerWinText = tostring(bankerWinScore)
    -- if bankerWinScore > 0 then
    --     bankerWinText = "+"..bankerWinText
    -- end
    -- self.bankerWinScore.text = bankerWinText
    -- self.bankerTotalWinScore.text = tostring(bankerTotalWinScore)

    self.resultPanel:SetActive(true)
    return GameConfig.ShowResultTime
end

function Class:HideResult()
    self.resultPanel:SetActive(false)
end

function Class:__GetNumString(num)
    local numStr = tostring(num)
    if num > 0 then
        numStr = "+"..numStr
    end
    return numStr
end

return _ENV