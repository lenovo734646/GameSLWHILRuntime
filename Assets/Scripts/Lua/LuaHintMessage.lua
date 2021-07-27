local _G = _G
local table, print, tostring, Log, typeof, Destroy, LogE, string, assert, type, UnityEngine = table, print, tostring,
    Log, typeof, Destroy, LogE, string, assert, type, UnityEngine


local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local SEnv=SEnv
_ENV = moduledef {
    seenamespace = CS
}
---------------------
-- local showHintMessage

function Create()
    local this = {
        showingMsgT = {}
    }
    this.ShowHintMessage = function(self, ...)
        return ShowHintMessage(self, ...)
    end
    return this
end

function ShowHintMessage(this, msg)
    Log('ShowHintMessage', msg, print(type(msg)))
    if this.showingMsgT[msg] then
        return -- 同一个消息只显示一次
    end
    local prefab = UnityEngine.Resources.Load('popupTipsUI')
    local gameObject = UnityEngine.Object.Instantiate(prefab,SEnv.UIParent)
    local initer = gameObject:GetComponent(typeof(LuaInitHelper))
    local t = {}
    initer:Init(t)
    t.tipsfont_text.text = msg
    t.popuptipsui_luaunityeventlistener:Init{
        OnDestroy = function()
            this.showingMsgT[msg] = nil
        end
    }
    this.showingMsgT[msg] = true
    CoroutineHelper.StartCoroutine(function()
        yield(UnityEngine.WaitForSeconds(3.8))
        if this.showingMsgT[msg] then
            Destroy(gameObject)
        end
    end)
end


return _ENV
