

-- 结算界面
local Class = class()

function Create(...)
    return Class(...)
end


function Class:__init(resultPanelGameObject)
    self.resultPanel = resultPanelGameObject
    -- 结算界面
    local resultInitHelper = self.resultPanel:GetComponent(typeof(GS.LuaInitHelper))
    resultInitHelper:Init(self)
    self.resultAnimals = {} -- 普通中奖动物
    resultInitHelper:ObjectsSetToLuaTable(self.resultAnimals)
    --
    local multiList = {}
    local multiListInitHelper = self.resultPanel:GetComponent(typeof(GS.LuaInitMultiListHelper))
    multiListInitHelper:Init(multiList)
    --
    self.enjoyGameData = {}
    self.winEnjoyResult = {}
    self.winEnjoyGameInitHelper:Init(self.enjoyGameData)
    self.winEnjoyGameInitHelper:ObjectsSetToLuaTable(self.winEnjoyResult)

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
    self.resultAnimals_Gold = multiList.resultAnimals_Gold -- 三元四喜黄金中奖动物

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
    for _, enjoyResult in pairs(self.winEnjoyResult) do
        enjoyResult:SetActive(false)    -- 先重置一下
    end
    local enjoyGameData = resultPanelData.enjoyGameData
    self.winEnjoyResult[enjoyGameData.enjoyGame_id]:SetActive(true)
    self.enjoyGameData.ratioText.text = "x"..enjoyGameData.enjoyGameRatio
    self.enjoyGameData.winEnjoyGameGO:SetActive(true)
    -- 颜色(普通中奖+三元四喜)
    if color_id == ColorType.SiXi then   -- 同一颜色四种动物都中奖
        self.winSiXi:SetActive(true)
        local data = resultPanelData.sixiData
        local colorSpr = self.smallColors[data.sixiColor_id]
        for i = AnimalType.Lion, AnimalType.Rabbit, 1 do
            print("四喜动物倍率:", i, data.animalRatioArray[i])
            self:__AddAnimal(i, colorSpr, data.animalRatioArray[i], self.resultAnimals_Gold, true)
        end
        
    elseif color_id == ColorType.SanYuan then  -- 同一动物三种颜色都中奖
        self.winSanYuan:SetActive(true)
        local data = resultPanelData.sanyuanData
        for i = ColorType.Red, ColorType.Yellow, 1 do
            local spr = self.smallColors[i]
            self:__AddAnimal(data.animal_id, spr, data.animalRatioArray[i], self.resultAnimals_Gold, true)
        end
    else
        self.winAnimalData.winAnimalGO:SetActive(true)
        local data = resultPanelData.normalData
        self:__AddAnimal(data.animal_id, self.smallColors[color_id], data.ratio, self.resultAnimals, false)
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
        self.winShanDianData.ratio.text = tostring(resultPanelData.shandian_ratio)

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
        self:__AddAnimal(data.songDengAnimalID, self.smallColors[data.songDengColorID], ratio, self.resultAnimals)

    end


    return GameConfig.ShowResultTime
end

function Class:HideResult()
    self.resultPanel:SetActive(false)
    for i = 0, self.resuletScrollView.content.childCount-1, 1 do
        GS.Destroy(self.resuletScrollView.content:GetChild(i).gameObject)
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
function Class:__AddAnimal(animal_id, colorSpr, ratio, resultAnimals, isSanYuanSiXi)
    local go = GS.Instantiate(resultAnimals[animal_id], self.resuletScrollView.content)
    go.transform.localPosition = GS.Vector3.zero
    local animalData = {}
    go:GetComponent(typeof(GS.LuaInitHelper)):Init(animalData, false)
    animalData.color.sprite = colorSpr
    animalData.ratioText.text = "x"..ratio
    if not isSanYuanSiXi then
        animalData.animator:Play("Victory", 0, 0);
        animalData.animator:SetTrigger("tResultVictoryToIdel1")
    else
        animalData.animator:Play("SanYuanSiXi", 0, 0);
    end

    
end

function Class:__GetNumString(num)
    local numStr = tostring(num)
    if num > 0 then
        numStr = "+"..numStr
    end
    return numStr
end

return Class