local util = require 'xlua.util'

local cs_coroutine_runner = gLuaEntryCom

local typeCache = typeof(CS.SubGameCoStarter)
local IsUnityObjectValid = CS.UnityHelper.IsUnityObjectValid
-- print('cs_coroutine_runner:',cs_coroutine_runner)


local unpack = table.unpack

local move_end = {}

local generator_mt = {
    __index = {
        MoveNext = function(self)
            local Current
            Current = self.co()
            self.Current = Current
            if Current == move_end then
                self.Current = nil
                return false
            else
                return true
            end
        end;
        Reset = function(self)
            self.co = coroutine.wrap(self.w_func)
        end
    }
}

local function cs_generator(func, ...)
    local params = {...}
    local generator = setmetatable({
        w_func = function()
            if g_Env then   
                if g_Env.showDebugErr then  -- 大厅显示消息就捕获消息
                    local status, err = xpcall(function()
                        return func(unpack(params))
                    end,debug.traceback)
                    if not status then
                        g_Env.HandleError('捕获到协程错误:'..tostring(err), true)
                    end
                else    -- 大厅不显示消息就直接执行
                    func(unpack(params))
                end
            else    -- 不在大厅就直接捕获消息
                local status, err = xpcall(function()
                    return func(unpack(params))
                end,debug.traceback)
                if not status then
                    LogE('捕获到协程错误:'..tostring(err))
                end
            end
            return move_end
        end
    }, generator_mt)
    generator:Reset()
    return generator
end

return {
    StartCoroutine = function(...)
        if IsUnityObjectValid(cs_coroutine_runner) then
            return cs_coroutine_runner:StartCoroutine(cs_generator(...))
        else
            LogE('cs_coroutine_runner invalid ', cs_coroutine_runner)
        end
    end,
    StartCoroutineAuto = function(monoBehaviour, ...)
        if IsUnityObjectValid(monoBehaviour) then
            return monoBehaviour:StartCoroutine(cs_generator(...))
        else
            LogW('monoBehaviour was Destroyed! ', monoBehaviour)
        end
    end,
    StartCoroutineGo = function(gameObject, ...)
        if IsUnityObjectValid(gameObject) then
            local component = gameObject:GetOrAddComponent(typeCache)
            return component:StartCoroutine(cs_generator(...))
        else
            LogW('StartCoroutineGo gameObject was Destroyed! ', gameObject)
        end

    end,
    IEnumerator = function(...)
        return cs_generator(...)
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
    StopCoroutineGo = function (gameObject, coroutine)
        if IsUnityObjectValid(gameObject) then
            local component = gameObject:GetOrAddComponent(typeCache)
            if IsUnityObjectValid(component) then
                return component:StopCoroutine(coroutine)
            end
        else
            LogW('StopCoroutineGo gameObject was Destroyed! ', gameObject)
        end
    end
}
