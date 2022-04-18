local GS = GS
local GF = GF
local LogE=LogE
local table=table
local g_Env=g_Env

local Pool = class(nil, {
    prefab = nil,
    tActive = nil,
    tInactive = nil,
    max = nil
})

function Pool:__init(_prefab, max)
    self.prefab = _prefab
    self.max = max == nil and 1000 or max
    self.tActive = {}
    self.tInactive = {}
end

function Pool:Spawn(pos, rot, parent, script)
    local poolObj
    if #self.tInactive == 0 then
        local obj = GS.Instantiate(self.prefab, pos, rot)
        if script then
            poolObj = script(GS.LuaClass(obj))
        else
            poolObj = obj
        end
    else
        poolObj = self.tInactive[1]
        table.remove(self.tInactive, 1)
    end
    poolObj.transform:SetParent(parent, false)
    poolObj.transform.localScale = GS.UnityEngine.Vector3.one
    poolObj.transform.localPosition = pos
    poolObj.transform.localRotation = rot
    poolObj.gameObject:SetActive(true)
    table.insert(self.tActive, poolObj)

    return poolObj
end

function Pool:Unspawn(poolObj)
    if GF.table.contains(self.tActive, poolObj) then
        if not GS.UnityHelper.IsUnityObjectValid(poolObj.gameObject) then
            LogE('try to Unspawn an invalid gameObject')
            return false
        end
        poolObj.gameObject:SetActive(false)
        table.insert(self.tInactive, poolObj)
        GF.table.removebyvalue(self.tActive, poolObj)
        if g_Env.Fishing3DEnv then
            local poolManagerTrans = g_Env.Fishing3DEnv.poolManager:GetOPMTransform()
            if not poolManagerTrans then
                return false
            end
            poolObj.transform:SetParent(g_Env.Fishing3DEnv.poolManager:GetOPMTransform())
        end
        return true
    else
        return false
    end
end

function Pool:MachObjectCount(count)
    if count > self.max then
        return
    end

    local currentCount = #self.tActive + #self.tInactive
    for i = currentCount, count do
        local obj = GS.Instantiate(self.prefab)
        obj.transform:SetParent(g_Env.Fishing3DEnv.poolManager:GetOPMTransform())
        obj.gameObject:SetActive(false)
        table.insert(self.tInactive, obj)
    end
end

function Pool:Clear()
    for k, v in pairs(self.tActive) do
        GF.SafeDestroy(v.gameObject)
    end
    for k, v in pairs(self.tInactive) do
        GF.SafeDestroy(v.gameObject)
    end
    self.tActive = {}
    self.tInactive = {}
end

return Pool
