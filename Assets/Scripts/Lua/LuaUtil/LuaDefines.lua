typeof = typeof

--Global
LuaClass = require "LuaUtil/LuaClass"
LuaBase = require "LuaUtil/LuaBase"

--GlobalPath
Path_Res = "Assets/JiuXian/"
Path_UI = Path_Res .. "UIPrefab/"
Path_UI_Item = Path_Res.."UIItem/"
Path_Audios = Path_Res.."Sound/"

-- 大厅传过来的全局变量（只能使用，不能改变）
-- SubGame_Env结构说明
-- SubGame_Env = {
--     gamePlayer = "玩家信息表",
--     loader = "游戏加载器",
--     LanguageConvert = {}
-- }
-- 其它变量G_gLuaEntryCom/G_IsRunInHall/G_g_Env/G_STR_
gLuaEntryCom = G_gLuaEntryCom or gLuaEntryCom
IsRunInHall = G_IsRunInHall
g_Env = G_g_Env
_STR_ = G_STR_ or function(str)
    local t = SEnv.LanguageConvert[str]
    if t then
        local tstr = t[CS.SysDefines.curLanguage]
        if tstr then
            return tstr
        else
            LogW("_STR_: <"..str..">  没有对应的值")
        end
    end
    return str
end

-- 全局变量采用GS前缀管理
if not GS then
    print("初始化GS全局变量")
    GS = {}

    local meta_GS = {}
    local UnityEngine = CS.UnityEngine

    meta_GS.CS = CS

    -- UnityEngine
    meta_GS.UnityEngine = UnityEngine
    meta_GS.Application = UnityEngine.Application
    -- meta_GS.Instantiate = UnityEngine.Object.Instantiate
    local InstantiateOld= UnityEngine.Object.Instantiate
    local assert = assert
    meta_GS.Instantiate = function (prefab,...) -- 重写了 Instantiate 为了 检测 prefab 是否存在
        assert(prefab)
        return InstantiateOld(prefab,...)
    end
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
    meta_GS.AudioClip = UnityEngine.AudioClip
    meta_GS.EventTriggerType = UnityEngine.EventSystems.EventTriggerType
    meta_GS.Rigidbody = UnityEngine.Rigidbody

    -- UnityEngine.UI
    meta_GS.Toggle = UnityEngine.UI.Toggle
    meta_GS.Text = UnityEngine.UI.Text
    meta_GS.Image = UnityEngine.UI.Image
    meta_GS.Button = UnityEngine.UI.Button

    -- XLuaExtension
    meta_GS.UpdateLuaBehaviour = CS.XLuaExtension.UpdateLuaBehaviour
    meta_GS.UGUIClickLuaBehaviour = CS.XLuaExtension.UGUIClickLuaBehaviour
    meta_GS.LuaUnityEventListener = CS.LuaUnityEventListener

    -- CustomCSharp
    meta_GS.Context = CS.Context
    meta_GS.AssetConfig = CS.AssetConfig
    meta_GS.AsyncImageDownload = CS.AsyncImageDownload

    --XiaoShi
    meta_GS.SysDefines = CS.SysDefines
    meta_GS.UIManager = CS.UIManager

    --
    meta_GS.NetController = CS.NetController
    meta_GS.TableLoadHelper = CS.TableLoadHelper
    --
    meta_GS.UnityHelper = CS.UnityHelper
    meta_GS.RandomInt = CS.UnityHelper.RandomInt
    meta_GS.RandomFloat = CS.UnityEngine.Random.Range
    meta_GS.IsUnityObjectValid = CS.UnityHelper.IsUnityObjectValid
    --
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
    meta_GS.ObjectPoolManagerSubGame = CS.ObjectPoolManagerSubGame
    meta_GS.ObjectPoolManager = CS.ObjectPoolManager
    meta_GS.LuaEntry = CS.LuaEntry
    meta_GS.QWebRequset = CS.QWebRequset

    meta_GS.KeyEventListener = CS.KeyEventListener
    meta_GS.AnimationHelper = CS.AnimationHelper
    meta_GS.EventBroadcaster = CS.EventBroadcaster

    -- ForReBuild
    meta_GS.BundleInfo = CS.ForReBuild.BundleInfo
    meta_GS.BundleRecycler = CS.ForReBuild.BundleRecycler

    --Spine
    meta_GS.SkeletonGraphic = CS.Spine.Unity.SkeletonGraphic

    -- Tweening
    meta_GS.DG = CS.DG
    meta_GS.DOTween = CS.DG.Tweening.DOTween
    meta_GS.TweeningEase = CS.DG.Tweening.Ease
    meta_GS.TweeningLoopType = CS.DG.Tweening.LoopType
    meta_GS.TweeningPathType = CS.DG.Tweening.PathType
    meta_GS.TweeningPathMode = CS.DG.Tweening.PathMode
    meta_GS.DOTweenAnimation = CS.DG.Tweening.DOTweenAnimation

    -- System
    meta_GS.DateTime = CS.System.DateTime
    meta_GS.DateTime = CS.System.DateTime
    meta_GS.Path = CS.System.IO.Path
    meta_GS.DateTimeKind = CS.System.DateTimeKind

    -- OSAHelper -- OSA 的再包装
    meta_GS.OSAHelper = CS.OSAHelper
    meta_GS.ItemViewHolder = CS.OSAHelper.ItemViewHolder
    -- OSA
    meta_GS.OSA = CS.Com.TheFallenGames.OSA
    meta_GS.ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode

    -- 实例化DDOLGameObject
    meta_GS.ObjectPoolManager = {}
    meta_GS.ObjectPoolManager.Instance = CS.ObjectPoolManager.Instance

    -- ==================设置GS表为只读表==================
    local setonlyreadtable = function(tab, metatab)
        setmetatable(tab, {
            __index = function(t, k)
                return metatab[k]
            end,
            __newindex = function(t, k, v)
                LogE('table GS is only read', k)
            end
        })
    end

    setonlyreadtable(GS, meta_GS)

end