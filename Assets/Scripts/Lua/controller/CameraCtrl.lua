local _G, g_Env = _G, g_Env
local class = class
local print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs =
      print, tostring, _STR_, typeof, debug, LogE, LogW,string, assert,pairs

local GameObject = GameObject
local DOTweenAnimation = CS.DG.Tweening.DOTweenAnimation
-- local DOTween_AnimationType = DOTweenAnimation.AnimationType

local SEnv = SEnv
_ENV = moduledef { seenamespace = CS }

-- 控制摄像机DOTween 动画
local Class = class()

function Create(...)
    return Class(...)
end

function Class:__init()
    local CameraRoot = GameObject.Find('CameraRoot')
    self.root = CameraRoot
    CameraRoot:GetComponent(typeof(LuaInitHelper)):Init(self)
    -- self.eventListener:Init(self)
	local coms = self.MainCamera:GetComponents(typeof(DOTweenAnimation))
	print("coms = ", coms.Length)
	for i = 0, coms.Length-1, 1 do
		print(coms[i])
		-- if anim.animationType == DOTween_AnimationType.LocalMove then
		-- 	self.localMoveDOTweenAnim = anim
		-- elseif anim.animationType == DOTween_AnimationType.LocalRotate then
		-- 	self.localRotateDOTweenAnim = anim
		-- end
	end
	self.localRotateDOTweenAnim = coms[0]
	self.localMoveDOTweenAnim = coms[1]
	assert(self.localRotateDOTweenAnim)
	assert(self.localMoveDOTweenAnim)
end

local ApplyDOTweenAnimChange = function (doTweenAnim)
	doTweenAnim.tween:Kill();
	doTweenAnim:CreateTween();
	return doTweenAnim;
end

function Class:MoveToPoint(point)
	self.localRotateDOTweenAnim.endValueV3 = point.localEulerAngles
	self.localMoveDOTweenAnim.endValueV3 = point.localPosition
	ApplyDOTweenAnimChange(self.localRotateDOTweenAnim)
	ApplyDOTweenAnimChange(self.localMoveDOTweenAnim)
	self.localRotateDOTweenAnim:DOPlayForward()
	self.localMoveDOTweenAnim:DOPlayForward()
end

function Class:ToNormalPoint()
	print("ToNormalPoint...")
	self:MoveToPoint(self.normalPoint)
end

function Class:ToRotatePoint()
	print("ToRotatePoint...")
	self:MoveToPoint(self.rotatePoint)
end

function Class:ToShowPoint()
	print("ToShowPoint...")
	self:MoveToPoint(self.showPoint)
end

return _ENV