
local _G, g_Env, print, log, logError = _G, g_Env, print, log, logError
local class, typeof, type, string, utf8= class, typeof, type, string, utf8

local UnityEngine, GameObject, Sprite = UnityEngine, GameObject, Sprite

local OSA = CS.OSAHelper
local OSACore = CS.Com.TheFallenGames.OSA.Core
local OSAScrollView = OSA.OSAScrollView
local MyParam = OSA.MyParam
local MyItemViewHolder = OSA.MyItemViewHolder
local ItemCountChangeMode = OSACore.ItemCountChangeMode



_ENV = {}

local Class = class()

function Create(...)
    return Class(...)
end 


function Class:__init(OSAScrollViewCom)
    -- 
    self.OSAScrollViewCom = OSAScrollViewCom
    -- if not self.OSAScrollViewCom.IsInitialized and self.OSAScrollViewCom.gameObject.activeSelf == true then
    --     self.OSAScrollViewCom:Init()
    -- end
    -- self.OSAScrollViewCom.exView = self
    --
    OSAScrollViewCom.StartCallback = function (paramters_)
        self:Init(paramters_)
    end
    OSAScrollViewCom.UpdateCallback = function (paramters_)
        self:UpdateView(paramters_)
    end
    
    self.OSAScrollViewCom.OnBeforeRecycleOrDisableViewsHolderCallback = function (paramters_)
        self:OnBeforeRecycleOrDisableViewsHolder(paramters_)
    end
    self.OSAScrollViewCom.RebuildLayoutDueToScrollViewSizeChangeCallback = function (paramters_)
        self:RebuildLayoutDueToScrollViewSizeChange(paramters_)
    end
    self.OSAScrollViewCom.ChangeItemsCountCallback = function (paramters_)
        self:ChangeItemsCount(paramters_)
    end
    
    self.OSAScrollViewCom.DisposeCallback = function (paramters_)
        self:Dispose(paramters_)
    end
    self.OSAScrollViewCom.OnItemHeightChangedPreTwinPassCallback = function (paramters_)
        self:OnItemHeightChangedPreTwinPass(paramters_)
    end
    self.OSAScrollViewCom.OnItemWidthChangedPreTwinPassCallback = function (paramters_)
        self:OnItemWidthChangedPreTwinPass(paramters_)
    end

end

-- 回调
function Class:Init(osaView_)
    if not self.OSAScrollViewCom.IsInitialized then
        self.OSAScrollViewCom:Init()
    end
end

function Class:UpdateView(osaView_)
    local osaView = osaView_
end

--


function Class:OnItemHeightChangedPreTwinPass(paramters_)
    -- local osaView = paramters_[0]
    -- local itemIndex = paramters_[1]
end

function Class:OnItemWidthChangedPreTwinPass(paramters_)
    --local osaView = paramters_[0]
end

function Class:OnBeforeRecycleOrDisableViewsHolder(paramters_)
    -- local osaView = paramters_[0]
    -- local vh = paramters_[1]
    -- local newIndex = paramters_[2]
    -- vh.bindData:DeactivePopupAnimation()
end

-- 检测到滚动视图大小更改时调用，标记内容进行布局重建，然后调用Canvas.ForceUpdateCanvases
-- 注意：如果ItemViewHolder上存在LayoutGroup 并且调用了LayoutRebuilder.MarkForRebuild()，必须重写"AbstractViewsHolder.MarkForRebuild"方法
-- 调用之后将会调用Refresh(bool, bool)
function Class:RebuildLayoutDueToScrollViewSizeChange(paramters_)
    -- local osaView = paramters_[0]
    -- self:SetAllModelsHavePendingSizeChange()
end

-- 每次数量更改都会调用，
function Class:ChangeItemsCount(paramters_)
    -- local osaView = paramters_[0]
    local changeMode = paramters_[1] -- 更改方式
    local itemsCount = paramters_[2] -- 更改数量
    -- if changeMode == ItemCountChangeMode.RESET then
    --     self:SetAllModelsHavePendingSizeChange()
    -- end
    -- log(changeMode)
    if self.ChangeItemsCountCallback then
        self:ChangeItemsCountCallback(changeMode, itemsCount)
    end

end

-- 插入或移出时调用，仅当数据依赖itemIndex而不是依赖model时才需要此方法
function Class:OnItemIndexChangedDueInsertOrRemove(paramters_)
    local osaView = paramters_[0]
    local changeMode = paramters_[1]
end

-- OnDestroy 中自动调用
function Class:Dispose(osaView_)
    --local osaView = osaView_
end

-- 自定义非回调函数
function Class:GetItemsCount()
    return self.OSAScrollViewCom:GetItemsCount()
end

function Class:GetItemViewsHolder(index)
    --print("GetItemViewsHolder index = ", index)
    return self.OSAScrollViewCom:GetItemViewsHolder(index).bindData -- 
end

function Class:SmoothScrollTo(itemIndex, duration, normalizedOffsetFromViewportStart, 
    normalizedPositionOfItemPivotToUse, onProgressFunc, onDoneFunc, overrideCurrentScrollingAnimation)
    --
    normalizedOffsetFromViewportStart = normalizedOffsetFromViewportStart or 0.1
    normalizedPositionOfItemPivotToUse = normalizedPositionOfItemPivotToUse or 0.1
    overrideCurrentScrollingAnimation = overrideCurrentScrollingAnimation or false
    --
    self.OSAScrollViewCom:SmoothScrollTo(itemIndex, duration, normalizedOffsetFromViewportStart, 
    normalizedPositionOfItemPivotToUse, onProgressFunc, onDoneFunc, overrideCurrentScrollingAnimation)
end




return _ENV