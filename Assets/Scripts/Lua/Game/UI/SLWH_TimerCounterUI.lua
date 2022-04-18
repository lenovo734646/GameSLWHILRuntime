
-- 倒计时
local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(initHelper)
    self.gameObject = initHelper.gameObject
    self.gameObject:SetActive(true)
    initHelper:Init(self)
    self.time = 0
    self.timerID = nil
end

function Class:StartCountDown(time, state, playSoundFunc)
    if SEnv.CountDownTimerManager.HasTimer(self.timerID) then
        SEnv.CountDownTimerManager.StopTimer(self.timerID)
    end
    self.timerID = nil -- 旧的定时器清理
    self.time = time
    -- 游戏状态图片显示
    for i=1,3 do
        if i==state then
            self['gamestate_'..i..'_image'].gameObject:SetActive(true)
        else
            self['gamestate_'..i..'_image'].gameObject:SetActive(false)
        end
    end
    --
    local timeText = self.timeText
    timeText.text = tostring(math.floor(time+0.5))

    --
    local function doOneSecond(leftTime, bFinish)
        -- print("leftTime real = "..leftTime)
        self.time = leftTime
        leftTime = math.floor(leftTime+0.5)
        if playSoundFunc ~= nil then
            playSoundFunc(leftTime)
        end
        
        if leftTime < 1 then
            return true
        end
        timeText.text = tostring(leftTime)
    end

    self.timerID = SEnv.CountDownTimerManager.StartCountDown(time, doOneSecond)
end

return Class