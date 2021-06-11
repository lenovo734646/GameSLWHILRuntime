local util = require 'xlua.util'



local cs_coroutine_runner = gLuaEntryCom
local typeCache = typeof(CS.SubGameCoStarter)


return {
    StartCoroutine = function(...)
	    return cs_coroutine_runner:StartCoroutine(util.cs_generator(...))
	end;

	StartCoroutineAuto = function (component, ...)
		return component:StartCoroutine(util.cs_generator(...))
	end,
	StartCoroutineGo = function(gameObject,...)
		local component = gameObject:GetOrAddComponent(typeCache)
		return component:StartCoroutine(util.cs_generator(...))
	end;
	StopCoroutine = function(coroutine)
	    cs_coroutine_runner:StopCoroutine(coroutine)
	end,

}, cs_coroutine_runner