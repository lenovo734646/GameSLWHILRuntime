local util = require 'xlua.util'

local cs_coroutine_runner = gLuaEntryCom

return {
    StartCoroutine = function(...)
	    return cs_coroutine_runner:StartCoroutine(util.cs_generator(...))
	end;

	StopCoroutine = function(coroutine)
	    cs_coroutine_runner:StopCoroutine(coroutine)
	end
}, cs_coroutine_runner