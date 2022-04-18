local GS = GS
local GF = GF
local Pool = require 'Pool.Pool'
local typeof,print = typeof,print
local AssertUnityObjValid=AssertUnityObjValid

local PoolManager = class(nil, {
    tPool = nil,
    parent = nil
})

function PoolManager:__init(poolNode)
    self.tPool = {}
    self.parent = poolNode or GS.GameObject("PoolNode")
    self.parent:AddComponent(typeof(GS.LuaUnityEventListener)):Init(self)
    GS.UnityEngine.Object.DontDestroyOnLoad(self.parent.gameObject)
end

function PoolManager:Spawn(param)
    local prefab = param.prefab
    local pos = param.position or GS.UnityEngine.Vector3.zero
    local rot = param.rotation or GS.UnityEngine.Quaternion.identity
    local parent = param.parent or self.parent.transform

    local script = param.script

    local pool
    for k, v in pairs(self.tPool) do
        if v.prefab == prefab then
            pool = v
        end
    end
    if pool == nil then
        pool = Pool(prefab)
        table.insert(self.tPool, pool)
    end
    return pool:Spawn(pos, rot, parent, script)
end

function PoolManager:Unspawn(obj)
    for k, v in pairs(self.tPool) do
        if v:Unspawn(obj) then
            return
        end
    end
    GF.SafeDestroy(obj.gameObject)
end

function PoolManager:ClearAll()
    for k, v in pairs(self.tPool) do
        v:Clear()
    end
end

function PoolManager:OnDestroy()
    for k, v in pairs(self.tPool) do
        v:Clear()
    end
    AssertUnityObjValid(self.parent.gameObject)
    if self.parent.gameObject.name == "PoolNode" then
        GS.Destroy(self.parent.gameObject)
    end
end
-- poolManager是否被销毁
function PoolManager:IsDestroyed()
    return not GS.UnityHelper.IsUnityObjectValid(self.parent)
end

function PoolManager:GetOPMTransform()
    if not self:IsDestroyed() then
        return self.parent.transform
    end
    return nil
end

return PoolManager