using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class LuaUnityEventListener : MonoBehaviour
{
    public bool showLog = false;
    Dictionary<string, LuaFunction> funcache = new Dictionary<string, LuaFunction>();
    HashSet<string> noFuncDic = new HashSet<string>();

    LuaTable self;

    int lastScreenWidth = 0;
    int lastScreenHeight = 0;
    bool hasOnScreenSizeChanged = false;

    public void Init(LuaTable self_) {
        self = self_;
        hasOnScreenSizeChanged = call("OnScreenSizeChanged");
    }
    //用来做动态事件添加，防止被缓存后无法动态添加监听
    public void ClearFuncCacheKey(string key) {
        funcache.Remove(key);
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
        if (showLog) {
            print("call "+name);
        }
        return true;
    }

    bool callparams(string name, object obj1=null,object obj2 = null) {
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
        if (obj1 != null && obj2 != null) {
            f.Call(self, obj1, obj2);
        } else if (obj1!=null)
            f.Call(self, obj1);
        else
            f.Call(self);
        if (showLog) {
            print("callparams " + name);
        }
        return true;
    }

    public void CallLuaByEvent(string tablefuncName) {
        callparams(tablefuncName);
    }
    public void CallLuaByGameObjectName(Object @object) {
        if(showLog)
            Debug.Log("点击的是"+($"On_{@object.name}_Event", @object));
        callparams($"On_{@object.name}_Event", @object);
    }

    private void Start() {
        callparams("Start");
    }

    private void OnDisable() {
        callparams("OnDisable");
    }

    private void OnEnable() {
        callparams("OnEnable");
    }

    private void OnDestroy() {
        callparams("OnDestroy");
        foreach (var f in funcache) {
            f.Value.Dispose();
        }
        funcache.Clear();
        self?.Dispose();
        self = null;
    }

    
    void Update() {
        if (hasOnScreenSizeChanged) checkScreen();
        callparams("Update");
    }

    
    void checkScreen() {
        if (lastScreenWidth != Screen.width || lastScreenHeight != Screen.height) {
            lastScreenWidth = Screen.width;
            lastScreenHeight = Screen.height;
            callparams("OnScreenSizeChanged", lastScreenWidth, lastScreenHeight);
        }
    }

    public void OnDoTweenComplete() {
        callparams("OnDoTweenComplete");
    }

    private void OnApplicationFocus(bool focus) {
        callparams("OnApplicationFocus", focus);
    }

    private void OnApplicationPause(bool pause) {
        callparams("OnApplicationPause", pause);
    }

    private void OnApplicationQuit() {
        callparams("OnApplicationQuit");
    }

    private void OnCollisionEnter(Collision collision) {
        callparams("OnCollisionEnter", collision);
    }

    private void OnCollisionEnter2D(Collision2D collision) {
        callparams("OnCollisionEnter2D", collision);
    }

    private void OnCollisionStay(Collision collision) {
        callparams("OnCollisionStay", collision);
    }

    private void OnCollisionStay2D(Collision2D collision) {
        callparams("OnCollisionStay2D", collision);
    }

    private void OnCollisionExit(Collision collision) {
        callparams("OnCollisionExit", collision);
    }

    private void OnCollisionExit2D(Collision2D collision) {
        callparams("OnCollisionExit2D", collision);
    }

    private void OnControllerColliderHit(ControllerColliderHit hit) {
        callparams("OnControllerColliderHit", hit);
    }

    private void OnParticleCollision(GameObject other) {
        callparams("OnParticleCollision", other);
    }

    private void OnParticleTrigger() {
        callparams("OnParticleTrigger");
    }

    private void OnCanvasGroupChanged() {
        callparams("OnCanvasGroupChanged");
    }

    private void OnTriggerEnter(Collider other) {
        callparams("OnTriggerEnter", other);
    }

    private void OnTriggerStay(Collider other) {
        callparams("OnTriggerStay", other);
    }

    private void OnTriggerExit(Collider other) {
        callparams("OnTriggerExit", other);
    }

    private void OnTriggerEnter2D(Collider2D collision) {
        callparams("OnTriggerEnter2D", collision);
    }

    private void OnTriggerStay2D(Collider2D collision) {
        callparams("OnTriggerStay2D", collision);
    }

    private void OnTriggerExit2D(Collider2D collision) {
        callparams("OnTriggerExit2D", collision);
    }

    private void OnAudioFilterRead(float[] data, int channels) {
        callparams("OnAudioFilterRead", data, channels);
    }

    private void OnTransformChildrenChanged() {
        callparams("OnTransformChildrenChanged");
    }

    private void OnTransformParentChanged() {
        callparams("OnTransformParentChanged");
    }

    private void OnRectTransformDimensionsChange() {
        callparams("OnRectTransformDimensionsChange");
    }

    private void OnRectTransformRemoved() {
        callparams("OnRectTransformRemoved");
    }
    //旧的调用方法，为兼容考虑不使用calloneparam，将来不推荐使用
    public void OnCustumEvent(string param) {
        call("OnCustumEvent", param);
    }
    //旧的调用方法，为兼容考虑不使用calloneparam，将来不推荐使用
    public void OnCustumEvent2(Object @object) {
        call("OnCustumEvent2", @object);
    }

    public void OnCustumObjectEvent(Object @object) {
        callparams("OnCustumObjectEvent", @object);
    }

}
