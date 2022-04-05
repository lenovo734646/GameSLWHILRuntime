
local GS = GS
local GF = GF
local _G = _G
local g_Env, class = g_Env, class
local pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert
    = pairs, json, table, math, print, tostring, typeof, debug, LogE, string, assert

local Log, LogW, LogE = Log, LogW, LogE
local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local WaitForSeconds = GS.WaitForSeconds
local floor = math.floor

--
local table = table
local os = os
local tinsert = table.insert
local tremove = table.remove

-- 定时器管理
-- 每次开始倒计时会重新启动一个定时器
-- 定时器不用需要及时关闭，避免多个定时器调用同一个回调，导致每个tick回调多次执行（比如断线重连定时器需要关闭清理，避免重连成功新建定时器和老的定时器同时执行一个回调）

_ENV = {}

local timerList = {}
local count = 0

-- 停止倒计时
function StopTimer(id, iscallAction)
    -- print("停止倒计时 id = ", id)
    local timer = GetTimer(id)
    if not timer then
        LogW("StopTimer 未找到对应的定时器 id 错误或定时器已停止")
        return 
    end
    --
    local co = timer.co
    if co then
        CoroutineHelper.StopCoroutine(co)
        co = nil
    end
    if iscallAction and timer.actionPerInterval then
        timer.actionPerInterval(timer.leftTime, true)
    end
    GF.table.removebyvalue(timerList, timer, true)
    -- print("停止倒计时成功 #timerList = ", #timerList)
end

-- 开始倒计时，返回倒计时ID和协程
function StartCountDown(time, actionPerInterval, interval)
    local interval = interval or 1
    -- print("倒计时开始:", time)
    local cdStartTimestamp = os.time()
    local leftTime = floor(time+0.5) -- 
    --
    count = count +1
    if count >= 10000 then
        count = 1
    end
    local timerdata = {id = count, duration = time, leftTime = time, isFinish = false, co = nil, actionPerInterval = actionPerInterval}
    if actionPerInterval then
        actionPerInterval(leftTime, false) -- 起始时就调用一次以便刷新界面
    end
    timerdata.co = CoroutineHelper.StartCoroutine(function ()
        while leftTime > 0 do
            yield(WaitForSeconds(interval))
            local nowTimestamp = os.time()
            leftTime = time - (nowTimestamp - cdStartTimestamp)
            if leftTime <= 0 then
                leftTime = 0
                break
            end
            timerdata.leftTime = leftTime
            if actionPerInterval then
                actionPerInterval(leftTime)
            end
        end
        timerdata.leftTime = 0
        timerdata.isFinish = true
        if actionPerInterval then
            actionPerInterval(0, true)
        end
        StopTimer(timerdata.id)
    end)

    tinsert(timerList, timerdata)
    -- print("开始倒计时成功 #timerList = ", #timerList)
    return count
end



function GetTimer(id)
    local timer = GF.table.FindBy(timerList, function (v)
        return v.id == id
    end)
    return timer
end

function HasTimer(id)
    local timer = GetTimer(id)
    return timer ~= nil
end

function Clear()
    -- print("清理倒计时 #timerList", #timerList)
    for key, timer in pairs(timerList) do
        -- print("ClearTimer timer.id = ", timer.id, "timer.isFinish:", timer.isFinish, "timer.co:", timer.co)
        local co = timer.co
        if co then
            CoroutineHelper.StopCoroutine(co)
            co = nil
        end
    end
    timerList = {}
end

return _ENV