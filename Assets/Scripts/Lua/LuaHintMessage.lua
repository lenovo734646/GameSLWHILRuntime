local _CreateHintMessage

local Class = class()

function Class.Create()
    local this = {
        showingMsgT = {}
    }
    this.CreateHintMessage = function(self, ...)
        return _CreateHintMessage(self, ...)
    end
    return this
end

function _CreateHintMessage(this, msg,parent)
    Log('_CreateHintMessage', msg, type(msg))
    if this.showingMsgT[msg] then
        return -- 同一个消息只显示一次
    end
    local prefab = GS.UnityEngine.Resources.Load('popupTipsUI')
    local uiParent = GS.GameObject.Find('HintMessage')
    local gameObject = GS.UnityEngine.Object.Instantiate(prefab, uiParent)
    
    local initer = gameObject:GetComponent(typeof(GS.LuaInitHelper))

    if parent then
        gameObject.transform:SetParent(parent, false)   
    end

    local t = {}
    initer:Init(t)
    t.tipsfont_text.text = msg
    t.popuptipsui_luaunityeventlistener:Init{
        OnDestroy = function()
            this.showingMsgT[msg] = nil
        end
    }
    this.showingMsgT[msg] = true
    GG.CoroutineHelper.StartCoroutine(function()
        GF.WaitForSeconds(3.8)
        if this.showingMsgT[msg] then
            GS.Destroy(gameObject)
        end
    end)
end


return Class
