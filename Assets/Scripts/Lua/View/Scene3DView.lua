
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert,pairs

local tinsert = table.insert
local tonumber = tonumber

local GameObject = GameObject
local DOTween = CS.DG.Tweening.DOTween
local Scene3DViewCtrl = require'controller.Scene3DViewCtrl'
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local GameConfig = require'GameConfig'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'

local OSACore = CS.Com.TheFallenGames.OSA.Core
local ItemCountChangeMode = OSACore.ItemCountChangeMode

local MainUI =  require'UI.MainUI'
local SimpleSlot = require'controller.SimpleSlot'
local SEnv = SEnv


_ENV = moduledef { seenamespace = CS }

local RUN_ITEM_COUNT = GameConfig.RunItemCount
local ColorType = GameConfig.ColorType
local ExWinType = GameConfig.ExWinType

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
    -- 进入即播放背景音乐，因为是否静音使用音量调节，所以这里一直播放就行了
    AudioManager.Instance:PlayMusic("BGMusic")
    -- EnjoyGame 小老虎机
    self.slot = SimpleSlot.Create(self.slotPanelInitHelper)

    -- UI
    self.mainUI = MainUI.Create(roomdata)
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
            item_id = indexToFindMap[i].item_id, 
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
        --print("下注区域helper = ", i, helper)
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
        itemViewGameObject:GetComponent(typeof(LuaInitHelper)):Init(viewItemData, false)
        viewItemData.gameObject = itemViewGameObject
        return viewItemData
    end
    --数据更新接口实现（itemViewGameObject会自动回收使用，所以需要对itemViewGameObject进行更新）
    roadScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        local SetAnimalImg = function (animalImg, spr)
            animalImg.sprite = spr
            animalImg:SetNativeSize()
        end
        for i = 1, 3 do
            local active = i==itemdata.enjoyType_id
            viewItemData['enjoyTypeImg'..i].gameObject:SetActive(active)
        end
        -- 每次刷新先重置一下，因为viewItem会复用
        viewItemData.sanYuanInitHelper.gameObject:SetActive(false)
        viewItemData.siXiInitHelper.gameObject:SetActive(false)

        viewItemData.shanDianInitHelper.gameObject:SetActive(false)
        viewItemData.songDengInitHelper.gameObject:SetActive(false)
        viewItemData.caiJinInitHelper.gameObject:SetActive(false)
        --
        if itemdata.siXiInfo ~= nil then
            local sxData = {}
            viewItemData.siXiInitHelper:Init(sxData, false)
            sxData.item_1.sprite = itemdata.colorSpr
            sxData.item_2.sprite = itemdata.colorSpr
            sxData.item_3.sprite = itemdata.colorSpr
            sxData.item_4.sprite = itemdata.colorSpr
            sxData.animal_1.sprite = itemdata.siXiInfo.animalSpr_1
            sxData.animal_2.sprite = itemdata.siXiInfo.animalSpr_2
            sxData.animal_3.sprite = itemdata.siXiInfo.animalSpr_3
            sxData.animal_4.sprite = itemdata.siXiInfo.animalSpr_4
            sxData.SiXiRoot:SetActive(true)
        elseif itemdata.sanYuanInfo ~= nil then
            local syData = {}
            viewItemData.sanYuanInitHelper:Init(syData, false)
            syData.item_1.sprite = itemdata.sanYuanInfo.colorSpr_1
            syData.item_2.sprite = itemdata.sanYuanInfo.colorSpr_2
            syData.item_3.sprite = itemdata.sanYuanInfo.colorSpr_3
            syData.animal_1.sprite = itemdata.sanYuanInfo.animalSpr
            syData.animal_2.sprite = itemdata.sanYuanInfo.animalSpr
            syData.animal_3.sprite = itemdata.sanYuanInfo.animalSpr
            syData.SanYuanRoot:SetActive(true)
        else
            viewItemData.colorImg.sprite = itemdata.colorSpr
            SetAnimalImg(viewItemData.animalImg, itemdata.animalSpr)
            viewItemData.animalImg.gameObject:SetActive(true)
        end
        -- 特殊大奖
        if itemdata.shanDianRatio ~= nil then
            local sdData = {}
            viewItemData.shanDianInitHelper:Init(sdData, false)
            sdData.ratio.text = tostring(itemdata.shanDianRatio)
            sdData.ShanDianRoot:SetActive(true)
        elseif itemdata.songDengInfo ~= nil then
            local songDengData = {}
            --print("送灯 color = ", itemdata.songDengInfo.songDengColorSpr, "  animal = ", itemdata.songDengInfo.songDengAnimalSpr)
            viewItemData.songDengInitHelper:Init(songDengData, false)
            songDengData.colorImg.sprite = itemdata.songDengInfo.songDengColorSpr
            songDengData.animalImg.sprite = itemdata.songDengInfo.songDengAnimalSpr
            songDengData.SongDengRoot:SetActive(true)
        elseif itemdata.caijinRatio ~= nil then
            local caijinData = {}
            viewItemData.caiJinInitHelper:Init(caijinData, false)
            caijinData.ratio.text = "x"..tostring(itemdata.caijinRatio)
            caijinData.CaiJinRoot:SetActive(true)
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

    -- 找一个不会被Inactive 的脚本用来运行协程
    SEnv.CoroutineMonoBehaviour = self.viewEventBroadcaster

    -- ctrl
    self.ctrl = Scene3DViewCtrl.Create(self,View,roomdata)
    return self.ctrl
end

-- 获取路单item信息
-- item_id 中奖动物id
-- color_id 中奖颜色id
-- type_id 庄和闲 id
-- sp_id 特殊中奖id（大三元，大四喜）
function Class:GetHistoryIconData(info)
    local color_id = info.ressult_info.winColor
    local siXIColor_id = info.ressult_info.winSiXiColor
    local animal_id = info.ressult_info.winAnimal
    local ex_id = info.win_exType
    local enjoyType_id = info.win_enjoyGameType
    local caijinRotio_ = info.caijin_ratio
    --print("获取历史数据：color_id = ", color_id, "  siXIColor_id = ", siXIColor_id, "  animal_id = ", animal_id, 
    --    "  ex_id = ", ex_id, "  enjoyType_id = ", enjoyType_id, "  caijinRotio_ = ", caijinRotio_)
    --
    local colorSpr = self.roadColorSprites[color_id] --普通颜色1、2、3处理
    local sanYuanInfo = nil
    local siXiInfo = nil
    local songDengInfo = nil
    local shanDianRatio = nil
    local caijinRatio = nil
    if color_id == ColorType.SiXi then   -- 大四喜处理
        colorSpr = self.roadColorSprites[siXIColor_id]
        siXiInfo = {
            animalSpr_1 = self.roadAnimalSprites[1],
            animalSpr_2 = self.roadAnimalSprites[2],
            animalSpr_3 = self.roadAnimalSprites[3],
            animalSpr_4 = self.roadAnimalSprites[4],
        }
    elseif color_id == ColorType.SanYuan then   -- 大三元处理
        colorSpr = self.roadColorSprites[1] -- 给个默认
        sanYuanInfo = {
            colorSpr_1 = self.roadColorSprites[1],
            colorSpr_2 = self.roadColorSprites[2],
            colorSpr_3 = self.roadColorSprites[3],
            animalSpr = self.roadAnimalSprites[animal_id],
        }
    end
    -- 特殊大奖处理
    if ex_id == ExWinType.CaiJin then
        caijinRatio = caijinRotio_
    elseif ex_id == ExWinType.LiangBei then
        shanDianRatio = 2
    elseif ex_id == ExWinType.SanBei then
        shanDianRatio = 3
    elseif ex_id == ExWinType.SongDeng and info.ressult_info_songdeng ~= nil then
        local songDengColorID = info.ressult_info_songdeng.winColor
        local songDengAnimalID =  info.ressult_info_songdeng.winAnimal
        --print("获取历史数据 songDengColorID = ", songDengColorID, "  songDengAnimalID = ", songDengAnimalID)
        songDengInfo = {
            songDengColorSpr = self.roadColorSprites[songDengColorID],
            songDengAnimalSpr = self.roadAnimalSprites[songDengAnimalID],
        }
    end

    return {
        -- color_id = color_id,
        -- ex_id = ex_id,
        colorSpr = colorSpr,
        animalSpr = self.roadAnimalSprites[animal_id],
        -- enjoyTypeSpr = self.roadEnjoyTypeSprites[enjoyType_id],
        enjoyType_id = enjoyType_id,
        --
        sanYuanInfo = sanYuanInfo,
        siXiInfo = siXiInfo,
        --
        shanDianRatio = shanDianRatio,
        songDengInfo = songDengInfo,
        --
        caijinRatio = caijinRatio,

    }
end

function Class:Release()
    print("Scene3DView Release")
    CoroutineHelper.StopAllCoroutines()
    self.roadScrollView.OnCreateViewItemData = nil
    self.roadScrollView.UpdateViewItemHandler = nil
    self.roadScrollView:Release()
    self.roadScrollView = nil

    self.mainUI:Release()
end



return _ENV