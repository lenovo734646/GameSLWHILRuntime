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
    -- self.btnOK.onClick:AddListener(function ()
    --     self:HideResult()
    -- end)
    
    self:HideResult()
end

-- 返回等待时间可供协程调用
function Class:ShowResult(winID, winRatio, winScore, totalWinScore, bankerWinScore, bankerTotalWinScore)
    print("显示结算界面，功能待实现")

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