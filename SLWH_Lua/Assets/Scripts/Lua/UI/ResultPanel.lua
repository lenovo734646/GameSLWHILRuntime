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
local Vector3 = Vector3

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
    self.resultAnimals = {}
    resultInitHelper:ObjectsSetToLuaTable(self.resultAnimals)
    --
    
    
    self:HideResult()
end

-- 返回等待时间可供协程调用
function Class:ShowResult(resultPanelData)
    print("显示结算界面，功能待实现")
    local ColorType = GameConfig.ColorType
    local ExWinType = GameConfig.ExWinType
    local AnimalType = GameConfig.AnimalType
    --
    local winScore = resultPanelData.winScore or 0
    local betScore = resultPanelData.betScore or 0
    local color_id = resultPanelData.color_id
    local animal_id = resultPanelData.animal_id
    local win_enjoyGameType = resultPanelData.win_enjoyGameType
    local win_exType = resultPanelData.win_exType
    if color_id == ColorType.SanYuan then   -- 同一颜色四种动物都中奖
        color_id = resultPanelData.winSanYuanColor
        local colorSpr = 
        for i = AnimalType.Lion, AnimalType.Rabbit, 1 do
            self:__AddAnimal(i, )
        end
    elseif color_id == ColorType.SiXi then  -- 同一动物三种颜色都中奖
        for i = 1, 3, 1 do
            self:__AddAnimal(animal_id)
        end
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
    for i = 0, self.resuletScrollView.content.childCount-1, 1 do
        Destroy(self.resuletScrollView.content:GetChild(i).gameObject)
    end
end

-- 初始化一个中奖动物
function Class:__AddAnimal(animal_id, colorSpr, ratio)
    local go = Instantiate(self.resultAnimals[animal_id], self.resuletScrollView.content)
    go.transform.localPosition = Vector3.zero
    local animalData = {}
    go:GetComponent(typeof(luaInitHelper)):Init(animalData)
    animalData.color.sprite = colorSpr
    animalData.ratioText.text = ratio
    
end

function Class:__GetNumString(num)
    local numStr = tostring(num)
    if num > 0 then
        numStr = "+"..numStr
    end
    return numStr
end

return _ENV