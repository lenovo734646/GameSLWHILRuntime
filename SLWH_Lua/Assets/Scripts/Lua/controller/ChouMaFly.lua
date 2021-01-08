
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE,tonumber =
      print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,LogE,tonumber

local math,pairs = math,pairs

local DOTween = CS.DG.Tweening.DOTween
local table = table
local tinsert = table.insert
local tremove = table.remove

local CoroutineHelper = require'CoroutineHelper'
local WaitForSeconds = UnityEngine.WaitForSeconds
local yield = coroutine.yield

local GameConfig = require'GameConfig'
local Destroy = Destroy
local Instantiate = Instantiate
local GameObject = GameObject
local RandomInt = UnityHelper.RandomInt
local RandomFloat = UnityEngine.Random.Range
local Vector3 = CS.UnityEngine.Vector3
local Rigidbody = CS.UnityEngine.Rigidbody

local SubGame_Env=SubGame_Env
_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(choumaFlyRootTrans, betConfigArray)
    print("ChouMa Fly Init...")
    self.betConfigArray = betConfigArray
    self.chouMaFlyRoot = choumaFlyRootTrans
    local initHelper = self.chouMaFlyRoot:GetComponent(typeof(LuaInitHelper))
    local temp = {}
    initHelper:Init(temp)
    --
    self.otherChouMaRoot = temp.otherChouMaRoot
    self.selfChouMaRoot = temp.selfChouMaRoot
    self.flyOutPos = temp.flyOutPos.localPosition
    self.srcPosList = {}
    for i = 0, temp.srcPosList.childCount-1, 1 do
        tinsert(self.srcPosList, temp.srcPosList:GetChild(i))
    end
    self.dstPosList = {}
    for i = 0, temp.dstPosList.childCount-1, 1 do
        tinsert(self.dstPosList, temp.dstPosList:GetChild(i))
    end
    self.chouMaList = {}
    for i = 0, temp.chouMaList.childCount-1, 1 do
        tinsert(self.chouMaList, temp.chouMaList:GetChild(i).gameObject)
    end

    -- 开始减少Drag的时间点（0.5为整个路径的一半50%）
    self.fallLimit = 0.5
    -- Drag减少倍数（根据剩余路径百分比计算）
    self.mulitiple = 5
    -- 整个路径动画持续时间(太短体现不出自由落体的抛物线效果)
    self.duration = 0.5
    -- 动画时间浮动值
    self.durationOffset = 0

end

function Class:GetSrcPos()
    local index = RandomInt(0, #self.srcPosList)+1
    local tPos = self.srcPosList[index].localPosition
    local tOffset = self.srcPosList[index].localEulerAngles
    local offset = Vector3(RandomFloat(-tOffset.x, tOffset.x),0,RandomFloat(-tOffset.z, tOffset.z))
    return tPos + offset
end

function Class:GetDstPos(index)
    local tPos = self.dstPosList[index].localPosition
    local tOffset = self.dstPosList[index].localEulerAngles
    local offset = Vector3(RandomFloat(-tOffset.x, tOffset.x),0,RandomFloat(-tOffset.z, tOffset.z))
    return tPos + offset
end

function Class:GetRandomDuration(base, offest)
    return base + RandomFloat(-offest, offest)
end

-- 把押注分数转换为筹码数量
function Class:ConvertBetScoreToBetIndex(betScore, betScoreList)
    local betData = {}
    for i = #betScoreList, 1, -1 do
        --print("betScoreList[i] = ", betScoreList[i], i)
		if betScore >= betScoreList[i] then
			--local aa = betScore/betScoreList[i]
			local c = math.floor(betScore/betScoreList[i])
			betScore = betScore - c*betScoreList[i]
            --print("i = "..i.."  商"..c.."  剩余"..betScore)
            tinsert(betData, {betid = i-1, count = c})
		end
    end
    return betData
end

-- 场外飞向场内
-- targetIndex 为从1开始的下标：因为使用的是luatable下标从1开始，所以不需要转换
function Class:FlyIn(targetIndex, betScore, isSelf, betid)
    if targetIndex <= 0 or targetIndex > #self.dstPosList  then
        logError("targetIndex 越界或不合法"..targetIndex.."  最大值为："..#self.dstPosList)
        return
    end
    ---
    local parent = self.otherChouMaRoot
    if isSelf then
        parent = self.selfChouMaRoot
    end
    if betid == nil then
        --print("分数分解筹码....", betScore)
        local betData = self:ConvertBetScoreToBetIndex(betScore, self.betConfigArray)
        --print("分数分解完成....", #betData)
        for _, data in pairs(betData) do
            for i = 1, data.count, 1 do
                --print("data.betid = ",data.betid, self.chouMaList[data.betid+1], parent)
                local go = Instantiate(self.chouMaList[data.betid+1], parent)
                local srcPos = self:GetSrcPos()
                local dstPos = self:GetDstPos(targetIndex)
                local dur = self:GetRandomDuration(self.duration, self.durationOffset)
                self:__Fly(go, srcPos, dstPos, dur)
            end
        end
    else
        local go = Instantiate(self.chouMaList[betid+1], parent)
        local srcPos = self:GetSrcPos()
        local dstPos = self:GetDstPos(targetIndex)
        local dur = self:GetRandomDuration(self.duration, self.durationOffset)
        self:__Fly(go, srcPos, dstPos, dur)
    end
end

-- 场内飞向场外:
-- bOnlySelf：是否为玩家清楚下注
function Class:FlyOut(bOnlySelf)
    if bOnlySelf then
        self:__FlyOut(self.selfChouMaRoot)
    else
        self:__FlyOut(self.selfChouMaRoot)
        self:__FlyOut(self.otherChouMaRoot)
    end
end

function Class:Clear()
    for i = 0, self.selfChouMaRoot.childCount-1, 1 do
        local go = self.selfChouMaRoot:GetChild(i)
        Destroy(go)
    end

    for i = 0, self.otherChouMaRoot.childCount-1, 1 do
        local go = self.otherChouMaRoot:GetChild(i)
        Destroy(go)
    end
end

function Class:__FlyOut(choumaRoot)
    --print("FlyOut ",choumaRoot, self.selfChouMaRoot,self.otherChouMaRoot)
    for i = 0, choumaRoot.childCount-1, 1 do
        local go = choumaRoot:GetChild(i)
        assert(go)
        local srcPos = go.localPosition
        local dstPos = self.flyOutPos
        local dur = self:GetRandomDuration(self.duration, self.durationOffset)
        self:__Fly(go.gameObject, srcPos, dstPos, dur, true)
        CoroutineHelper.StartCoroutine(function ()
            yield(WaitForSeconds(dur))
            Destroy(go.gameObject)
        end)
    end
end


function Class:__Fly(go, srcPos, dstPos, duration, bOut)
    --go:SetActive(false)
    go.transform.localPosition = srcPos
    local drag = 50
    go.transform:GetComponent(typeof(Rigidbody)).drag = drag;
    go:SetActive(true);
    --
    go.transform:DOLocalMoveX(dstPos.x, duration):SetEase(DG.Tweening.Ease.InOutCirc)
    go.transform:DOLocalMoveZ(dstPos.z, duration):SetEase(DG.Tweening.Ease.InOutCirc)

    if not bOut then
        CoroutineHelper.StartCoroutine(function ()
            while true do
                local disPer = Vector3.Distance(go.transform.localPosition, dstPos) / Vector3.Distance(srcPos, dstPos)
                local rigid = go:GetComponent(typeof(Rigidbody))
                if disPer < self.fallLimit then
                    rigid.drag = drag*disPer/self.mulitiple
                    --print("Fly: ", rigid.drag, disPer, self.mulitiple)
                    if rigid.drag < 10 then
                        rigid.drag = 0
                        break
                    end
                end
                yield()
            end
        end)
    end
end









return _ENV