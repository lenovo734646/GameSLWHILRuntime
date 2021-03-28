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
    local multiList = {}
    local multiListInitHelper = self.resultPanel:GetComponent(typeof(LuaInitMultiListHelper))
    multiListInitHelper:Init(multiList)
    --
    self.enjoyGameData = {}
    self.winEnjoyGameInitHelper:Init(self.enjoyGameData)
    self.winAnimalData = {}
    self.winAnimalInitHelper:Init(self.winAnimalData)
    self.winShanDianData = {}
    self.winShandianInitHelper:Init(self.winShanDianData)
    self.winCaiJinData = {}
    self.winCaiJinInitHelper:Init(self.winCaiJinData)
    self.winSongDengData = {}
    self.winSongDengInitHelper:Init(self.winSongDengData)
    --

    self.smallColors = multiList.smallColors
    self.bgColors = multiList.bgColors
    self.animalNameSprs = multiList.animalNameSprs
    self.animalSprs = multiList.animalSprs
    self.enjoyTypeSprs = multiList.enjoyTypeSprs

    self:HideResult()
end

-- 返回等待时间可供协程调用
function Class:ShowResult(resultPanelData)
    if resultPanelData.enjoyGameData == nil then
        return
    end

    self.resultPanel:SetActive(true)
    local ColorType = GameConfig.ColorType
    local ExWinType = GameConfig.ExWinType
    local AnimalType = GameConfig.AnimalType
    --
    local winScore = resultPanelData.winScore or 0
    local betScore = resultPanelData.betScore or 0
    local color_id = resultPanelData.color_id
    local exType = resultPanelData.exType
    --
    self.betText.text = tostring(betScore)
    self.winText.text = self:__GetNumString(winScore)
    --庄闲和小游戏
    local enjoyGameData = resultPanelData.enjoyGameData
    print("显示结算界面 enjoyGame_id：", enjoyGameData.enjoyGame_id)
    self.enjoyGameData.winColorBG = self.bgColors[enjoyGameData.enjoyGame_id]
    self.enjoyGameData.enjoyImg.sprite = self.enjoyTypeSprs[enjoyGameData.enjoyGame_id]
    self.enjoyGameData.ratioText.text = "x"..enjoyGameData.enjoyGameRatio
    self.enjoyGameData.winEnjoyGameGO:SetActive(true)
    -- 颜色(普通中奖+三元四喜)
    if color_id == ColorType.SanYuan then   -- 同一颜色四种动物都中奖
        self.winSanYuan:SetActive(true)
        local data = resultPanelData.sanyuanData
        local colorSpr = self.smallColors[data.sanyuanColor_id]
        for i = AnimalType.Lion, AnimalType.Rabbit, 1 do
            self:__AddAnimal(i, colorSpr, data.animalRatioArray[i])
        end
        
    elseif color_id == ColorType.SiXi then  -- 同一动物三种颜色都中奖
        self.winSiXi:SetActive(true)
        local data = resultPanelData.sixiData
        for i = ColorType.Red, ColorType.Yellow, 1 do
            local spr = self.smallColors[i]
            self:__AddAnimal(data.animal_id, spr, data.animalRatioArray[i])
        end
        
    else
        self.winAnimalData.winAnimalGO:SetActive(true)
        local data = resultPanelData.normalData
        self:__AddAnimal(data.animal_id, self.smallColors[color_id], data.ratio)
        --
        self.winAnimalData.winColorBG.sprite = self.bgColors[color_id]
        self.winAnimalData.animalImg.sprite = self.animalSprs[data.animal_id]
        self.winAnimalData.animalImg:SetNativeSize()
        self.winAnimalData.ratioText.text = "x"..tostring(data.ratio)
        
    end

    -- 额外大奖
    if exType == ExWinType.CaiJin then
        self.winCaiJinData.winCaiJiGO:SetActive(true)
        self.winCaiJinData.ratio.text = " x"..tostring(resultPanelData.caijin_ratio)
    elseif exType == ExWinType.LiangBei or exType == ExWinType.SanBei then
        self.winShanDianData.winShandianGO:SetActive(true)
        self.winShanDianData.ratio.text = " x"..tostring(resultPanelData.shandian_ratio)

    elseif exType == ExWinType.SongDeng then
        self.winSongDengData.winSongDengGO:SetActive(true)
        local data = resultPanelData.songdengData
        local color = self.bgColors[data.songDengColorID]
        local animal = self.animalSprs[data.songDengAnimalID]
        local ratio = data.songDengRatio
        self.winSongDengData.winColorBG.sprite = color
        self.winSongDengData.animalImg.sprite = animal
        self.winSongDengData.animalImg:SetNativeSize()
        self.winSongDengData.ratio.text = "x"..tostring(ratio)
        self:__AddAnimal(data.songDengAnimalID, self.smallColors[data.songDengColorID], ratio)

    end


    return GameConfig.ShowResultTime
end

function Class:HideResult()
    self.resultPanel:SetActive(false)
    for i = 0, self.resuletScrollView.content.childCount-1, 1 do
        Destroy(self.resuletScrollView.content:GetChild(i).gameObject)
    end
    --
    --self.enjoyGameData.winEnjoyGameGO:SetActive(false)
    self.winSanYuan:SetActive(false)
    self.winSiXi:SetActive(false)
    self.winAnimalData.winAnimalGO:SetActive(false)
    self.winCaiJinData.winCaiJiGO:SetActive(false)
    self.winShanDianData.winShandianGO:SetActive(false)
    self.winSongDengData.winSongDengGO:SetActive(false)
end

-- 初始化一个中奖动物
function Class:__AddAnimal(animal_id, colorSpr, ratio)
    local go = Instantiate(self.resultAnimals[animal_id], self.resuletScrollView.content)
    go.transform.localPosition = Vector3.zero
    local animalData = {}
    go:GetComponent(typeof(LuaInitHelper)):Init(animalData, false)
    animalData.color.sprite = colorSpr
    animalData.ratioText.text = "x"..ratio
    animalData.animator:Play("Jump", 0, 0);
    
end

function Class:__GetNumString(num)
    local numStr = tostring(num)
    if num > 0 then
        numStr = "+"..numStr
    end
    return numStr
end

return _ENV