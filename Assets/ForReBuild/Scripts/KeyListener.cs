using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using XLua;
public class KeyListener : MonoBehaviour {
    public CustomObjectEvent OnKeyDown;
    public CustomObjectEvent OnKeyUp;
    public CustomObjectEvent OnKey;
    public CustomUnityIntEvent OnMouseButtonDown;
    public CustomUnityIntEvent OnMouseButtonUp;
    public CustomUnityIntEvent OnMouseButton;

    public List<KeyCode> keyDownList = new List<KeyCode>();
    public List<KeyCode> keyUpList = new List<KeyCode>();
    public List<KeyCode> keyList = new List<KeyCode>();
    public List<int> onMouseButtonDownList = new List<int>();
    public List<int> onMouseButtonUpList = new List<int>();
    public List<int> onMouseButtonList = new List<int>();

    Dictionary<string, LuaFunction> funcache = new Dictionary<string, LuaFunction>();
    HashSet<string> noFuncDic = new HashSet<string>();

    LuaTable self;

    bool isAwake = false;
    private void Awake() {
        isAwake = true;
    }

    public void Init(LuaTable self_) {
        self = self_;
        if (!isAwake) {
            Debug.LogError($"{gameObject.name} 没有激活的情况下初始化会导致Lua引用不能被正确释放");
        }
    }

    private void OnDestroy() {
        OnKeyDown.RemoveAllListeners();
        OnKeyUp.RemoveAllListeners();
        OnKey.RemoveAllListeners();
        OnMouseButtonDown.RemoveAllListeners();
        OnMouseButtonUp.RemoveAllListeners();
        OnMouseButton.RemoveAllListeners();
    }

    bool call(string name, params object[] args) {
        if (self == null) return false;
        if (noFuncDic.Contains(name)) return false;
        LuaFunction f;
        if (!funcache.TryGetValue(name, out f)) {
            if (self.ContainsKey(name)) {
                f = self.Get<LuaFunction>(name);
            } else {
                noFuncDic.Add(name);
                return false;
            }
            if (f == null) {
                noFuncDic.Add(name);
                return false;
            }
        }
        f.Call(self, args);
        return true;
    }

    void Update() {

        for (int i = 0; i < keyDownList.Count; i++) {
            var value = keyDownList[i];
            if (Input.GetKeyDown(value)) {
                OnKeyDown?.Invoke(value);
                call("OnKeyDown", value);
            }
        }
        for (int i = 0; i < keyUpList.Count; i++) {
            var value = keyUpList[i];
            if (Input.GetKeyUp(value)) {
                OnKeyUp?.Invoke(value);
                call("OnKeyUp", value);
            }
        }
        for (int i = 0; i < keyList.Count; i++) {
            var value = keyList[i];
            if (Input.GetKey(value)) {
                OnKey?.Invoke(value);
                call("OnKey", value);
            }
        }
        for (int i = 0; i < onMouseButtonDownList.Count; i++) {
            var value = onMouseButtonDownList[i];
            if (Input.GetMouseButtonDown(value)) {
                OnMouseButtonDown?.Invoke(value);
                call("OnMouseButtonDown", value);
            }
        }
        for (int i = 0; i < onMouseButtonUpList.Count; i++) {
            var value = onMouseButtonUpList[i];
            if (Input.GetMouseButtonUp(value)) {
                OnMouseButtonUp?.Invoke(value);
                call("OnMouseButtonUp", value);
            }
        }
        for (int i = 0; i < onMouseButtonList.Count; i++) {
            var value = onMouseButtonList[i];
            if (Input.GetMouseButton(value)) {
                OnMouseButton?.Invoke(value);
                call("OnMouseButton", value);
            }
        }

    }
}
