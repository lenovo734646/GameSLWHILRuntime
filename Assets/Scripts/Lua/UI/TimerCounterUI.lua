
local _G = _G
local class = class
local print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,tonumber =
      print, tostring, SysDefines, typeof, debug,string, assert,ipairs,json,tonumber

local CoroutineHelper = require'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local floor = math.floor

_ENV = moduledef { seenamespace = CS }

local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init(initHelper)
    self.gameObject = initHelper.gameObject
    self.gameObject:SetActive(true)
    initHelper:Init(self)
end

function Class:StartCountDown(time, state, playSoundFunc)
    if self.co then
        CoroutineHelper.StopCoroutine(self.co)
    end
    for i=1,3 do
        if i==state then
            self['gamestate_'..i..'_image'].gameObject:SetActive(true)
        else
            self['gamestate_'..i..'_image'].gameObject:SetActive(false)
        end
    end
    local timeText = self.timeText
    timeText.text = tostring(floor(time+0.5))
    --
    local function doOneSecond(leftTime)
        -- print("leftTime real = "..leftTime)
        leftTime = floor(leftTime+0.5)
        if playSoundFunc ~= nil then
            playSoundFunc(leftTime)
        end
        
        if leftTime < 1 then
            return true
        end
        timeText.text = tostring(leftTime)
    end

    self.co = CoroutineHelper.StartCoroutine(function ()
        local timerCounter = time - floor(time)
        while true do
            yield()
            local dt = Time.deltaTime
            time = time - dt
            timerCounter = timerCounter - dt
            if timerCounter <= 0 then
                timerCounter = timerCounter + 1
                if doOneSecond(time) then
                    break
                end
            end
        end
        self.co = nil
    end)
end

return _ENV