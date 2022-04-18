function moduledef(paramT)
    local t = paramT.t
    local name = paramT.name
    local seeall = paramT.seeall
    local seenamespace = paramT.seenamespace
    local _t = t or {}
    if name then
        _G[name] = _t
    end
    if seeall then
        setmetatable(_t, {__index = _G}) 
    end
    if seenamespace then
        setmetatable(_t, {__index = seenamespace}) 
    end
    return _t
end

local function default_ctor(self, ...)
    local obj = {}
    setmetatable(obj, self)
    if obj.__init then
        obj:__init(...)
    end
    return obj
end

function class(super, cls)
    if not cls then
        cls = {}
    end
    local mt = {}
    if super then
        setmetatable(mt, super)
        cls.super = super
    end
    mt.__index = mt
    mt.__call = function(self, ...)
        if self.New then
            return self:New(...)
        else
            return default_ctor(self, ...)
        end
    end
    setmetatable(cls, mt)
    cls.__index = cls
    return cls
end