using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendMessageToLuaRunTime : MonoBehaviour
{
    public void Send(string param) {
        var go = GameObject.Find("LuaRuntime");
        if (go) {
            go.SendMessage("DoString", param, SendMessageOptions.RequireReceiver);
        } else {
            Debug.LogError("Can not find LuaRuntime");
        }
    }
}
