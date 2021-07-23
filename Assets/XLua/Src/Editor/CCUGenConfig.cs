

using System.Collections.Generic;
using System;
using XLua;
using System.Reflection;
using System.Linq;
using UnityEngine;
using XLuaExtension;
using System.Collections;

public static class CCUGenConfig
{
    /***************如果你全lua编程，可以参考这份自动化配置***************/
    //--------------begin 纯lua编程配置参考----------------------------
    static List<string> exclude = new List<string> {
        "HideInInspector", "ExecuteInEditMode",
        "AddComponentMenu", "ContextMenu",
        "RequireComponent", "DisallowMultipleComponent",
        "SerializeField", "AssemblyIsEditorAssembly",
        "Attribute", "Types",
        "UnitySurrogateSelector", "TrackedReference",
        "TypeInferenceRules", "FFTWindow",
        "RPC", "Network", "MasterServer",
        "BitStream", "HostData",
        "ConnectionTesterStatus", "GUI", "EventType",
        "EventModifiers", "FontStyle", "TextAlignment",
        "TextEditor", "TextEditorDblClickSnapping",
        "TextGenerator", "TextClipping", "Gizmos",
        "ADBannerView", "ADInterstitialAd",
        "Android", "Tizen", "jvalue",
        "iPhone", "iOS", "Windows", "CalendarIdentifier",
        "CalendarUnit", "CalendarUnit",
        "ClusterInput", "FullScreenMovieControlMode",
        "FullScreenMovieScalingMode", "Handheld",
        "LocalNotification", "NotificationServices",
        "RemoteNotificationType", "RemoteNotification",
        "SamsungTV", "TextureCompressionQuality",
        "TouchScreenKeyboardType", "TouchScreenKeyboard",
        "MovieTexture", "UnityEngineInternal",
        "Terrain", "Tree", "SplatPrototype",
        "DetailPrototype", "DetailRenderMode",
        "MeshSubsetCombineUtility", "AOT", "Social", "Enumerator",
        "SendMouseEvents", "Cursor", "Flash", "ActionScript",
        "OnRequestRebuild", "Ping",
        "ShaderVariantCollection", "SimpleJson.Reflection",
        "CoroutineTween", "GraphicRebuildTracker",
        "Advertisements", "UnityEditor", "WSA",
        "EventProvider", "Apple",
        "ClusterInput", "Motion",
        "UnityEngine.UI.ReflectionMethodsCache", "NativeLeakDetection",
        "NativeLeakDetectionMode", "WWWAudioExtensions", "UnityEngine.Experimental",
    };

    static bool isExcluded(Type type)
    {
        var fullName = type.FullName;
        for (int i = 0; i < exclude.Count; i++)
        {
            if (fullName.Contains(exclude[i]))
            {
                return true;
            }
        }
        return false;
    }
    //用于自定义的类
    static List<string> exclude2 = new List<string> {
        "DebugUILine",
        "Tester",
        "TestGC",
        "GLuaSharedHelper",
        "TAnim_EditorHelper",
        "ReferenceFinderData",
        "AssetTreeView",
        "CustomEditorNameAttribute",
        "SeletTypeAttribute",
        "LabelAttribute",
    };
    static bool isExcludedCustomType(Type type)
    {
        var fullName = type.FullName;
        for (int i = 0; i < exclude2.Count; i++)
        {
            if (fullName.Contains(exclude2[i]))
            {
                return true;
            }
        }
        return false;
    }

    [LuaCallCSharp]
    public static IEnumerable<Type> LuaCallCSharp
    {
        get
        {
            List<string> namespaces = new List<string>() // 在这里添加名字空间
            {
                "UnityEngine",
                "UnityEngine.UI",
                "UnityEngine.SceneManagement",
                "XLuaExtension",
                "Spine.Unity",
                "UnityEngine.EventSystems",
            };
            var unityTypes = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                              where !(assembly.ManifestModule is System.Reflection.Emit.ModuleBuilder)
                              from type in assembly.GetExportedTypes()
                              where type.Namespace != null && namespaces.Contains(type.Namespace) && !isExcluded(type)
                                      && type.BaseType != typeof(MulticastDelegate) && !type.IsInterface && !type.IsEnum
                              select type);

            string[] customAssemblys = new string[] {
                "Assembly-CSharp",
            };
            var customTypes = (from assembly in customAssemblys.Select(s => Assembly.Load(s))
                               from type in assembly.GetExportedTypes()
                               where ((type.Namespace == null || !type.Namespace.StartsWith("XLua")
                                       && type.BaseType != typeof(MulticastDelegate) && !type.IsInterface && !type.IsEnum)
                                       && !isExcludedCustomType(type))
                               select type);
            return unityTypes.Concat(customTypes);
        }
    }

    //自动把LuaCallCSharp涉及到的delegate加到CSharpCallLua列表，后续可以直接用lua函数做callback
    [CSharpCallLua]
    public static List<Type> CSharpCallLua
    {
        get
        {
            var lua_call_csharp = LuaCallCSharp;
            var delegate_types = new List<Type>();
            var flag = BindingFlags.Public | BindingFlags.Instance
                | BindingFlags.Static | BindingFlags.IgnoreCase | BindingFlags.DeclaredOnly;
            foreach (var field in (from type in lua_call_csharp select type).SelectMany(type => type.GetFields(flag)))
            {
                if (typeof(Delegate).IsAssignableFrom(field.FieldType))
                {
                    delegate_types.Add(field.FieldType);
                }
            }

            foreach (var method in (from type in lua_call_csharp select type).SelectMany(type => type.GetMethods(flag)))
            {
                if (typeof(Delegate).IsAssignableFrom(method.ReturnType))
                {
                    delegate_types.Add(method.ReturnType);
                }
                foreach (var param in method.GetParameters())
                {
                    var paramType = param.ParameterType.IsByRef ? param.ParameterType.GetElementType() : param.ParameterType;
                    if (typeof(Delegate).IsAssignableFrom(paramType))
                    {
                        delegate_types.Add(paramType);
                    }
                }
            }
            return delegate_types
                .Where(t => t.BaseType == typeof(MulticastDelegate) && !hasGenericParameter(t) && !delegateHasEditorRef(t))
                .Where(t => !isInDelegateInBlackList(t))
                .Distinct().ToList();
        }
    }
    // --------------end 纯lua编程配置参考----------------------------

    /***************热补丁可以参考这份自动化配置***************/
    [Hotfix]
    static IEnumerable<Type> HotfixInject
    {
        get
        {
            return (from type in Assembly.Load("Assembly-CSharp").GetTypes()
                    where type.Namespace == null || !type.Namespace.StartsWith("XLua")
                    select type);
        }
    }
    //--------------begin 热补丁自动化配置-------------------------
    static bool hasGenericParameter(Type type)
    {
        if (type.IsGenericTypeDefinition) return true;
        if (type.IsGenericParameter) return true;
        if (type.IsByRef || type.IsArray)
        {
            return hasGenericParameter(type.GetElementType());
        }
        if (type.IsGenericType)
        {
            foreach (var typeArg in type.GetGenericArguments())
            {
                if (hasGenericParameter(typeArg))
                {
                    return true;
                }
            }
        }
        return false;
    }

    static bool typeHasEditorRef(Type type)
    {
        if (type.Namespace != null && (type.Namespace == "UnityEditor" || type.Namespace.StartsWith("UnityEditor.")))
        {
            return true;
        }
        if (type.IsNested)
        {
            return typeHasEditorRef(type.DeclaringType);
        }
        if (type.IsByRef || type.IsArray)
        {
            return typeHasEditorRef(type.GetElementType());
        }
        if (type.IsGenericType)
        {
            foreach (var typeArg in type.GetGenericArguments())
            {
                if (typeHasEditorRef(typeArg))
                {
                    return true;
                }
            }
        }
        return false;
    }

    static bool delegateHasEditorRef(Type delegateType)
    {
        if (typeHasEditorRef(delegateType)) return true;
        var method = delegateType.GetMethod("Invoke");
        if (method == null)
        {
            return false;
        }
        if (typeHasEditorRef(method.ReturnType)) return true;
        return method.GetParameters().Any(pinfo => typeHasEditorRef(pinfo.ParameterType));
    }

    // 配置某Assembly下所有涉及到的delegate到CSharpCallLua下，Hotfix下拿不准那些delegate需要适配到lua function可以这么配置
    [CSharpCallLua]
    static IEnumerable<Type> AllDelegate
    {
        get
        {
            BindingFlags flag = BindingFlags.DeclaredOnly | BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public;
            List<Type> allTypes = new List<Type>();
            var allAssemblys = new Assembly[]
            {
                Assembly.Load("Assembly-CSharp")
            };
            foreach (var t in (from assembly in allAssemblys from type in assembly.GetTypes() select type))
            {
                var p = t;
                while (p != null)
                {
                    allTypes.Add(p);
                    p = p.BaseType;
                }
            }
            allTypes = allTypes.Distinct().ToList();
            var allMethods = from type in allTypes
                             from method in type.GetMethods(flag)
                             select method;
            var returnTypes = from method in allMethods
                              select method.ReturnType;
            var paramTypes = allMethods.SelectMany(m => m.GetParameters()).Select(pinfo => pinfo.ParameterType.IsByRef ? pinfo.ParameterType.GetElementType() : pinfo.ParameterType);
            var fieldTypes = from type in allTypes
                             from field in type.GetFields(flag)
                             select field.FieldType;
            return (returnTypes.Concat(paramTypes).Concat(fieldTypes))
                .Where(t => t.BaseType == typeof(MulticastDelegate) && !hasGenericParameter(t) && !delegateHasEditorRef(t))
                .Distinct();
        }
    }
    //--------------end 热补丁自动化配置-------------------------
    static bool isInDelegateInBlackList(Type t)
    {
        foreach (var tt in DelegatesGensBridgeBlackList)
        {
            if (tt == t) return true;
        }
        return false;
    }
    public static List<Type> DelegatesGensBridgeBlackList = new List<Type>() {
       typeof(CanvasRenderer.OnRequestRebuild),
    };

    //黑名单
    [BlackList]
    public static List<List<string>> BlackList = new List<List<string>>()  {
        //new List<string>(){ typeof(Febucci.UI.Core.BehaviorBase).FullName, "EDITOR_RecordModifier"},
        //new List<string>(){ typeof(Febucci.UI.Core.BehaviorBase).FullName, "EDITOR_ApplyModifiers"},

        new List<string>(){ "UnityEngine.ParticleSystemRenderer", "supportsMeshInstancing"},

        new List<string>(){"UnityEngine.UI.Text", "OnRebuildRequested"},
        new List<string>(){"UnityEngine.UI.Graphic", "OnRebuildRequested"},
        new List<string>(){"UnityEngine.AnimatorControllerParameter", "name"},
        new List<string>(){"UnityEngine.AudioSettings", "GetSpatializerPluginNames"},
        new List<string>(){"UnityEngine.AudioSettings", "SetSpatializerPluginName", "System.String"},
        new List<string>(){"UnityEngine.DrivenRectTransformTracker", "StopRecordingUndo"},
        new List<string>(){"UnityEngine.DrivenRectTransformTracker", "StartRecordingUndo"},
        new List<string>(){"UnityEngine.Caching", "SetNoBackupFlag", "UnityEngine.CachedAssetBundle"},
        new List<string>(){"UnityEngine.Caching", "ResetNoBackupFlag", "UnityEngine.CachedAssetBundle"},
        new List<string>(){"UnityEngine.Caching", "SetNoBackupFlag", "System.String", "UnityEngine.Hash128"},
        new List<string>(){"UnityEngine.Caching", "ResetNoBackupFlag", "System.String", "UnityEngine.Hash128"},
        new List<string>(){"UnityEngine.Input", "IsJoystickPreconfigured", "System.String"},
        new List<string>(){"UnityEngine.LightProbeGroup", "dering"},
        new List<string>(){"UnityEngine.LightProbeGroup", "probePositions"},
        new List<string>(){"UnityEngine.Light", "SetLightDirty"},
        new List<string>(){"UnityEngine.Light", "shadowRadius"},
        new List<string>(){"UnityEngine.Light", "shadowAngle"},
        new List<string>(){"UnityEngine.ParticleSystemForceField", "FindAll"},
        new List<string>(){"UnityEngine.QualitySettings", "streamingMipmapsRenderersPerFrame"},
        new List<string>(){"UnityEngine.Texture", "imageContentsHash"},
        new List<string>(){ "UnityEngine.MeshRenderer", "scaleInLightmap"},
        new List<string>(){ "UnityEngine.MeshRenderer", "receiveGI"},
        new List<string>(){ "UnityEngine.MeshRenderer", "stitchLightmapSeams"},
        new List<string>(){ "UnityEngine.UI.DefaultControls", "factory"},


        new List<string>(){ "UnityEngine.AudioSettings", "GetSpatializerPluginNames"},
        new List<string>(){ "UnityEngine.AudioSettings", "SetSpatializerPluginName"},
        new List<string>(){ "UnityEngine.Caching", "SetNoBackupFlag"},
        new List<string>(){ "UnityEngine.DrivenRectTransformTracker", "StopRecordingUndo"},
        new List<string>(){ "UnityEngine.DrivenRectTransformTracker", "StartRecordingUndo"},
        new List<string>(){ "UnityEngine.Input", "IsJoystickPreconfigured"},
        new List<string>(){ "UnityEngine.LightProbeGroup", "dering"},
        new List<string>(){ "UnityEngine.LightProbeGroup", "SetLightDirty"},
        new List<string>(){ "UnityEngine.LightProbeGroup", "shadowRadius"},
        new List<string>(){ "UnityEngine.ParticleSystemForceField", "FindAll"},
        new List<string>(){ "UnityEngine.UI.Text", "OnRebuildRequested"},
        new List<string>(){ "UnityEngine.UI.Graphic", "OnRebuildRequested"},
        new List<string>(){ "UnityEngine.Texture", "imageContentsHash"},
        new List<string>(){ "UnityEngine.Light", "shadowRadius"},
        new List<string>(){ "UnityEngine.Light", "shadowAngle"},
        new List<string>(){ "UnityEngine.QualitySettings", "streamingMipmapsRenderersPerFrame"},

        new List<string>(){"System.Xml.XmlNodeList", "ItemOf"},
        new List<string>(){"UnityEngine.WWW", "movie"},
#if UNITY_WEBGL
        new List<string>(){"UnityEngine.WWW", "threadPriority"},
#endif
        new List<string>(){"UnityEngine.Texture2D", "alphaIsTransparency"},
        new List<string>(){"UnityEngine.Security", "GetChainOfTrustValue"},
        new List<string>(){"UnityEngine.CanvasRenderer", "onRequestRebuild"},
        new List<string>(){"UnityEngine.Light", "areaSize"},
        new List<string>(){"UnityEngine.Light", "lightmapBakeType"},
        new List<string>(){"UnityEngine.WWW", "MovieTexture"},
        new List<string>(){"UnityEngine.WWW", "GetMovieTexture"},
        new List<string>(){"UnityEngine.AnimatorOverrideController", "PerformOverrideClipListCleanup"},
#if !UNITY_WEBPLAYER
        new List<string>(){"UnityEngine.Application", "ExternalEval"},
#endif
        new List<string>(){"UnityEngine.GameObject", "networkView"}, //4.6.2 not support
        new List<string>(){"UnityEngine.Component", "networkView"},  //4.6.2 not support
        new List<string>(){"System.IO.FileInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
        new List<string>(){"System.IO.FileInfo", "SetAccessControl", "System.Security.AccessControl.FileSecurity"},
        new List<string>(){"System.IO.DirectoryInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections"},
        new List<string>(){"System.IO.DirectoryInfo", "SetAccessControl", "System.Security.AccessControl.DirectorySecurity"},
        new List<string>(){"System.IO.DirectoryInfo", "CreateSubdirectory", "System.String", "System.Security.AccessControl.DirectorySecurity"},
        new List<string>(){"System.IO.DirectoryInfo", "Create", "System.Security.AccessControl.DirectorySecurity"},
        new List<string>(){"UnityEngine.MonoBehaviour", "runInEditMode"},


    };

#if UNITY_2018_1_OR_NEWER
    [BlackList]
    public static Func<MemberInfo, bool> MethodFilter = (memberInfo) => {
        if (memberInfo.DeclaringType.IsGenericType && memberInfo.DeclaringType.GetGenericTypeDefinition() == typeof(Dictionary<,>))
        {
            if (memberInfo.MemberType == MemberTypes.Constructor)
            {
                ConstructorInfo constructorInfo = memberInfo as ConstructorInfo;
                var parameterInfos = constructorInfo.GetParameters();
                if (parameterInfos.Length > 0)
                {
                    if (typeof(System.Collections.IEnumerable).IsAssignableFrom(parameterInfos[0].ParameterType))
                    {
                        return true;
                    }
                }
            }
            else if (memberInfo.MemberType == MemberTypes.Method)
            {
                var methodInfo = memberInfo as MethodInfo;
                if (methodInfo.Name == "TryAdd" || methodInfo.Name == "Remove" && methodInfo.GetParameters().Length == 2)
                {
                    return true;
                }
            }
        }
        return false;
    };
#endif


    [LuaCallCSharp]
    public static List<Type> others = new List<Type>()
    {
        typeof(DG.Tweening.AutoPlay),
        typeof(DG.Tweening.AxisConstraint),
        typeof(DG.Tweening.Ease),
        typeof(DG.Tweening.LogBehaviour),
        typeof(DG.Tweening.LoopType),
        typeof(DG.Tweening.PathMode),
        typeof(DG.Tweening.PathType),
        typeof(DG.Tweening.RotateMode),
        typeof(DG.Tweening.ScrambleMode),
        typeof(DG.Tweening.TweenType),
        typeof(DG.Tweening.UpdateType),

        typeof(DG.Tweening.DOTween),
        typeof(DG.Tweening.DOVirtual),
        typeof(DG.Tweening.EaseFactory),
        typeof(DG.Tweening.Tweener),
        typeof(DG.Tweening.Tween),
        typeof(DG.Tweening.Sequence),
        typeof(DG.Tweening.TweenParams),
        typeof(DG.Tweening.Core.ABSSequentiable),
        typeof(DG.Tweening.Core.ABSAnimationComponent),

        typeof(DG.Tweening.Core.TweenerCore<Vector3, Vector3, DG.Tweening.Plugins.Options.VectorOptions>),
        typeof(DG.Tweening.Core.TweenerCore<Vector3, Vector3[], DG.Tweening.Plugins.Options.Vector3ArrayOptions>),
        typeof(DG.Tweening.Core.TweenerCore<Quaternion, Vector3, DG.Tweening.Plugins.Options.QuaternionOptions>),


        typeof(DG.Tweening.TweenExtensions),
        typeof(DG.Tweening.TweenSettingsExtensions),
        typeof(DG.Tweening.ShortcutExtensions),
       
        //dotween pro 的功能
        typeof(DG.Tweening.DOTweenPath),
        typeof(DG.Tweening.DOTweenVisualManager),
        typeof(DG.Tweening.DOTweenAnimation),
        typeof(DG.Tweening.DOTweenAnimation.AnimationType),
        typeof(DG.Tweening.DOTweenAnimation.TargetType),


        typeof(DDOLSingleton<ObjectPoolManager>),

        typeof(BaseLuaBehaviour<ColliderLuaBehaviour>),
        typeof(BaseLuaBehaviour<DestroyLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIClickLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIOnBeginDragLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIOnEndDragLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIPointerDownLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIPointerEnterLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIPointerExitLuaBehaviour>),
        typeof(BaseLuaBehaviour<UGUIPointerUpLuaBehaviour>),
        typeof(BaseLuaBehaviour<UpdateLuaBehaviour>),

        typeof(UGUIOnBeginDragLuaBehaviour),
        typeof(UGUIOnDragLuaBehaviour),
        typeof(UGUIOnEndDragLuaBehaviour),
        typeof(UGUIPointerDownLuaBehaviour),
        typeof(UGUIPointerEnterLuaBehaviour),
        typeof(UGUIPointerExitLuaBehaviour),
        typeof(UGUIPointerUpLuaBehaviour),


        typeof(List<KeyCode>),
        typeof(List<object>),
        typeof(List<string>),
        typeof(List<TMPro.TMP_Dropdown.OptionData>),

        typeof(Dictionary<string, object>),

        //typeof(UnityEngine.EventSystems.PointerEventData),
        typeof(UnityEngine.EventSystems.PointerEventData.InputButton),
        typeof(UnityEngine.EventSystems.PointerEventData.FramePressState),
        typeof(UnityEngine.SceneManagement.LoadSceneMode),
        typeof(ScreenOrientation),
        typeof(Camera.FieldOfViewAxis),
        typeof(Camera.GateFitMode),
        typeof(Camera.StereoscopicEye),
        typeof(Camera.MonoOrStereoscopicEye),
        typeof(LogType),

        typeof(UnityEngine.UI.Selectable.Transition),
        typeof(UnityEngine.UI.Slider.Direction),
        typeof(UnityEngine.UI.Toggle.ToggleTransition),
        typeof(UnityEngine.UI.Image.Type),
        typeof(UnityEngine.UI.Image.FillMethod),
        typeof(UnityEngine.UI.Image.Origin180),
        typeof(UnityEngine.UI.Image.Origin90),
        typeof(UnityEngine.UI.Image.Origin360),
        typeof(UnityEngine.UI.Image.OriginHorizontal),
        typeof(UnityEngine.UI.Image.OriginVertical),
        typeof(UnityEngine.UI.CanvasScaler.ScaleMode),
        typeof(UnityEngine.UI.CanvasScaler.ScreenMatchMode),
        typeof(UnityEngine.UI.CanvasScaler.Unit),
        typeof(UnityEngine.UI.ScrollRect.MovementType),
        typeof(UnityEngine.UI.ScrollRect.ScrollbarVisibility),
        typeof(UnityEngine.UI.ScrollRect.ScrollRectEvent),
        typeof(UnityEngine.UI.GridLayoutGroup.Axis),
        typeof(UnityEngine.UI.GridLayoutGroup.Constraint),
        typeof(UnityEngine.UI.GridLayoutGroup.Corner),
        typeof(UnityEngine.UI.InputField.CharacterValidation),
        typeof(UnityEngine.UI.InputField.ContentType),
        typeof(UnityEngine.UI.InputField.InputType),
        typeof(UnityEngine.UI.InputField.LineType),
        typeof(UnityEngine.UI.Selectable.Transition),
        typeof(UnityEngine.UI.GraphicRaycaster.BlockingObjects),
        typeof(UnityEngine.UI.ContentSizeFitter.FitMode),
        typeof(UnityEngine.EventSystems.EventTriggerType),
        typeof(UnityEngine.Networking.UnityWebRequest),
        typeof(UnityEngine.Networking.UnityWebRequestAsyncOperation),
        typeof(UnityEngine.Networking.DownloadHandlerBuffer),
        typeof(UnityEngine.Networking.DownloadHandler),
        typeof(UnityEngine.Texture2D.EXRFlags),
        typeof(UnityEngine.ScreenCapture.StereoScreenCaptureMode),
        typeof(UnityEngine.Video.VideoClip),

        typeof(TMPro.TMP_Text),
        typeof(TMPro.TMP_InputField),
        typeof(TMPro.TMP_InputField.CharacterValidation),
        typeof(TMPro.TMP_InputField.ContentType),
        typeof(TMPro.TMP_InputField.InputType),
        typeof(TMPro.TMP_InputField.LineType),
        typeof(TMPro.TMP_InputField.Transition),
        typeof(TMPro.TMP_Dropdown),
        typeof(TMPro.TMP_Dropdown.OptionData),
        typeof(TMPro.TMP_Dropdown.OptionDataList),
        typeof(TMPro.TMP_Dropdown.Transition),


        typeof(Space),
        typeof(RectTransform.Edge),
        typeof(RectTransform.Axis),

        typeof(RuntimePlatform),
        typeof(KeyCode),
        typeof(NetworkReachability),

        typeof(DateTime),
        typeof(TimeSpan),
        typeof(System.IO.MemoryStream),
        typeof(System.IO.BinaryReader),
        typeof(System.IO.SeekOrigin),
        typeof(System.IO.File),
        typeof(System.IO.Directory),
        typeof(System.IO.Path),
        typeof(System.IO.FileInfo),
        typeof(System.IO.DirectoryInfo),
        typeof(System.Diagnostics.Stopwatch),
        typeof(System.ValueType),
        typeof(System.DateTimeKind),
        typeof(object),

        typeof(Newtonsoft.Json.Linq.JArray),

        //typeof(OpenInstall),


        typeof(Enum),
        typeof(UGUIPointerUpLuaBehaviour),
        typeof(BaseLuaBehaviour<UGUIPointerUpLuaBehaviour>),

        // TextMeshPro
        typeof(TMPro.TextMeshProUGUI),
        typeof(TMPro.TextMeshPro),
        //// Text Animation
        //typeof(Febucci.UI.TextAnimator),
        //typeof(Febucci.UI.TextAnimatorPlayer),
        //typeof(Febucci.UI.TAnimTags),
        //typeof(Febucci.UI.AnimationText),

        // OSAScrollView
        typeof(Com.TheFallenGames.OSA.Core.BaseParams),
        typeof(Com.TheFallenGames.OSA.Core.BaseParams.OrientationEnum),
        typeof(Com.TheFallenGames.OSA.Core.BaseParams.Effects),
        typeof(Com.TheFallenGames.OSA.Core.BaseParams.NavigationParams),
        typeof(Com.TheFallenGames.OSA.Core.BaseParams.Optimization),
        typeof(Com.TheFallenGames.OSA.CustomParams.BaseParamsWithPrefab),
        typeof(Com.TheFallenGames.OSA.Core.ItemCountChangeMode),
        typeof(Com.TheFallenGames.OSA.Core.BaseParams.ContentGravity),
        typeof(Com.TheFallenGames.OSA.Core.OSA<OSAHelper.Param, OSAHelper.ItemViewHolder>),
        typeof(Com.TheFallenGames.OSA.Core.BaseItemViewsHolder),
        typeof(Com.TheFallenGames.OSA.Core.AbstractViewsHolder),
        typeof(OSAHelper.OSAScrollView),
        typeof(OSAHelper.Param),
        typeof(OSAHelper.ItemViewHolder),
        typeof(TextAnchor),

        //spine
        typeof(Spine.AnimationState),
        typeof(Spine.TrackEntry),

        typeof(ICSharpCode.SharpZipLib.Zip.FastZip),
        typeof(ICSharpCode.SharpZipLib.Zip.FastZip.Overwrite),

        //typeof(QL.CharMask),

        //typeof(PageTurning),
    };




    static List<Type> LuaCallCSharpAndCSharpCallLua = new List<Type>() {
        typeof(System.Collections.IEnumerator),
        //typeof(NetBase.NetComponent),

        typeof(Action<object>),
        typeof(Action<object[]>),
        typeof(Action<string>),
        typeof(Action<bool>),
        typeof(Action<UnityEngine.Object>),
        typeof(Action<List<object>>),
        typeof(Action<List<string>>),
        typeof(Action<LuaTable, float>),
        typeof(Action<LuaTable, bool, int, string>),
        typeof(Action<int, bool>),
        typeof(Func<string, bool, TextAsset>),
        typeof(Func<string, bool, string>),
        typeof(Func<string, string>),
        typeof(Func<object, object>),
        typeof(Func<object, bool>),

        typeof(UnityEngine.Events.UnityEvent<bool>),
        typeof(UnityEngine.Events.UnityEvent),
        typeof(UnityEngine.Events.UnityEvent<float>),
        typeof(UnityEngine.Events.UnityEvent<string>),
        typeof(UnityEngine.Events.UnityEvent<object>),
        typeof(UnityEngine.Events.UnityEvent<UnityEngine.Object>),
        typeof(UnityEngine.Events.UnityEvent<int>),
        typeof(UnityEngine.Events.UnityEvent<Vector2>),
        typeof(UnityEngine.Events.UnityEvent<UnityEngine.EventSystems.BaseEventData>),

        typeof(TMPro.TMP_InputField.OnChangeEvent),
        typeof(TMPro.TMP_InputField.OnValidateInput),
        typeof(TMPro.TMP_InputField.SelectionEvent),
        typeof(TMPro.TMP_InputField.SubmitEvent),
        typeof(TMPro.TMP_InputField.TextSelectionEvent),
        typeof(TMPro.TMP_InputField.TouchScreenKeyboardEvent),
        typeof(TMPro.TMP_Dropdown.DropdownEvent),

        typeof(CustomObjectEvent),
        typeof(CustomUnityObjectEvent),
        typeof(CustomUnityBoolEvent),
        typeof(CustomUnityStringEvent),
        typeof(CustomUnityIntEvent),
        typeof(CustomUnityFloatEvent),



        typeof(DG.Tweening.TweenCallback),
        typeof(DG.Tweening.TweenCallback<>),
        typeof(DG.Tweening.TweenCallback<object>),

        typeof(UnityEngine.UI.Slider.SliderEvent),
        typeof(UnityEngine.Events.UnityEventBase),


        //typeof(OpenInstallDelegate),

        typeof(Action<UnityEngine.EventSystems.PointerEventData>),
        typeof(Action<LuaTable, UnityEngine.EventSystems.PointerEventData>),
        typeof(Action<LuaTable, Collider>),
        typeof(Action<LuaTable>),
        typeof(Action<Message>),
    };

    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp_ = LuaCallCSharpAndCSharpCallLua;
    [CSharpCallLua]
    public static List<Type> CSharpCallLua_ = LuaCallCSharpAndCSharpCallLua;
}
