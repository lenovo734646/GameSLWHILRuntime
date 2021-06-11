using System;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using XLua;
using XLua.LuaDLL;
using static SubGameNet.NetHelper;

public class XLuaMain : MonoBehaviour
{


    internal const float GCInterval = 1;    //second
    private float lastGCTime = 0;
    public LuaEnv luaEnv;

    [SerializeField]
    private string luaBoot = "Main";
    [SerializeField]
    private string luaAssetPath = "Assets/Scripts/Lua/";


    private bool _inited = false;

    public bool InitOnAwake = false;

    private Action _luaUpdate;
    private Action _luaFixedUpdate;
    private Action _luaLateUpdate;
    private UnityAction<Scene, LoadSceneMode> _luaSceneLoaded;
    private UnityAction<Scene> _luaSceneUnloaded;
    private UnityAction<Scene, Scene> _luaActiveSceneChanged;
    private Action<NetDataPack,string> _luaReceiveNetData;
    private Action<Message> _luaReceiveCSharpData;


    private void Awake()
    {
        //Debug.Log("XLuaMain Awake....InitOnAwake = "+ InitOnAwake);
        if (InitOnAwake)
            Init(null);
    }

    public void SetLuaParam(string boot, string assetPath)
    {
        luaBoot = boot;
        luaAssetPath = assetPath;
    }

    public void Init(Context context)
    {
        Debug.Log("XLuaMain Init....");
        if (_inited)
            return;

        _inited = true;
        
        luaEnv = new LuaEnv();

        var fileLoader = new LuaFileLoaderEx(Application.dataPath + "/Scripts/Lua/");
        luaEnv.AddLoader(fileLoader.LoadFile);


        luaEnv.AddBuildin("pb", Lua.LoadPb);

#if LOCAL_DEBUG
        DoString("LOCAL_DEBUG=true");
#endif
#if HALL
        DoString("HALL=true");
#endif
#if UNITY_EDITOR
        DoString("UNITY_EDITOR=true");
        DoString("SUBGAME_EDITOR=true");
#endif
        luaEnv.Global.Set("gLuaEntryCom", this);
        if(context==null)
            luaEnv.DoString("require 'Test'", "XLuaMain");
        else
            luaEnv.DoString("require '" + luaBoot + "'", "XLuaMain");



        luaEnv.Global.Get("Update", out _luaUpdate);
        luaEnv.Global.Get("FixedUpdate", out _luaFixedUpdate);
        luaEnv.Global.Get("LateUpdate", out _luaLateUpdate);
        luaEnv.Global.Get("OnSceneLoaded", out _luaSceneLoaded);
        luaEnv.Global.Get("OnSceneUnloaded", out _luaSceneUnloaded);
        luaEnv.Global.Get("OnActiveSceneChanged", out _luaActiveSceneChanged);
        luaEnv.Global.Get("OnReceiveNetDataPack", out _luaReceiveNetData);
        luaEnv.Global.Get("OnReceiveCSharpData", out _luaReceiveCSharpData);


        SceneManager.sceneLoaded += OnSceneLoaded;
        SceneManager.sceneUnloaded += OnSceneUnloaded;
        SceneManager.activeSceneChanged += OnActiveSceneChanged;

        MessageCenter.Instance.AddListener(MsgType.NET_RECEIVE_DATA, OnReceiveNetData);
        MessageCenter.Instance.AddListener(MsgType.CSHARP_RECEIVE_DATA, OnReceiveCSharpData);
    }

    void DoString(string str) {
        luaEnv?.DoString(str, "SubGame");
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

    private void OnReceiveNetData(Message msg)
    {
        if (_luaReceiveNetData != null)
        {
            var pack = msg.Content as NetDataPack;
            _luaReceiveNetData.Invoke(pack, pack.packName);
        }
    }

    private void OnReceiveCSharpData(Message msg)
    {
        if (_luaReceiveCSharpData != null)
        {
            _luaReceiveCSharpData.Invoke(msg);
        }
    }

    private void Update()
    {
        if (luaEnv == null)
            return;

        if (_luaUpdate != null)
            _luaUpdate();

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

        if (_luaFixedUpdate != null)
            _luaFixedUpdate();
    }

    private void LateUpdate()
    {
        if (luaEnv == null)
            return;

        if (_luaLateUpdate != null)
            _luaLateUpdate();
    }

    public void ClearSceneDelegate()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
        SceneManager.sceneUnloaded -= OnSceneUnloaded;
        SceneManager.activeSceneChanged -= OnActiveSceneChanged;
    }

    public void Destroy()
    {
        MessageCenter.Instance.RemoveListener(MsgType.NET_RECEIVE_DATA, OnReceiveNetData);

        //luaBoot = null;
        //luaAssetPath = null;

        _luaUpdate = null;
        _luaFixedUpdate = null;
        _luaLateUpdate = null;
        _luaSceneLoaded = null;
        _luaSceneUnloaded = null;
        _luaActiveSceneChanged = null;
        _luaReceiveNetData = null;

        if (luaEnv != null)
        {
            luaEnv.Dispose();
            luaEnv = null;
        }
        
        _inited = false;
    }
}
