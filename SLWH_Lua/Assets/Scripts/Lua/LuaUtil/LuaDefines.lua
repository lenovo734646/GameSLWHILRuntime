--Debug.Log
log = CS.UnityEngine.Debug.Log
logWarning = CS.UnityEngine.Debug.LogWarning
logError = CS.UnityEngine.Debug.LogError

--UnityEngine
UnityEngine = CS.UnityEngine
Application = CS.UnityEngine.Application
Instantiate = CS.UnityEngine.Object.Instantiate
Destroy = CS.UnityEngine.Object.Destroy
GameObject = CS.UnityEngine.GameObject
Transform = CS.UnityEngine.Transform
Color = CS.UnityEngine.Color
TextAsset = CS.UnityEngine.TextAsset
Sprite = CS.UnityEngine.Sprite
Animator = CS.UnityEngine.Animator
Time = CS.UnityEngine.Time
SceneManager = CS.UnityEngine.SceneManagement.SceneManager
Math = CS.UnityEngine.Mathf
Vector3 = CS.UnityEngine.Vector3
Vector2 = CS.UnityEngine.Vector2
PlayerPrefs = CS.UnityEngine.PlayerPrefs
AudioClip = CS.UnityEngine.AudioClip
Input = CS.UnityEngine.Input

--UnityEngine.UI
Toggle = CS.UnityEngine.UI.Toggle
Text = CS.UnityEngine.UI.Text
Image = CS.UnityEngine.UI.Image
Button = CS.UnityEngine.UI.Button

--XLuaExtension
UpdateLuaBehaviour = CS.XLuaExtension.UpdateLuaBehaviour
UGUIClickLuaBehaviour = CS.XLuaExtension.UGUIClickLuaBehaviour

--Global
Timer = require "LuaUtil/Timer"
LuaClass = require "LuaUtil/LuaClass"
LuaBase = require "LuaUtil/LuaBase"
require'LuaUtil.Logger'

--CustomCSharp
Context = CS.Context
AssetConfig = CS.AssetConfig
Loader = CS.Context.Game.Loader
AppRoot = CS.AppRoot.Get()
--Loader = CS.ForRebuild.Loader(true)  -- param : 默认从大厅加载（强制update assets）
--log("DS Lua Defines  Loader")
--Loader = CS.AppRoot.Get().assetLoader
--log("DS Lua Defines  Loader  11")
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
AudioManager = CS.AudioManager.Instance
ObjectPoolManager = CS.ObjectPoolManager.Instance
CoroutineController = CS.CoroutineController.Instance
UnityHelper = CS.UnityHelper

-- OSAScrollVeiw 
OSA = OSA or{}
OSA.OSAScrollView = CS.OSAScrollView.OSAScrollView
OSA.MyParam = CS.OSAScrollView.MyParam
OSA.MyItemViewHolder = CS.OSAScrollView.MyItemViewHolder
OSA.ItemCountChangeMode = CS.Com.TheFallenGames.OSA.Core.ItemCountChangeMode
OSA.ContentGravity = CS.Com.TheFallenGames.OSA.Core.BaseParams.ContentGravity



