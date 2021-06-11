
local _G = _G
local g_Env,class = g_Env,class
local print, tostring, SysDefines, typeof, debug, LogE,string, assert =
      print, tostring, SysDefines, typeof, debug, LogE,string, assert

local tinsert = table.insert

_ENV = moduledef { seenamespace = CS }

--需要UI已经设置了DOTween且配置了LuaUnityEventListener
function UIDoFadeAndClose(ui, uidestroyCallBack)
      if not ui then return end
      local tw = ui.go:GetComponent('DOTweenAnimation')
      tw:DOPlay()
      ui.uidestroyCallBack = uidestroyCallBack
end


return _ENV