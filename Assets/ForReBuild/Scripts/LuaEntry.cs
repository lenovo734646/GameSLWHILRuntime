
//#define TEST_CODE

//using ICSharpCode.SharpZipLib.Zip;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using XLua;



public class LuaEntry : MonoBehaviour
{
    public bool test = false;
    public bool useEncrypted = false;
    public bool useUpdateScript = true;
    public string testEntry = "test";
    public string entry = "Entry";
    public string gameName = "";
    public float GCInterval = 1;    //second
    private float lastGCTime = 0;

    public LuaEnv luaEnv;
    private Action _luaUpdate;
    private Action _luaFixedUpdate;
    private Action _luaLateUpdate;
    private UnityAction<Scene, LoadSceneMode> _luaSceneLoaded;
    private UnityAction<Scene> _luaSceneUnloaded;
    private UnityAction<Scene, Scene> _luaActiveSceneChanged;

    private LuaFileLoaderEx luaFileLoaderEx;

    private Action<object,object> _OnNetData;

    public static LuaEntry Instance { get; private set; }


    void Awake()
    {
        Instance = this;
        if (test) {
            entry = testEntry;
        }
        print("buil ver = 1");
        DontDestroyOnLoad(gameObject);
        //DebugCheckThread.Init();
        luaEnv = new LuaEnv();
#if UNITY_EDITOR
        luaEnv.translator.debugDelegateBridgeRelease = true;
#endif

        luaEnv.AddBuildin("pb", XLua.LuaDLL.Lua.LoadPb);
        luaEnv.Global.Set("gLuaEntryGameObject", gameObject);
        luaEnv.Global.Set("gLuaEntryCom", this);
        var rect = this.gameObject.GetComponent("RectTransform");
    }

    IEnumerator Start()
    {
        yield return null;
#if (!UNITY_EDITOR && UNITY_ANDROID) || TEST_CODE
        //StartCoroutine(cReadZip());
#elif UNITY_EDITOR || UNITY_STANDALONE
        Init(Application.streamingAssetsPath);
#else
        Init(Application.persistentDataPath);
#endif
    }

    

    void Init(string path)
    {
#if DEV_VER
        DoString("DEV_VER=true");
#endif
#if UNITY_EDITOR
        print("luapath=" + path);
#else
        DoString("_NDEBUG=true");
        useUpdateScript = true;
        useEncrypted = true;
#endif
#if UNITY_EDITOR
        DoString("UNITY_EDITOR=true");
#endif
        var fileLoader = luaFileLoaderEx = new LuaFileLoaderEx(Application.dataPath + "/Scripts/Lua/");
        //fileLoader.useEncrypted = useEncrypted;
        luaEnv.AddLoader(fileLoader.LoadFile);

        if (useEncrypted) {
            fileLoader._searchPath = Application.streamingAssetsPath + "/LuaEncrypted/";
        }

        print("searchPath:"+ fileLoader._searchPath);

        if (useUpdateScript && useEncrypted) {
            DoString("USEUPDATESCIRPT=true");
        }
        // DoString("g_Env = {showDebugErr=true}");
        //var g_Env = GLuaSharedHelper.g_Env = luaEnv.Global.Get<LuaTable>("g_Env");
        //g_Env.Set("luaFileLoader", fileLoader);

        DoString($"require '{entry}'");

        

        luaEnv.Global.Get("Update", out _luaUpdate);
        luaEnv.Global.Get("FixedUpdate", out _luaFixedUpdate);
        luaEnv.Global.Get("LateUpdate", out _luaLateUpdate);
        luaEnv.Global.Get("OnSceneLoaded", out _luaSceneLoaded);
        luaEnv.Global.Get("OnSceneUnloaded", out _luaSceneUnloaded);
        luaEnv.Global.Get("OnActiveSceneChanged", out _luaActiveSceneChanged);
        luaEnv.Global.Get("OnReceiveNetDataPack", out _OnNetData);

        SceneManager.sceneLoaded += OnSceneLoaded;
        SceneManager.sceneUnloaded += OnSceneUnloaded;
        SceneManager.activeSceneChanged += OnActiveSceneChanged;

        //if (MessageCenter.Instance)
        //    MessageCenter.Instance.AddListener(MsgType.NET_RECEIVE_DATA, OnReceiveNetData);



        // Tester.Test();
    }

    private void OnReceiveNetData(Message msg)
    {
        var netDataPack = msg.Content as SubGameNet.NetHelper.NetDataPack;
        _OnNetData?.Invoke(netDataPack, netDataPack.packName);
    }

    public void DoString(string str)
    {
        luaEnv?.DoString(str, "DoString");
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        if (_luaSceneLoaded != null)
            _luaSceneLoaded(scene, mode);
    }

    private void OnSceneUnloaded(Scene scene)
    {
        if (_luaSceneUnloaded != null)
            _luaSceneUnloaded(scene);
    }

    private void OnActiveSceneChanged(Scene previousScene, Scene newScene)
    {
        if (_luaActiveSceneChanged != null)
            _luaActiveSceneChanged(previousScene, newScene);
    }




    private void Update()
    {
        if (luaEnv == null)
            return;

        _luaUpdate?.Invoke();

        if (Time.time - lastGCTime > GCInterval)
        {
            luaEnv.Tick();
            lastGCTime = Time.time;
        }
    }

    private void FixedUpdate()
    {
        if (luaEnv == null)
            return;

        _luaFixedUpdate?.Invoke();
    }

    private void LateUpdate()
    {
        if (luaEnv == null)
            return;

        _luaLateUpdate?.Invoke();
    }

    private void OnDestroy() {
        StopAllCoroutines();
        luaEnv.Global.Get<LuaFunction>("OnCloseSubGame").Call();

        Instance = null;

        _luaUpdate = null;
        _luaFixedUpdate = null;
        _luaLateUpdate = null;

        _luaSceneLoaded = null;
        _luaSceneUnloaded = null;
        _luaActiveSceneChanged = null;
        _OnNetData = null;

        SceneManager.sceneLoaded -= OnSceneLoaded;
        SceneManager.sceneUnloaded -= OnSceneUnloaded;
        SceneManager.activeSceneChanged -= OnActiveSceneChanged;

        luaFileLoaderEx.Reset();

        luaEnv.Dispose();
    }
}
