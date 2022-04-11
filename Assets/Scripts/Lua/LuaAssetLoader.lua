local yield = coroutine.yield

local Class = class()

function Class.Create()
    return Class()
end

-- notCache在大厅运行时有用
function Class:Load(path, type)

    local isRawPath = GF.string.Contains(path, 'Assets/')
    Log('Load from editor ', path, isRawPath)
    local r
    if type then
        r = GS.ResHelper.Load(path, type, isRawPath)
    else
        r = GS.ResHelper.Load(path, isRawPath)
    end
    if r then
        return r
    else
        LogE('can not load from editor ' .. path)
    end
    return Log('Load ' .. path)
end

-- 载入所有
function Class:LoadAll(path, type)
    local isRawPath = GF.string.Contains(path, 'Assets/')

    Log('LoadAll from editor ', path, isRawPath)
    local r
    r = GS.ResHelper.LoadAll(path, isRawPath)
    if r then
        return r
    else
        LogE('can not load from editor ' .. path)
    end
    return Log('LoadAll ' .. path)
end

local function doDone(req, assert)
    req.isDone = true
    req.progress = 1
    req.assert = assert
    if req.onComplete then
        req.onComplete(assert)
    end
    return assert
end
-- 异步加载，在编辑器模式下看不出效果，但是建议使用此方法以提升加载流畅度
function Class:LoadAsync(path, infoOut)
    yield()
    local isRawPath = GF.string.Contains(path, 'Assets/')
    infoOut = infoOut or {}
    infoOut.progress = 0
    return doDone(infoOut, GS.ResHelper.Load(path, isRawPath))
end
-- 可以根据bundlename进行加载，在编辑器模式下无效
function Class:LoadBundle(bundlename)
    assert(bundlename)
end
-- 可以根据bundlename进行加载，在编辑器模式下无效
function Class:LoadBundleAsync(bundlename)
    assert(bundlename)
    yield()
end

function Class:LoadBundleAllAsync(bundlename)
    local abinfo = self:LoadBundleAsync(bundlename)
    if not abinfo then
        return
    end

    local allnames = abinfo:GetAllAssetNames()
    local len = allnames.Length - 1
    for i = 0, len do
        local name = allnames[i]
        local req = abinfo:LoadAssetAsync(name)
        yield(req)
    end
    return abinfo
end

function Class:LoadScene(name)
    if GG.Config.isLoadFromEditor then
        GS.SceneManager.LoadScene(name)
        return
    end
    local path = [[Assets/Scenes/]] .. name .. '.unity'
    self:Load(path)
    return GS.SceneManager.LoadScene(name)
end

function Class:LoadSceneAsync(name, infoOut)
    if not GG.Config.isLoadFromEditor then
        local path = [[Assets/Scenes/]] .. name .. '.unity'
        self:LoadAsync(path)
    end
    local req = GS.SceneManager.LoadSceneAsync(name)
    if infoOut then
        infoOut.progress = 0
        while not req.isDone do
            if infoOut.UpdateInfo then
                infoOut:UpdateInfo(req.progress)
            else
                infoOut.progress = req.progress
            end
        end
        infoOut.progress = 1
    else
        yield(req)
    end

    -- self.sceneCache[name] = true
end

function Class:LoadSoundsPackageAsync(path)
    local prefab = self:LoadAsync(path)
    return GS.Instantiate(prefab) -- 声音装载
end

function Class:LoadSoundsPackage(path)
    local prefab = self:Load(path)
    return GS.Instantiate(prefab) -- 声音装载
end
-- 释放所有资源
function Class:Clear()

end

return Class
