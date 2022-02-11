using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;
[LuaCallCSharp]
public class LuaInitHelper :MonoBehaviour{


    [Serializable]
    public class TypeData {
        public string name;
        public Transform t;//实际上已经没用，但是为了兼容旧代码需要保留
        public Behaviour monoType;//实际上已经没用，但是为了兼容旧代码需要保留
        public Object anyType;
        public string sType;//实际上已经没用，但是为了兼容旧代码需要保留
        public string manualName;//实际上已经没用，但是为了兼容旧代码需要保留
    }
    public Object[] objects;
    public bool sortByName = false;
    public List<TypeData> initList = new List<TypeData>();
    public LuaTable t;

    public bool HasInit { get { return t != null; } }

    public bool showlog = false;


    private void Awake() {
        if (sortByName) {
            Array.Sort(objects, (a,b)=> { return a.name.CompareTo(b.name); });
        }
    }

    public void ObjectsSetToLuaTable(LuaTable t, bool autoDestroy = false) {
        this.t = t;
        for(int i = 0; i < objects.Length; i++) {
            t.Set(i + 1, objects[i]);
        }
        if (autoDestroy)
            Destroy(this);
    }

    public void InitValuesAndEvent(LuaTable self, bool autoDestroy = true) {
        gameObject.GetOrAddComponent<LuaUnityEventListener>().Init(self);
        InitValuesToLua(self, autoDestroy);
    }

    public void InitWithList(LuaTable self, string listKey, bool autoDestroy = true) {
        ObjectsSetToLuaTable(self.NewTable(listKey));
        Init(self, autoDestroy);
    }

    public LuaTable Init(LuaTable self, bool autoDestroy = true) {
        InitValuesToLua(self, autoDestroy);
        return self;
    }

    public void InitValuesToLua(LuaTable self, bool autoDestroy = true, bool withChildInitHelper = false) {
        t = self;
        for (int i = 0; i < initList.Count; i++) {
            var data = initList[i];
            var name = string.IsNullOrEmpty(data.name) ? data.manualName : data.name;
            if (string.IsNullOrEmpty(data.name)) {
                Debug.LogError($"index:{i} name没有值！ at {gameObject}");
                continue;
            }
            if (!data.anyType) {
                Debug.LogError($"{name}没有值！at {gameObject}");
                continue;
            }
            self.Set(name, data.anyType);
            if(showlog)
                Debug.Log($"{name}设置了值！");
            if(withChildInitHelper && (data.anyType is LuaInitHelper)) {
                var hp = data.anyType as LuaInitHelper;
                hp.InitValuesToLua(self.NewTable(hp.name+"_ct"),autoDestroy,withChildInitHelper);
            }
        }
        if(autoDestroy)
            Destroy(this);
    }
    public void InitWithChildrenInit(LuaTable self, bool autoDestroy = true) {
        InitValuesToLua(self, autoDestroy, true);
    }

    public void InitList(LuaTable self, bool autoDestroy = true) {
        t = self;
        for (int i = 0; i < objects.Length; i++) {
            self.Set(i + 1, objects[i]);
        }
        if (autoDestroy)
            Destroy(this);
    }

    public void InitListToMap(LuaTable self, bool autoDestroy = true) {
        t = self;
        for (int i = 0; i < objects.Length; i++) {
            if(self.ContainsKey(objects[i].name)) {
                Debug.LogWarning($"重复的key {objects[i].name} at {gameObject}");
                continue;
            }
            self.Set(objects[i].name, objects[i]);
        }
        if (autoDestroy)
            Destroy(this);
    }

    private void OnDestroy() {
        t?.Dispose();
        t = null;
    }
}
