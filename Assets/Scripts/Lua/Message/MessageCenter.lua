local GS = GS
local GF = GF
local pairs, LogW, tostring = pairs, LogW, tostring

local MessageCenter = class(nil, {
    autoReleaseEvents = {},
    dicMsgBind = {},
    dicMsgEvents = {}
})

function MessageCenter:__init()
    return self:RemoveAllListener()
end

function MessageCenter:RemoveAllListener()
    self.dicMsgEvents = {}
end

function MessageCenter:AddListener(msgType, func, target)
    if self.dicMsgBind[msgType] == nil then
        self.dicMsgBind[msgType] = {}
    end
    local bindFunc = GF.functional.bind1(func, target)
    table.insert(self.dicMsgBind[msgType], {
        bind = bindFunc,
        func = func,
        target = target
    })
    self:_addListener(msgType, bindFunc)
end
-- 自动移除调用的事件
function MessageCenter:AddListenerAutoRelease(msgType, func)
    local list = self.autoReleaseEvents[msgType]
    if not list then
        list = {}
        self.autoReleaseEvents[msgType] = list
    end
    table.insert(list, func)
end

function MessageCenter:_addListener(msgType, event)
    if self.dicMsgEvents[msgType] == nil then
        self.dicMsgEvents[msgType] = {}
    end
    if not GF.table.contains(self.dicMsgEvents[msgType], event) then
        -- print("成功添加这个监听")
        table.insert(self.dicMsgEvents[msgType], event)
    end
end

function MessageCenter:RemoveListener(msgType, func, target)
    local tbl = GF.table.findMap(self.dicMsgBind[msgType], function(b)
        return b.func == func and b.target == target
    end)
    for k, v in pairs(tbl) do
        self:_removeListener(msgType, v.bind)
        GF.table.removebyvalue(self.dicMsgBind[msgType], v)
    end
end

function MessageCenter:RemoveAllByType(msgType, target)
    local tbl = GF.table.findMap(self.dicMsgBind[msgType], function(b)
        return b.target == target
    end)
    for k, v in pairs(tbl) do
        self:_removeListener(msgType, v.bind)
        GF.table.removebyvalue(self.dicMsgBind[msgType], v)
    end
end

function MessageCenter:RemoveAllByTarget(target)
    local tbl = {}
    for k, v in pairs(self.dicMsgBind) do
        for k1, v1 in pairs(v) do
            if v1.target == target then
                table.insert(tbl, {
                    msgType = k,
                    value = v1
                })
            end
        end
    end
    for k, v in pairs(tbl) do
        self:_removeListener(v.msgType, v.value.bind)
        GF.table.removebyvalue(self.dicMsgBind[v.msgType], v.value)
    end
end

function MessageCenter:_removeListener(msgType, event)
    if self.dicMsgEvents[msgType] ~= nil then
        local index = GF.table.contains(self.dicMsgEvents[msgType], event)
        if index then
            -- print("成功移除这个监听")
            GF.table.removebyvalue(self.dicMsgEvents[msgType], event, true)
        end
    end
end

function MessageCenter:SendMessage(msgType, content)
    if self.dicMsgEvents[msgType] ~= nil then
        for k, v in pairs(self.dicMsgEvents[msgType]) do
            v(content)
        end
    end
    local list = self.autoReleaseEvents[msgType]
    if list then
        for i = 1, #list do
            list[i](content)
        end
        self.autoReleaseEvents[msgType] = nil
    end
end

return MessageCenter
