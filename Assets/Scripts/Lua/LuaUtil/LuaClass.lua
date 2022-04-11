local LuaClass = class(nil,{
	transform = nil,
	gameObject = nil
	})

function LuaClass:New(go)
	local obj = {}
	setmetatable(obj,self)
	if obj.__init then
		obj:__init(go)
	end
	return obj
end

function LuaClass:__init(go)
	self.gameObject = go
	self.transform = go.transform
end

return LuaClass