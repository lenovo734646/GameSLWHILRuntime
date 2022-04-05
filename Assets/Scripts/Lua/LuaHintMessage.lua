
local GS = GS
local GF = GF

local Log = Log
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local yield = coroutine.yield
local SEnv=SEnv
_ENV = {}
---------------------
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
    local prefab = GS.UnityEngine.Resources.Load('popupTipsUI')
    local gameObject = GS.UnityEngine.Object.Instantiate(prefab,SEnv.UIParent)
    local initer = gameObject:GetComponent(typeof(GS.LuaInitHelper))
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
        yield(GS.UnityEngine.WaitForSeconds(3.8))
        if this.showingMsgT[msg] then
            GS.Destroy(gameObject)
        end
    end)
end


return _ENV
