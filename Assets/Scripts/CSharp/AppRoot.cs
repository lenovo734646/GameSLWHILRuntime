using System;
using System.Collections;
using System.Linq;
using UnityEngine;

public class AppRoot : MonoBehaviour
{
    [SerializeField]
    private UpdatePlatform _updatePlatform = UpdatePlatform.CurrentPlatform;
    [SerializeField]
    private AssetSourceType _gameAssetSource = AssetSourceType.LocalAssets;

    private static AppRoot _instance;
    public static AppRoot Get()
    {
        Debug.Log("==============AppRoot Get.....");
        return _instance;
    }
    //
    private static string _assetUrl = string.Empty;
    private static string _downLoadPath = string.Empty;

    /// <summary>
    /// AssetBundle 资源加载模块
    /// </summary>
    //public ForRebuild.Loader assetLoader;
    public bool IsEditorAssets { get { return _gameAssetSource == AssetSourceType.LocalAssets; } }

    public bool IsRunInHall() {
        return false;   
    }

    public void HotUpdate(string version)
    {
        InitContext();
        if (!IsEditorAssets)
            StartUpdate(version);
        else
            OnABUpdateComplete();
    }

    public void AddHotUpdateListener(Action<ProgressType, int, int> onProgress,
        Action<int, string> onError, Action onComplete)
    {
        this.onProgress = onProgress;
        this.onError = onError;
        this.onComplete = onComplete;
    }

    private void Start()
    {
        Debug.Log("==================AppRoot Start....");
        if (!ReferenceEquals(Get(), null))
        {
            GetComponent<XLuaMain>().enabled = false;
            enabled = false;
            return;
        }
        //assetLoader = new ForRebuild.Loader(IsEditorAssets);
        _instance = this;

        //InitContext();
    }

    public void Init()
    {
        InitContext();
    }

    private void InitContext()
    {
        //Debug.Log("AppRoot InitContext....");

        Context.Game.Config = new AssetConfig();
        Context.Game.Config.SetAssetType(_updatePlatform, _gameAssetSource);
        Context.Game.Config.SetPathParam(_assetUrl + "Game/", "game", true);
        Context.Game.Loader = new AssetLoader(Context.Game);
        Context.Game.BundleMgr = new BundleManager(Context.Game, Context.Game.Config.IsUpdate);
        if (!IsEditorAssets)
            Context.Game.BundleMgr.Init();
        Context.Game.LuaClient = GetComponent<XLuaMain>();
        Context.Game.LuaClient.Init(Context.Game);
    }

    private void StartUpdate(string version)
    {
        Debug.Log("AppRoot StartUpdate...");
        var updater = gameObject.AddComponent<AssetUpdater>();
        updater.updateComplete = OnABUpdateComplete;
        updater.onProgress = OnProgress;
        updater.onError = OnError;
        updater.StartUpdate(_assetUrl, UtilityEnv.File_List_Name, _downLoadPath, version);
    }

    private Action<ProgressType, int, int> onProgress;
    private Action<int, string> onError;
    private Action onComplete;
    private void OnABUpdateComplete()
    {
        if (!Context.Hall.Config.IsEditorAssets)
            Context.Hall.BundleMgr.Init();
        Context.Hall.LuaClient.Init(Context.Hall);

        onComplete?.Invoke();
    }

    // Cunstom Loader
    //private byte[] LuaFileLoader(ref string filePath)
    //{
    //    var path = UtilityEnv.StringConcat("Assets/Scripts/Lua/", filePath.Replace('.', '/'), ".lua");
    //    if (!IsEditorAssets)
    //    {
    //        path = UtilityEnv.StringConcat(UtilityEnv.Lua_Output_Path, "/", filePath.Replace(".", "/"), ".lua.bytes");
    //        return new LuaBundleLoader(AssetConfig.Lua_Output_Path, context).LoadFile
    //    }
    //    Debug.Log("LuaFileLoader File = " + path);
    //    return assetLoader.LoadTextAsset(path);
    //}

    private void OnProgress(ProgressType type, int loaded, int total)
    {
        onProgress?.Invoke(type, loaded, total);
    }

    private void OnError(int errorCode, string error)
    {
        onError?.Invoke(errorCode, error);
    }

    /// <summary>
    /// 根据 _updatePlatform 获取当前平台的名字
    /// </summary>
    /// <returns></returns>
    public string GetPlatform()
    {
#if UNITY_EDITOR
        if (_updatePlatform == UpdatePlatform.CurrentPlatform)
        {
#if UNITY_ANDROID
            return "Android";
#elif UNITY_IOS
            return "iOS";
#else
            return "Win";
#endif
        }
        else if (_updatePlatform == UpdatePlatform.Android)
        {
            return "Android";
        }
        else if (_updatePlatform == UpdatePlatform.iOS)
        {
            return "iOS";
        }
        else
        {
            return "Win";
        }
#elif UNITY_ANDROID
        return "Android";
#elif UNITY_IOS
        return "iOS";
#else
        return "Win";
#endif
    }
}

public enum AssetSourceType
{
    LocalAssets,
    UpdateAssetBundle,
}

public enum UpdatePlatform
{
    CurrentPlatform,
    Android,
    iOS,
    Win,
}

