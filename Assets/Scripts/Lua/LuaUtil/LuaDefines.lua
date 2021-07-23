--Debug.Log
log = CS.UnityEngine.Debug.Log
logWarning = CS.UnityEngine.Debug.LogWarning
logError = CS.UnityEngine.Debug.LogError

--UnityEngine
UnityEngine = CS.UnityEngine
DontDestroyOnLoad = UnityEngine.Object.DontDestroyOnLoad
DestroyImmediate = UnityEngine.Object.DestroyImmediate
Application = CS.UnityEngine.Application
Instantiate = CS.UnityEngine.Object.Instantiate
Destroy = CS.UnityEngine.Object.Destroy
GameObject = CS.UnityEngine.GameObject
Transform = CS.UnityEngine.Transform
RectTransform = CS.UnityEngine.RectTransform
Color = CS.UnityEngine.Color
TextAsset = CS.UnityEngine.TextAsset
Sprite = CS.UnityEngine.Sprite
Animator = CS.UnityEngine.Animator
Time = CS.UnityEngine.Time
SceneManager = CS.UnityEngine.SceneManagement.SceneManager
Math = CS.UnityEngine.Mathf
Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
Quaternion = CS.UnityEngine.Quaternion
PlayerPrefs = CS.UnityEngine.PlayerPrefs
AudioClip = CS.UnityEngine.AudioClip
DateTime = CS.System.DateTime
TimeSpan = CS.System.TimeSpan
Input = CS.UnityEngine.Input
IsUnityObjectValid = CS.UnityHelper.IsUnityObjectValid

--UnityEngine.UI
Toggle = CS.UnityEngine.UI.Toggle
Text = CS.UnityEngine.UI.Text
Image = CS.UnityEngine.UI.Image
Button = CS.UnityEngine.UI.Button

--XLuaExtension
UpdateLuaBehaviour = CS.XLuaExtension.UpdateLuaBehaviour
UGUIClickLuaBehaviour = CS.XLuaExtension.UGUIClickLuaBehaviour



--CustomCSharp
Context = CS.Context
AssetConfig = CS.AssetConfig
AsyncImageDownload = CS.AsyncImageDownload.Instance

--Spine
SkeletonGraphic = CS.Spine.Unity.SkeletonGraphic

--Tweening
Ease = CS.DG.Tweening.Ease
LoopType = CS.DG.Tweening.LoopType

--XiaoShi
SysDefines = CS.SysDefines
UIManager = CS.UIManager
GameController = CS.GameController
ObjectPoolManager = CS.ObjectPoolManager.Instance
UnityHelper = CS.UnityHelper

-- OSAScrollVeiw 
OSA = OSA or{}
OSA.OSAScrollView = CS.OSAHelper.OSAScrollView
OSA.MyParam = CS.OSAHelper.MyParam
OSA.MyItemViewHolder = CS.OSAHelper.MyItemViewHolder
OSA.ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
OSA.ContentGravity = CS.Com.TheFallenGames.OSA.Core.BaseParams.ContentGravity
--Global
Timer = require "LuaUtil/Timer"
LuaClass = require "LuaUtil/LuaClass"
LuaBase = require "LuaUtil/LuaBase"
require'LuaUtil.Logger'


