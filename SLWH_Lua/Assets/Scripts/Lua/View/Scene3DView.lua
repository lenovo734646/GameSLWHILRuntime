
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

local yield = coroutine.yield

local Scene3DViewCtrl = require'controller.Scene3DViewCtrl'
local InfinityScroView = require'OSAScrollView.InfinityScroView'
local GameConfig = require'GameConfig'

local OSACore = CS.Com.TheFallenGames.OSA.Core
local ItemCountChangeMode = OSACore.ItemCountChangeMode

local ResultPanel = require'UI.ResultPanel'
local TopUI =  require'UI.TopUI'
local Banker = require'UI.Banker'

_ENV = moduledef { seenamespace = CS }

local RUN_ITEM_COUNT = GameConfig.RunItemCount

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(roomdata)

    local View = GameObject.Find('View')
    self.gameObject = View
    View:GetComponent(typeof(LuaInitHelper)):Init(self)
    
    -- 结算界面
    self.resultPanel = ResultPanel.Create(self.resultPanelGameObject)
    -- 顶部UI
    self.topUI = TopUI.Create(self.topUIInitHelper)
    -- 上庄
    self.banker = Banker.Create(self.bankerInfoInitHelper)
    --
    self.iconRigibody = self.iconPos:GetComponent('Rigidbody')
    local runItemIndexs = self.runItemIndexs
    local winStage = self.winStage
    local winStageChildren = {}
    winStage:GetComponent(typeof(LuaInitHelper)):Init(winStageChildren)
    local winStageDataList = {}
    local indexToFindMap = {}   -- 下标对应的winStageData
    for name,child in pairs(winStageChildren) do
        local arr = string.split(name,',')
        local gameObject = child.gameObject
        local childdata = {
            transform = child,
            gameObject = gameObject,
            item_id = tonumber(gameObject.name),
            --animationHelper = child:GetComponent(typeof(AnimationHelper)), -- BCBM效果是粒子
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

    local runItemDataList = {}
    for i=1,RUN_ITEM_COUNT do
        local t = runItemIndexs:GetChild(i-1)
        --local animationHelper = t:GetComponent(typeof(AnimationHelper)) --BCBM车标没有动画
        local select = t:Find('select')
        -- local winEffect = select:GetChild(0).gameObject -- BCBM中奖特效单独处理，没有放到每个item下面
        -- winEffect:SetActive(false)
        local selectps = select:GetChild(0):GetComponent('ParticleSystem')
        local data = {
            transform = t,
            --animationHelper = animationHelper,
            winShowData = indexToFindMap[i],
            position = t.position,
            select = select,
            selectps = selectps,
            --winEffect = winEffect,
            index = i,
            -- ActiveWinEffect = function (b)   -- 中奖动画外部管理
            --     --winEffect:SetActive(b)
            --     self.winParticleTransform.gameObject:SetActive(b)
            -- end,
            Play = function ()
                selectps:Play()
                self.ctrl.soundMgr:PlaySound("run")
            end,
            OnTriggerEnter = function (self)
                local uictrl = self.uictrl
                if uictrl then
                    uictrl:OnAnimalTrigger(i)
                end
            end,
        }
        t:GetComponent(typeof(LuaUnityEventListener)):Init(data)
        tinsert(runItemDataList, data)
    end
    self.runItemDataList = runItemDataList

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

    local roadScrollView = InfinityScroView.Create(self.OSAScrollViewCom)
    self.roadScrollView = roadScrollView
    --数据提供接口实现
    roadScrollView.OnCreateViewItemData = function (itemViewGameObject,itemIndex)
        local viewItemData = {
            msgImg = itemViewGameObject:GetComponent("Image") ,
            gameObject = itemViewGameObject,
        }
        return viewItemData
    end
    --数据更新接口实现（itemViewGameObject会自动回收使用，所以需要对itemViewGameObject进行更新）
    roadScrollView.UpdateViewItemHandler = function (itemdata,index,viewItemData)
        viewItemData.msgImg.sprite = itemdata.sprite
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

    self.histroyIconSprites = {}
    self.RoadInitHelper:ObjectsSetToLuaTable(self.histroyIconSprites)
    self.RoadInitHelper = nil
    self.betSelectToggles = {}
    self.BetSelectBtnsInitHelper:ObjectsSetToLuaTable(self.betSelectToggles)
    self.BetSelectBtnsInitHelper = nil



    self.ctrl = Scene3DViewCtrl.Create(self,View,roomdata)
    return self.ctrl
end

function Class:GetHistoryIconData(item_id)
    return {sprite = self.histroyIconSprites[item_id]}
end



return _ENV