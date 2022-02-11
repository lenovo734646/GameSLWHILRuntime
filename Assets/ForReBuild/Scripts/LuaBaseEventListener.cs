using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using XLua;


public class LuaBaseEventListener : MonoBehaviour {
    protected LuaTable self;

    public bool showLog = false;
    protected Dictionary<string, LuaFunction> funcache = new Dictionary<string, LuaFunction>();
    protected HashSet<string> noFuncDic = new HashSet<string>();

    protected bool isAwake = false;

    private void Awake() {
        isAwake = true;
    }
    public void Init(LuaTable self_) {
        if (!isAwake) {
            Debug.LogWarning($"{gameObject.name} 没有激活过，此时初始化可能会导致Lua引用不能被正确释放");
        }else
            self = self_;
    }
    public void ClearFuncCacheKey(string key) {
        if (funcache.TryGetValue(key, out LuaFunction f)) {
            f.Dispose();
        }
        funcache.Remove(key);
        noFuncDic.Remove(key);
    }

    public void ClearFunctions() {
        foreach (var f in funcache) {
            f.Value.Dispose();
        }
        funcache.Clear();
        noFuncDic.Clear();
    }

    protected bool call(string name, object obj1 = null, object obj2 = null) {
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
        } else if (obj1 != null)
            f.Call(self, obj1);
        else
            f.Call(self);
        if (showLog) {
            print("callparams " + name);
        }
        return true;
    }

    protected void OnDestroy() {
        OnDestroyPrecall();
        ClearFunctions();
        self?.Dispose();
        self = null;
    }

    protected virtual void OnDestroyPrecall() {

    }
}

