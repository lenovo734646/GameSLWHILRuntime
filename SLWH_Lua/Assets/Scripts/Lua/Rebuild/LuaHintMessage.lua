
local _G = _G
local g_Env = g_Env
local print, tostring, SysDefines, typeof, Destroy, LogE,string,assert,type =
      print, tostring, SysDefines, typeof, Destroy, LogE,string,assert,type



local Queue = require 'LuaUtil.Queue'

_ENV = moduledef { seenamespace = CS }
---------------------
local showHintMessage

function Create()
    local this = {
        hintMsgQueue = Queue.new(),
        isHintMsgShowing = false,
        lastHintTimestamp = 0,
    }
    this.CreateHintMessage = function (self, ...)
        CreateHintMessage(self,...)
    end
    this.CreateHintMessageByResponseProtocol = function (self, ...)
        CreateHintMessageByResponseProtocol(self,...)
    end
    return this
end

function CreateHintMessage(this, msg)
    print('CreateHintMessage',print(type(msg)),msg)
    local hintMsgQueue = this.hintMsgQueue
    if hintMsgQueue:contains(msg) then
        return
    end
    hintMsgQueue:pushback(msg)
    if ((TimeHelper.GetServerTimestamp() - this.lastHintTimestamp) >= 5000 and this.isHintMsgShowing) then
        this.isHintMsgShowing = false
    end
    if not this.isHintMsgShowing then
        showHintMessage(this)
    end
end

-- 根据协议对象以及内部的错误码显示提示文本(参数JBPROTO.INetProtocol rsp)
function CreateHintMessageByResponseProtocol(this, rsp)
    local hintMsg = '未知错误,错误代码:'..rsp.errcode
    if not string.IsNullOrEmpty(hintMsg) then
        CreateHintMessage(this, hintMsg)
    end
end

function showHintMessage(this)
    local hintMsgQueue = this.hintMsgQueue
    this.lastHintTimestamp = TimeHelper.GetServerTimestamp()
    local msg = hintMsgQueue:popfront()
    local prefab = g_Env.staticLoader:Load('Common/popupTipsUI.prefab')
    local obj = ObjectPoolManager.Instance:Spawn(prefab, g_Env.gamectrl.HintMessage)
    local com = obj:GetComponent(typeof(HintMessage))
    if not com then
        com = obj:AddComponent(typeof(HintMessage))
    end
    assert(com)
    print(type(msg))
    com:SetHintContent(msg, function()
        onHintMessageEnd(this)
    end )
    this.isHintMsgShowing = true;
end

function onHintMessageEnd(this)

    if (this.hintMsgQueue:count() > 0) then
        showHintMessage(this)
    else
        this.isHintMsgShowing = false
    end
end

return _ENV