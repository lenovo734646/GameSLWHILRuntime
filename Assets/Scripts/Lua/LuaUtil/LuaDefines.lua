-- 全局变量采用GS前缀管理
GS = {}

print("定义全局变量GS")
local meta_GS = {}
local UnityEngine = CS.UnityEngine

typeof = typeof
g_Env = g_Env

meta_GS.CS = CS
meta_GS.UnityEngine = CS.UnityEngine

-- meta_GS.Instantiate = UnityEngine.Object.Instantiate
local InstantiateOld= UnityEngine.Object.Instantiate
local assert = assert

meta_GS.Instantiate = function (prefab,...)
    assert(prefab)
    return InstantiateOld(prefab,...)
end

-- UnityEngine
meta_GS.Application = UnityEngine.Application
meta_GS.DontDestroyOnLoad = UnityEngine.Object.DontDestroyOnLoad 
meta_GS.Destroy = UnityEngine.Object.Destroy
meta_GS.DestroyImmediate = UnityEngine.Object.DestroyImmediate
meta_GS.GameObject = UnityEngine.GameObject
meta_GS.Transform = UnityEngine.Transform
meta_GS.Color = UnityEngine.Color
meta_GS.TextAsset = UnityEngine.TextAsset
meta_GS.Sprite = UnityEngine.Sprite
meta_GS.Animator = UnityEngine.Animator
meta_GS.Time = UnityEngine.Time
meta_GS.SceneManager = UnityEngine.SceneManagement.SceneManager
meta_GS.Math = UnityEngine.Mathf
meta_GS.Vector3 = UnityEngine.Vector3
meta_GS.Vector2 = UnityEngine.Vector2
meta_GS.Rect = UnityEngine.Rect
meta_GS.PlayerPrefs = UnityEngine.PlayerPrefs
meta_GS.Quaternion = UnityEngine.Quaternion
meta_GS.ScreenOrientation = UnityEngine.ScreenOrientation
meta_GS.Screen = UnityEngine.Screen
meta_GS.TextAnchor = UnityEngine.TextAnchor
meta_GS.Input = UnityEngine.Input
meta_GS.KeyCode = UnityEngine.KeyCode
meta_GS.RuntimePlatform = UnityEngine.RuntimePlatform

-- UnityEngine.UI
meta_GS.Toggle = UnityEngine.UI.Toggle
meta_GS.Text = UnityEngine.UI.Text
meta_GS.Image = UnityEngine.UI.Image
meta_GS.Button = UnityEngine.UI.Button

-- XLuaExtension
meta_GS.UpdateLuaBehaviour = CS.XLuaExtension.UpdateLuaBehaviour
meta_GS.UGUIClickLuaBehaviour = CS.XLuaExtension.UGUIClickLuaBehaviour
meta_GS.LuaUnityEventListener = CS.LuaUnityEventListener
meta_GS.KeyEventListener = CS.KeyEventListener

-- CustomCSharp
meta_GS.AssetConfig = CS.AssetConfig
meta_GS.AsyncImageDownload = CS.AsyncImageDownload.Instance

-- XiaoShi
meta_GS.SysDefines = CS.SysDefines
meta_GS.UIManager = CS.UIManager
meta_GS.GameController = CS.GameController

--
meta_GS.NetController = CS.NetController
meta_GS.TableLoadHelper = CS.TableLoadHelper
meta_GS.UnityHelper = CS.UnityHelper
meta_GS.ICSharpCode = CS.ICSharpCode
meta_GS.FPSChecker = CS.FPSChecker
meta_GS.CertHandler = CS.CertHandler
meta_GS.MessageCenter = CS.MessageCenter
meta_GS.SubGameCoStarter = CS.SubGameCoStarter
meta_GS.TimeHelper = CS.TimeHelper
meta_GS.AudioManager = CS.AudioManager
meta_GS.BundlePathHelper = CS.BundlePathHelper
meta_GS.ResHelper = CS.ResHelper
meta_GS.LuaInitHelper = CS.LuaInitHelper
meta_GS.LuaInitMultiListHelper = CS.LuaInitMultiListHelper
meta_GS.ItemScrollView = CS.ItemScrollView
meta_GS.LuaBundleLoader = CS.LuaBundleLoader
meta_GS.LuaFileLoader = CS.LuaFileLoader
meta_GS.ObjectPoolManager = CS.ObjectPoolManager
meta_GS.LuaEntry = CS.LuaEntry
meta_GS.QWebRequset = CS.QWebRequset
meta_GS.AnimationHelper = CS.AnimationHelper
meta_GS.EventBroadcaster = CS.EventBroadcaster
meta_GS.AnimatorHelper = CS.ForReBuild.UIHelper.AnimationHelper

-- ForReBuild
meta_GS.BundleInfo = CS.ForReBuild.BundleInfo
meta_GS.BundleRecycler = CS.ForReBuild.BundleRecycler

-- Tweening
meta_GS.DG = CS.DG
meta_GS.DOTween = CS.DG.Tweening.DOTween
meta_GS.Ease = CS.DG.Tweening.Ease
meta_GS.LoopType = CS.DG.Tweening.LoopType

-- System
meta_GS.System = CS.System
meta_GS.File = CS.System.IO.File
meta_GS.Directory = CS.System.IO.Directory
meta_GS.DateTime = CS.System.DateTime
meta_GS.Path = CS.System.IO.Path
meta_GS.DateTimeKind = CS.System.DateTimeKind

-- TMPro
meta_GS.TMPro = CS.TMPro
-- meta_GS.TMP_Dropdown = CS.TMPro.TMP_Dropdown
-- meta_GS.TMP_InputField = CS.TMPro.TMP_InputField
-- meta_GS.TextMeshProUGUI = CS.TMPro.TextMeshProUGUI

-- OSAHelper
meta_GS.OSAHelper = CS.OSAHelper
meta_GS.ContentGravity = CS.OSAHelper.ContentGravity
meta_GS.ItemViewHolder = CS.OSAHelper.ItemViewHolder
meta_GS.MyItemViewHolder = CS.OSAHelper.MyItemViewHolder
meta_GS.OSAScrollView = CS.OSAHelper.OSAScrollView
meta_GS.MyParam = CS.OSAHelper.MyParam

--
meta_GS.OSA = CS.Com.TheFallenGames.OSA
meta_GS.ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode

-- cs自定义全局变量
meta_GS.gLuaEntryGameObject = gLuaEntryGameObject
meta_GS.gLuaEntryCom = gLuaEntryCom
meta_GS.DEV_VER = DEV_VER
meta_GS.UNITY_EDITOR = UNITY_EDITOR
meta_GS.USE_UPDATE_TEST_PLAZA_PATH = USE_UPDATE_TEST_PLAZA_PATH

-- 固定碰撞边界比例为16:9
meta_GS.isFixedScreen = false
-- 宽
meta_GS.DesignWidth = 1920
-- 高
meta_GS.DesignHeight = 1080

-- 小游戏进行赋值
OnSceneLoaded = nil
Update = nil
OnReceiveNetDataPack = nil
OnNetworkLost = nil
OnApplicationPause = nil
OnApplicationFocus = nil
OnNetworkReConnect = nil
_WaitSubGameLoadDone = nil
OnCloseSubGame = nil
-- IsRunInHall = nil -- 小游戏是否运行在大厅中

meta_GS.LuaClass = require "LuaUtil/LuaClass"
meta_GS.LuaBase = require "LuaUtil/LuaBase"

-- ==================设置GS表为只读表==================
local setonlyreadtable = function(tab, metatab)
    setmetatable(tab, {
        __index = function(t, k)
            return metatab[k]
        end,
        __newindex = function(t, k, v)
            Assert(false, 'table GS is only read', k)
        end
    })
end

-- 可写字段
GS.UnityHelper = meta_GS.UnityHelper
GS.SysDefines = meta_GS.SysDefines

setonlyreadtable(GS, meta_GS)
