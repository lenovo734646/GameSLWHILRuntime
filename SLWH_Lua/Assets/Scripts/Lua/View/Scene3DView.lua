
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local DOTween = CS.DG.Tweening.DOTween

local tinsert = table.insert
local tremove = table.remove
local tonumber = tonumber

local CoroutineHelper = require'CoroutineHelper'
local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject
local EditorAssetLoader = CS.EditorAssetLoader

local yield = coroutine.yield
local AudioManager = AudioManager or CS.AudioManager
local Scene3DViewCtrl = require'controller.Scene3DViewCtrl'
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local GameConfig = require'GameConfig'

local OSACore = CS.Com.TheFallenGames.OSA.Core
local ItemCountChangeMode = OSACore.ItemCountChangeMode

local MainUI =  require'UI.MainUI'



_ENV = moduledef { seenamespace = CS }

local RUN_ITEM_COUNT = GameConfig.RunItemCount

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(roomdata)

    local View = GameObject.Find('View')
    self.gameObject = View
    local initHelper = View:GetComponent(typeof(LuaInitHelper))
    initHelper:Init(self)
    self.colorMeshMaterialList = {}
    initHelper:ObjectsSetToLuaTable(self.colorMeshMaterialList)

    -- UI
    self.mainUI = MainUI.Create(self.mainUIInitHelper, roomdata, EditorAssetLoader)
    -- 中间获胜动物舞台
    local winStageChildren = {}
    self.winStageInitHelper:Init(winStageChildren)
    local winStageDataList = {}
    local indexToFindMap = {}   -- 下标对应的winStageData
    for name,child in pairs(winStageChildren) do
        local arr = string.split(name,',')
        local gameObject = child.gameObject
        local childdata = {
            transform = child,
            gameObject = gameObject,
            item_id = tonumber(gameObject.name),
            animatorHelper = child:GetComponent(typeof(ForReBuild.UIHelper.AnimatorHelper)), 
        }
        tinsert(winStageDataList, childdata)
        gameObject:SetActive(false)
        for k, v in pairs(arr)do
            local n = tonumber(v)
            if n then
                assert(indexToFindMap[n]==nil)
                indexToFindMap[n] = childdata
            end
        end
    end
    self.winStageDataList = winStageDataList

    -- 外圈动物
    local runItemIndexs = self.runItemIndexs
    local runItemDataList = {}
    for i=1,RUN_ITEM_COUNT do
        local t = runItemIndexs:GetChild(i-1)
        local animatorHelper = t:GetComponent(typeof(ForReBuild.UIHelper.AnimatorHelper)) 
        --print("animatorHelper = ",animatorHelper)
        local data = {
            transform = t,
            animatorHelper = animatorHelper,
            winShowData = indexToFindMap[i],
            index = i,
            Play = function ()
                -- run item 
                AudioManager.Instance:PlaySoundEff2D("run")
            end,
            OnTriggerEnter = function (self)
                local uictrl = self.uictrl
                if uictrl then
                    uictrl:OnAnimalTrigger(i)
                end
            end,
        }
        tinsert(runItemDataList, data)
    end
    self.runItemDataList = runItemDataList

    -- 内圈颜色
    local colorDataList = {}
    local colorCount = self.colorRootTransform.childCount
    for i = 0, colorCount-1, 1 do
        local data = {
            colorMesh = self.colorRootTransform:GetChild(i):GetComponent("MeshRenderer"),
            animator = self.colorRootTransform:GetChild(i):GetComponent("Animator"),
        }
        tinsert(colorDataList, data)
    end
    self.colorDataList = colorDataList
    -- 下注区
    local betAreaBtnInitHelpers = self.betAreaBtnsInitHelper.objects
    local betAreaList = {}
    for i = 1, betAreaBtnInitHelpers.Length do
        local helper = betAreaBtnInitHelpers[i-1]
        local item_id = tonumber(helper.name)
        
        if helper.t==nil then
            local data = {
                item_id = item_id,
            }
            helper:Init(data,false)
        end
        
        betAreaList[item_id] = helper.t
    end
    self.betAreaList = betAreaList

    -- 路单区
    local roadScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.roadScrollView = roadScrollView
    --数据提供接口实现
    roadScrollView.OnCreateViewItemData = function (itemViewGameObject,itemIndex)
        local viewItemData = {}
        itemViewGameObject:GetComponent(typeof(LuaInitHelper)):Init(viewItemData)
        viewItemData.gameObject = itemViewGameObject
        return viewItemData
    end
    --数据更新接口实现（itemViewGameObject会自动回收使用，所以需要对itemViewGameObject进行更新）
    roadScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        local SetAnimalImg = function (animalImg, spr)
            animalImg.sprite = spr
            animalImg:SetNativeSize()
        end

        viewItemData.colorImg.sprite = itemdata.colorSpr
        SetAnimalImg(viewItemData.animalImg, itemdata.animalSpr)
        viewItemData.enjoyTypeImg.sprite = itemdata.enjoyTypeSpr
        print("itemdata.colorSpr = ", itemdata.colorSpr, itemdata.animalSpr, itemdata.enjoyTypeSpr)
        --
        if itemdata.sanYuanInfo ~= nil then
            local syData = {}
            viewItemData.sanYuanInitHelper:Init(syData)
            syData.item_1.sprite = itemdata.colorSpr
            syData.item_2.sprite = itemdata.colorSpr
            syData.item_3.sprite = itemdata.colorSpr
            syData.item_4.sprite = itemdata.colorSpr
            syData.animal_1.sprite = itemdata.sanYuanInfo.animalSpr_1
            syData.animal_2.sprite = itemdata.sanYuanInfo.animalSpr_2
            syData.animal_3.sprite = itemdata.sanYuanInfo.animalSpr_3
            syData.animal_4.sprite = itemdata.sanYuanInfo.animalSpr_4
            viewItemData.sanYuanInitHelper.gameObject:SetActive(true)
        elseif itemdata.siXiInfo ~= nil then
            local sxData = {}
            viewItemData.siXiInitHelper:Init(sxData)
            sxData.item_1.sprite = itemdata.siXiInfo.colorSpr_1
            sxData.item_2.sprite = itemdata.siXiInfo.colorSpr_2
            sxData.item_3.sprite = itemdata.siXiInfo.colorSpr_3
            sxData.animal_1.sprite = itemdata.siXiInfo.animalSpr
            sxData.animal_2.sprite = itemdata.siXiInfo.animalSpr
            sxData.animal_3.sprite = itemdata.siXiInfo.animalSpr
            viewItemData.siXiInitHelper.gameObject:SetActive(true)
        end
        --
        if itemdata.shanDianRatio ~= nil then
            local sdData = {}
            viewItemData.shanDianInitHelper:Init(sdData)
            sdData.ratio.text = tostring(itemdata.shanDianRatio)
            viewItemData.shanDianInitHelper.gameObject:SetActive(true)
        elseif itemdata.songDengInfo ~= nil then
            local songDengData = {}
            viewItemData.songDengInitHelper:Init(songDengData)
            songDengData.colorImg.sprite = itemdata.songDengInfo.songDengColorSpr
            songDengData.animalImg.sprite = itemdata.songDengInfo.songDengAnimalSpr
            viewItemData.songDengInitHelper.gameObject:SetActive(true)
        end
        
    end
    roadScrollView.OSAScrollView.ChangeItemsCountCallback = function (_, changeMode, changedItemCount)
        if changeMode == ItemCountChangeMode.INSERT then    --插入则自动滚动到末尾
            local itemsCount = self.roadScrollView:GetItemsCount()
            local tarIndex = itemsCount-1
            local DoneFunc = function ()
                if itemsCount > 100 then
                    self.roadScrollView:RemoveOneFromStart(true)
                end
            end
            self.roadScrollView:SmoothScrollTo(tarIndex, 0.1, nil, DoneFunc)
        end
    end

    local roadMultiList = {}
    self.roadInitMultiListHelper:Init(roadMultiList)
    self.roadColorSprites = roadMultiList.bgColorSprs
    self.roadAnimalSprites = roadMultiList.roadAnimalSprites
    self.roadEnjoyTypeSprites = roadMultiList.roadEnjoyTypeSprites
    self.roadExSprites = roadMultiList.roadExSprites
    
    self.roadMultiList = nil

    -- 筹码选择
    self.betSelectToggles = {}
    self.betSelectBtnsInitHelper:ObjectsSetToLuaTable(self.betSelectToggles)
    self.betSelectBtnsInitHelper = nil


    -- ctrl
    self.ctrl = Scene3DViewCtrl.Create(self,View,roomdata)
    return self.ctrl
end

-- 获取路单item信息
-- item_id 中奖动物id
-- color_id 中奖颜色id
-- type_id 庄闲和 id
-- sp_id 特殊中奖id（大三元，大四喜）
function Class:GetHistoryIconData(color_id, sanYuanColor_id, animal_id, enjoyType_id, ex_id, songDengColorID, songDengAnimalID)
    local ColorType = GameConfig.ColorType
    local ExWinType = GameConfig.ExWinType

    print("HistroyData: " ,color_id, animal_id, enjoyType_id)

    local colorSpr = self.roadColorSprites[color_id] --普通颜色1、2、3处理
    local sanYuanInfo = nil
    local siXiInfo = nil
    local songDengInfo = nil
    local shanDianRatio = nil
    if color_id == ColorType.SanYuan then   -- 大三元处理
        colorSpr = self.roadColorSprites[sanYuanColor_id]
        sanYuanInfo = {
            animalSpr_1 = self.roadAnimalSprites[1],
            animalSpr_2 = self.roadAnimalSprites[2],
            animalSpr_3 = self.roadAnimalSprites[3],
            animalSpr_4 = self.roadAnimalSprites[4],
        }
    elseif color_id == ColorType.SiXi then   -- 大四喜处理
        colorSpr = self.roadColorSprites[1] -- 给个默认
        siXiInfo = {
            colorSpr_1 = self.roadColorSprites[1],
            colorSpr_2 = self.roadColorSprites[2],
            colorSpr_3 = self.roadColorSprites[3],
            animalSpr = self.roadAnimalSprites[animal_id],
        }
    end
    -- 特殊大奖处理
    if ex_id == ExWinType.LiangBei then
        shanDianRatio = 2
    elseif ex_id == ExWinType.SanBei then
        shanDianRatio = 3
    elseif ex_id == ExWinType.SongDeng then
        songDengInfo = {
            songDengColorSpr = self.roadColorSprites[songDengColorID],
            songDengAnimalSpr = self. roadAnimalSprites[songDengAnimalID],
        }
    end

    return {
        -- color_id = color_id,
        -- ex_id = ex_id,
        colorSpr = colorSpr,
        animalSpr = self.roadAnimalSprites[animal_id],
        enjoyTypeSpr = self.roadEnjoyTypeSprites[enjoyType_id],
        --
        sanYuanInfo = sanYuanInfo,
        siXiInfo = siXiInfo,
        --
        shanDianRatio = shanDianRatio,
        songDengInfo = songDengInfo,
        

    }
end



return _ENV