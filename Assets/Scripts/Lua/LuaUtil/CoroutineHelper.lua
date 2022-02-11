local util = require 'xlua.util'

local cs_coroutine_runner = gLuaEntryCom

local typeCache = typeof(CS.SubGameCoStarter)
local IsUnityObjectValid = CS.UnityHelper.IsUnityObjectValid
-- print('cs_coroutine_runner:',cs_coroutine_runner)

return {
    StartCoroutine = function(...)
        if IsUnityObjectValid(cs_coroutine_runner) then
            return cs_coroutine_runner:StartCoroutine(util.cs_generator(...))
        else
            LogE('cs_coroutine_runner invalid ', cs_coroutine_runner)
        end
    end,
    StartCoroutineAuto = function(monoBehaviour, ...)
        if IsUnityObjectValid(monoBehaviour) then
            return monoBehaviour:StartCoroutine(util.cs_generator(...))
        else
            LogW('monoBehaviour was Destroyed! ', monoBehaviour)
        end
    end,
    StartCoroutineGo = function(gameObject, ...)
        if IsUnityObjectValid(gameObject) then
            local component = gameObject:GetOrAddComponent(typeCache)
            return component:StartCoroutine(util.cs_generator(...))
        else
            LogW('gameObject was Destroyed! ', gameObject)
        end

    end,
    IEnumerator = function(...)
        return util.cs_generator(...)
    end,
    StopCoroutine = function(coroutine,com)
        local runner = com or cs_coroutine_runner
        if IsUnityObjectValid(runner) then
            return runner:StopCoroutine(coroutine)
        end
    end,
    StopAllCoroutines = function()
        if IsUnityObjectValid(cs_coroutine_runner) then
            return cs_coroutine_runner:StopAllCoroutines()
        end
    end,
    StopAllCoroutinesAuto = function(monoBehaviour)
        if IsUnityObjectValid(monoBehaviour) then
            return monoBehaviour:StopAllCoroutines()
        end
    end,
}