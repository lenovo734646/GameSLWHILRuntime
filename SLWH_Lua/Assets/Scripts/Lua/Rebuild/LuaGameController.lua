local Config = require "rebuild.config"
local _G = _G
local CS = CS
local g_Env = g_Env
local print, tostring, SysDefines, NetController, THotUpdateHelper, typeof, Destroy, LogE, assert = print, tostring,
    SysDefines, NetController, THotUpdateHelper, typeof, Destroy, LogE, assert

local pairs = pairs
local tonumber = tonumber
local LogTrace = LogTrace

local ModuleManager = CS.ModuleManager
local UIManager = CS.UIManager
local MessageCenter = CS.MessageCenter
local PlayerPrefs = PlayerPrefs

local EnumSceneType = CS.EnumSceneType
local EnumUIType = CS.EnumUIType

local yield = coroutine.yield

local LuaTableLoadHelper = require 'Rebuild.LuaTableLoadHelper'
require 'LuaUtil.Functions'
local LuaAppRoot = require 'Rebuild.LuaAppRoot'
local SmartLoadingUI = require 'UI.SmartLoadingUI'
local CoroutineHelper = require 'LuaUtil.CoroutineHelper'
local LuaLoginUI = require 'UI.LuaLoginUI'
local LuaLoginCtrl = require 'Controller.LuaLoginCtrl'
local Loader = require 'Rebuild.LuaAssetLoader'
local HelperFuntions = require 'LuaUtil.HelperFuntions'
local WebRequest = require 'Web.WebRequest'
local CommonModule = require 'Module.CommonModule'
local MainModule = require 'Module.MainModule'
local FishingMainModule = require 'Module.FishingMainModule'
local FishingRoomModule = require 'Module.FishingRoomModule'
-- local AssetUpdater = require 'Web.AssetUpdater'
local CommonUICtrl = require 'Controller.CommonUICtrl'
local AssetDownloader = require 'Web.AssetDownloader'
local Helpers = require'LuaUtil.Helpers'
_ENV = moduledef {
    seenamespace = UnityEngine
}
---------------------

local onStart
local doSetting
local genRunPlatformInfo
local doOpenInstallPro
local startCo

function Create(loader)
    -- 程序一开始就去获取IP
    InitNetWork()
    genRunPlatformInfo()
    local DDOLGameObject = GameObject.Find('DDOLGameObject')
    DDOLGameObject:AddComponent(typeof(CS.MessageCenter))
    DDOLGameObject:AddComponent(typeof(CS.ForReBuild.BundleRecycler))

    local canvas = _G.Instantiate(loader:Load("Common/Canvas.prefab"))
    _G.DontDestroyOnLoad(canvas)
    local commonSounds = loader:Load("AudioPackage/commonSounds.prefab")
    _G.DontDestroyOnLoad(_G.Instantiate(commonSounds)) -- 公共音频资源

    local canvasIniter = Helpers.GetInitHelperWithTable(canvas)
    
    local MainCanvasScaler = canvasIniter.canvas_canvasscaler -- 屏幕适配组件
    assert(MainCanvasScaler)
    g_Env.sharedMap:Add('MainCanvas', canvasIniter.canvas_canvas) -- 画布
    g_Env.sharedMap:Add('MainCanvasScaler', MainCanvasScaler)

    local UIParent = canvasIniter.uiparent_recttransform -- 所有UI父类，还有UIEffect特效层，HintMessage提示层
    g_Env.sharedMap:Add('UIParent', UIParent)

    local HintMessage = canvasIniter.hintmessage_recttransform
    g_Env.sharedMap:Add('HintMessage', HintMessage) -- 各种弱提示
    g_Env.UITopLayer = HintMessage

    local MainCamera = canvasIniter.maincamera_camera
    g_Env.sharedMap:Add('MainCamera', MainCamera) -- 主摄像机，正交，投射所有层
    -- 摄像机上的DOTween组件，摄像头动画(震动等)
    g_Env.sharedMap:Add('CameraAnim', canvasIniter.maincamera_dotweenanimation)

    local ThisT = canvasIniter.canvas_recttransform
    assert(ThisT)
    g_Env.sharedMap:Add('GameCtrlRectTransform', ThisT)

    local this = {
        go = canvas, -- UIPrefab/Canvas
        ThisT = ThisT,
        MainCanvas = canvas:GetComponent('Canvas'),
        UIParent = UIParent,
        HintMessage = HintMessage,
        MainCanvasScaler = MainCanvasScaler,
        SubGameParent = canvasIniter.subgameparent_recttransform,
        MainCamera = MainCamera,
        GetIpPort = GetIpPort
    }

    this.ReturnToLogin = function(self, ...)
        ReturnToLogin(self)
    end
    this.DoQuitScene = function(self, ...)
        DoQuitScene(self)
    end
    -- local params = {activeSlider=true}
    local params = {
        activeBG = true,
        notShowMask = true
    }
    local smartLoadingUI = SmartLoadingUI.Create(loader, UIParent, params)

    local hallLoader = Loader.Create(g_Env.Config:GetSavePath('Plaza'))
    g_Env.loaders.plaza = hallLoader

    doSetting(this)

    doOpenInstallPro(this, function()
        smartLoadingUI.ctrl:Start(function(req)
            return startCo(this, smartLoadingUI, req, loader)
        end)
    end)

    return this
end

function startCo(this, ui, req, loader)
    ui:SetTipText('正在初始化...')
    local hallLoader = g_Env.loaders.plaza
    if hallLoader then
        hallLoader:LoadSoundsPackageAsync('AudioPackage/PlazaBGMSounds.prefab')
        CS.AudioManager.Instance:PlayMusicListByPackName('PlazaBGMSounds')
    end

    while not g_Env.netinfo do
        yield()
    end
    local md5 = g_Env.netinfo.ClientConfigPkgMd5

    local url = g_Env.netinfo.OssUrl .. "/" .. SysDefines.ZoneId .. "/Table/Data/config.pkg"
    url = url:replace("https://", "http://")
    local loadFromNetreq = {
        progress = 0
    }
    LuaTableLoadHelper.LoadFromNetAsync(url, md5, loadFromNetreq)

    ModuleManager.Instance:RegisterBasicModules()
    -- 在这里注册大厅Module
    -- 注册CommonModule
    g_Env.commonModule = CommonModule()
    -- 注册MainModule
    g_Env.mainModule = MainModule()
    -- 注册FishingMainModule
    g_Env.fishingMainModule = FishingMainModule()
    -- 注册FishingRoomModule
    g_Env.fishingRoomModule = FishingRoomModule()

    g_Env.WebRequest = WebRequest

    yield()

    if g_Env.Config:IsUpdate() then
        print('.........................................update')
        req.ui = ui
        ui:SetTipText('检查更新...')
        while true do
            -- local  err = AssetUpdater.StartUpdateAsync(req,
            --     g_Env.Config:GetPlazaDLUrl(),
            --     g_Env.Config:GetPlazaSavePath(true))
            local err = AssetDownloader.DownLoadPlazaAsync(req)
            if err then
                CommonUICtrl.SetActiveByParam(ui, {
                    WaitResponseUI = false
                })
                local showCancel = true
                if req.needForceUpdate then
                    showCancel = nil
                end
                local btnstr = g_Env.MessageBox {
                    content = '下载出错\n' .. err,
                    showCancel = showCancel
                }:WaitBtnClickedAsync()
                if btnstr == 'cancel' then
                    break
                end
            else
                break
            end
        end
        CommonUICtrl.SetActiveByParam(ui, {
            WaitResponseUI = true
        })
    else
        print('g_Env.Config:IsUpdate() == false')
    end

    if not hallLoader then
        hallLoader = Loader.Create(g_Env.Config:GetSavePath('Plaza'))
        g_Env.loaders.plaza = hallLoader
        hallLoader:LoadSoundsPackageAsync('AudioPackage/PlazaBGMSounds.prefab')
        CS.AudioManager.Instance:PlayMusicListByPackName('PlazaBGMSounds')
    end

    hallLoader:LoadBundleAllAsync('hall/ui')

    local loginCtrl
    local luaLoginUI
    local params = {
        async = true,
        loadAsync = true,
        loadingUI = ui
    }
    local createLoginUI = function()
        params.ctrl = loginCtrl
        luaLoginUI = LuaLoginUI.Create(hallLoader, this.UIParent, params)
        loginCtrl = luaLoginUI.ctrl
    end
    local loginType = PlayerPrefs.GetInt("LastLoginType")
    if loginType > 0 and g_Env.autoLogin then
        loginCtrl = LuaLoginCtrl.Create()
        loginCtrl.loginType = loginType
        ui:SetTipText('正在自动登录...')
    else
        createLoginUI()
        loginType = nil
    end

    g_Env.blockWaitResponseUI = true
    local b, err
    for i = 0, 10 do
        b, err = loginCtrl:AutoLoginAsync(loginType)
        if not b then
            loginCtrl:ResetLoginState()
            g_Env.MessageBox(err).ctrl:WaitOKClickedAsync()
            if luaLoginUI == nil then
                createLoginUI()
            end
        else
            break
        end
    end
    if not b then
        g_Env.RestartGame("登录失败多次")
        return
    end

    g_Env.blockWaitResponseUI = false
    if luaLoginUI then
        luaLoginUI:Destroy()
    end
    g_Env.uiManager:OpenUI('PlazaUI', {
        loadAsync = true
    })
    ui:SetTipText('')

    local ver = GameObject.Find('VersionCanvas')
    if ver then
        Destroy(ver)
    end

    -- 用于方便测试小游戏
    local subgamename = Config:GetDebugEnterSubGame()
    if subgamename then
        CoroutineHelper.StartCoroutine(function()
            -- yield(WaitForSeconds(1))
            yield()
            g_Env.SubGameCtrl.Enter(subgamename)
        end)
    end

end

local function doQuitScene()
    local switch = {
        MainScene = function()
            NetController.Instance:SendLogoutReq()
        end,
        FishScene = function()
            --NetController.Instance:SendExitGameReq(function()
                g_Env.fishingRoomModule:SendExitGameReq(function()
                    
                end)
                -- NetController.Instance:SendExitSiteReq(SysDefines.SiteId)
            --end)
        end
    }
    local sceneType = _G.SceneManager.GetActiveScene().name
    if (switch[sceneType]) then
        switch[sceneType]()
    end
end

function QuitGame(this)
    UIManager.Instance:OpenMessageBoxUI(SysDefines.QuitGame, 10, CS.EnumMessageBoxType.OK_CANCEL, doQuitScene)
end

function QuitScene(this, content)

    if (content == SysDefines.QuitFishScene) then
        g_Env.uiManager:OpenUI("LuaMessageLeaveFishUI")
        -- UIManager.Instance:OpenUI(EnumUIType.MessageLeaveFishUI)
    else
        UIManager.Instance:OpenMessageBoxUI(content, 10, CS.EnumMessageBoxType.OK_CANCEL, doQuitScene)
    end
end

function DoQuitScene(this)
    doQuitScene()
end

function ReturnToLogin(this)
    -- LogTrace('ReturnToLogin')
    if (SysDefines.SceneType ~= EnumSceneType.LoginScene) then
        CS.ModuleManager.Instance:UnRegisterGameModules()
        if (g_Env.luaAppRoot.curState == 1) then
            UIManager.Instance:ClearLuaUIObject()
            local parent = this.UIParent
            local count = parent.childCount
            for i = 0, count - 1 do
                local child = parent:GetChild(i)
                Destroy(child.gameObject)
            end
            LuaAppRoot.ForceQuit(g_Env.luaAppRoot)
        end
        -- print('ReturnToLogin UIManager.Instance:OpenUICloseOthers')
        UIManager.Instance:OpenUICloseOthers(EnumUIType.LoadingUI, true, EnumUIType.LoginUI, EnumSceneType.LoginScene)
    end
end

function genRunPlatformInfo()
    local t = {
        [RuntimePlatform.IPhonePlayer] = 1,
        [RuntimePlatform.Android] = 2,
        [RuntimePlatform.WindowsPlayer] = 3,
        [RuntimePlatform.LinuxPlayer] = 4,
        [RuntimePlatform.OSXPlayer] = 5,
        [RuntimePlatform.WindowsEditor] = 3
    }
    local t2 = {
        [RuntimePlatform.IPhonePlayer] = 1,
        [RuntimePlatform.Android] = 2,
        [RuntimePlatform.WindowsPlayer] = 'Win',
        [RuntimePlatform.LinuxPlayer] = 4,
        [RuntimePlatform.OSXPlayer] = 5,
        [RuntimePlatform.WindowsEditor] = 'Win'
    }
    SysDefines.Platform = t[Application.platform]
end

function doOpenInstallPro(this, callback)
    if (Application.platform == RuntimePlatform.Android or Application.platform == RuntimePlatform.IPhonePlayer) and
        Application.platform ~= RuntimePlatform.WindowsEditor then
        local openinstall = GameObject('OpenInstall'):AddComponent(typeof(CS.io.openinstall.unity.OpenInstall))
        openinstall:GetInstall(5, function(installData)
            local jstr = installData.bindData
            if jstr and jstr ~= '' then
                local t = _G.json.decode(jstr)
                local dataStr = "u=" .. tostring(t.u)
                print('OpeninstallToken:' .. tostring(dataStr))
                this.OpeninstallToken = dataStr
            end
            callback(this)
        end)
    else
        this.OpeninstallToken = ''
        callback(this)
    end
end

function GetIpPort(bWarForResultAsync)
    local handler = function(errRsp, rsp)
        local Ip, Port
        if errRsp then
            if PlayerPrefs.HasKey('Ip') then
                Ip, Port = PlayerPrefs.GetString('Ip'), PlayerPrefs.GetInt('Port')
                g_Env.ipinfo = {
                    Ip = Ip,
                    Port = Port,
                    isCache = true
                }
                g_Env.CreateHintMessage('网络不稳定使用缓存的地址')
            else
                g_Env.RestartGame(errRsp.msg)
            end
        else
            local Ip, Port = rsp.ip, tonumber(rsp.port)

            g_Env.ipinfo = {
                Ip = Ip,
                Port = Port
            }
            print(g_Env.ipinfo.Ip)
            PlayerPrefs.SetString('Ip', Ip)
            PlayerPrefs.SetInt('Port', Port)
        end
    end
    if bWarForResultAsync then
        local errRsp, rsp = WebRequest.GetGateConnectionAsync(g_Env.zone_id)
        handler(errRsp, rsp)
    else
        WebRequest.GetGateConnection(handler, g_Env.zone_id)
    end
end

function InitNetWork()
    NetController.Instance.serverUrl = g_Env.ServerUrl
    GetIpPort()
    WebRequest.GetDownloadUrl(function(errRsp, rsp)
        local OssUrl, PopularizeUrl, ClientConfigPkgMd5
        if errRsp then
            if PlayerPrefs.HasKey('OssUrl') then
                OssUrl, PopularizeUrl, ClientConfigPkgMd5 = PlayerPrefs.GetString('OssUrl'),
                    PlayerPrefs.GetString('PopularizeUrl'), PlayerPrefs.GetString('ClientConfigPkgMd5')
                g_Env.netinfo = {
                    OssUrl = OssUrl,
                    PopularizeUrl = PopularizeUrl,
                    ClientConfigPkgMd5 = ClientConfigPkgMd5,
                    isCache = true
                }
                g_Env.MessageBox('网络不稳定使用缓存的数据。\n错误原因:' .. tostring(errRsp.msg))
            else
                g_Env.RestartGame(errRsp.msg)
            end
        else
            OssUrl, PopularizeUrl, ClientConfigPkgMd5 = rsp.oss_url, rsp.popularize_url, rsp.client_config_pkg_md5
            g_Env.netinfo = {
                OssUrl = OssUrl,
                PopularizeUrl = PopularizeUrl,
                ClientConfigPkgMd5 = ClientConfigPkgMd5
            }
            PlayerPrefs.SetString('OssUrl', OssUrl)
            PlayerPrefs.SetString('PopularizeUrl', PopularizeUrl)
            PlayerPrefs.SetString('ClientConfigPkgMd5', ClientConfigPkgMd5)
        end
        -- print('GetDownloadUrl ',OssUrl)
    end, g_Env.zone_id)

end

function doSetting(this)
    Application.targetFrameRate = 60
    Input.multiTouchEnabled = true
    Screen.sleepTimeout = SleepTimeout.NeverSleep
    this.ThisT.localPosition = Vector3(0, 0, this.MainCanvas.planeDistance)

    if LOCAL_DEBUG then
        Debug.unityLogger.logEnabled = true
    else
        Debug.unityLogger.filterLogType = LogType.Warning
    end
end

return _ENV
