using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class LuaUnityEventListener : LuaBaseEventListener {


    int lastScreenWidth = 0;
    int lastScreenHeight = 0;
    bool hasOnScreenSizeChanged = false;

    //用于兼容
    bool oldcall(string name, params object[] args) {
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

    public void CallLuaByEvent(string tablefuncName) {
        call(tablefuncName);
    }
    public void CallLuaByGameObjectName(Object @object) {
        if(showLog)
            Debug.Log("点击的是"+($"On_{@object.name}_Event", @object));
        call($"On_{@object.name}_Event", @object);
    }

    

    private void Start() {
        call("Start");
    }

    private void OnDisable() {
        call("OnDisable");
    }

    private void OnEnable() {
        call("OnEnable");
    }

    protected override void OnDestroyPrecall() {
        call("OnDestroy");
    }


    void Update() {
        if (hasOnScreenSizeChanged) checkScreen();
        call("Update");
    }

    
    void checkScreen() {
        if (lastScreenWidth != Screen.width || lastScreenHeight != Screen.height) {
            lastScreenWidth = Screen.width;
            lastScreenHeight = Screen.height;
            call("OnScreenSizeChanged", lastScreenWidth, lastScreenHeight);
        }
    }

    public void OnDoTweenComplete() {
        call("OnDoTweenComplete");
    }

    private void OnApplicationFocus(bool focus) {
        call("OnApplicationFocus", focus);
    }

    private void OnApplicationPause(bool pause) {
        call("OnApplicationPause", pause);
    }

    private void OnApplicationQuit() {
        call("OnApplicationQuit");
    }

    private void OnCollisionEnter(Collision collision) {
        call("OnCollisionEnter", collision);
    }

    private void OnCollisionEnter2D(Collision2D collision) {
        call("OnCollisionEnter2D", collision);
    }

    private void OnCollisionStay(Collision collision) {
        call("OnCollisionStay", collision);
    }

    private void OnCollisionStay2D(Collision2D collision) {
        call("OnCollisionStay2D", collision);
    }

    private void OnCollisionExit(Collision collision) {
        call("OnCollisionExit", collision);
    }

    private void OnCollisionExit2D(Collision2D collision) {
        call("OnCollisionExit2D", collision);
    }

    private void OnControllerColliderHit(ControllerColliderHit hit) {
        call("OnControllerColliderHit", hit);
    }

    private void OnParticleCollision(GameObject other) {
        call("OnParticleCollision", other);
    }

    private void OnParticleTrigger() {
        call("OnParticleTrigger");
    }

    private void OnTriggerEnter(Collider other) {
        call("OnTriggerEnter", other);
    }

    private void OnTriggerStay(Collider other) {
        call("OnTriggerStay", other);
    }

    private void OnTriggerExit(Collider other) {
        call("OnTriggerExit", other);
    }

    private void OnTriggerEnter2D(Collider2D collision) {
        call("OnTriggerEnter2D", collision);
    }

    private void OnTriggerStay2D(Collider2D collision) {
        call("OnTriggerStay2D", collision);
    }

    private void OnTriggerExit2D(Collider2D collision) {
        call("OnTriggerExit2D", collision);
    }

    //旧的调用方法，为兼容考虑不使用calloneparam，将来不推荐使用
    public void OnCustumEvent(string param) {
        oldcall("OnCustumEvent", param);
    }
    //旧的调用方法，为兼容考虑不使用calloneparam，将来不推荐使用
    public void OnCustumEvent2(Object @object) {
        oldcall("OnCustumEvent2", @object);
    }

    public void OnCustumObjectEvent(Object @object) {
        call("OnCustumObjectEvent", @object);
    }


    //0.83后支持
    public void OnCustumObjecsEvent(object[] objs) {
        if (showLog) {
            var str = "objs:";
            foreach(var obj in objs) {
                str += obj + ",";
            }
            str = str.Remove(str.Length-1);
            Debug.Log("OnCustumObjecsEvent " + str);
        }
           
        call("OnCustumObjecsEvent", objs);
    }

    //0.83后支持
    public void CallLuaByGameObjectName_objects(Object @object, object[] objs) {
        if (showLog) {
            var str = " objs:";
            foreach (var obj in objs) {
                str += obj + ",";
            }
            str = str.Remove(str.Length - 1);
            Debug.Log("CallLuaByGameObjectName_objects " + ($"On_{@object.name}_Event", @object)+str);
        }
        call($"On_{@object.name}_Event2", @object, objs);
    }
}
