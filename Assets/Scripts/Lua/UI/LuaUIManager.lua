LuaUIManager = class(nil, {
    uiClassMap,
    panelMap,
})

function LuaUIManager:__init()
    self.uiClassMap = {}
    self.uiClassMap["InnerGameUI"] = InnerGameUI
    self.panelMap = {}
end

function LuaUIManager:OpenPanel(panelName, path)
    log("OpenPanel:" .. path)
    local panelObj = Loader:LoadAsset(path .. ".prefab", typeof(GameObject))
    local panel = Instantiate(panelObj)
    UIManager.Instance:BindLuaUIObject(panel, panelName)
    
    local panelInstance = self.uiClassMap[panelName](LuaClass(panel))
    self.panelMap[panelName] = panelInstance
end

function LuaUIManager:ClosePanel(panelName)
    --UIManager.Instance:CloseLuaUIObject(panelName)
    self.panelMap[panelName] = nil
end
