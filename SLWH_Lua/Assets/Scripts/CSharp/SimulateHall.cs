using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimulateHall : MonoBehaviour
{
    public string gameName = "GameFQZS";
    public bool runWithoutNet = false;

    private void Awake()
    {

    }
    private void Start()
    {
        DontDestroyOnLoad(gameObject);

        if (runWithoutNet) {
            gameObject.AddComponent<XLuaMain>().Init(null);
            return;
        }

        SysDefines.Platform = 2;
        ModuleManager.Instance.RegisterAllModules();
        ModuleManager.Instance.Get<LoginModule>().gameName = gameName;
        ModuleManager.Instance.Get<LoginModule>().SendNetConnect(1);
    }
}
