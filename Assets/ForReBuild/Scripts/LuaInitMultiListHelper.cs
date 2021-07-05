using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;
public class LuaInitMultiListHelper : MonoBehaviour
{
    [System.Serializable]
    public class ListData {
        [CustomEditorName("KeyOrName")]
        public string name;
        public List<Object> ObjectList=new List<Object>();
    }
    [CustomEditorName("是否忽略key(使用数组Table)")]
    public bool ignoreKey = false;
    public List<ListData> listDatas = new List<ListData>();

    public LuaTable t;
    public LuaTable Init(LuaTable self, bool autoDestroy = true) {
        if (ignoreKey) {
            for (int i = 0; i < listDatas.Count; i++) {
                var nt = self.NewTable(i + 1);
                var data = listDatas[i];
                setListToTable(nt, data.ObjectList);
            }
        } else {
            for (int i = 0; i < listDatas.Count; i++) {
                var data = listDatas[i];
                if (self.ContainsKey(data.name)) {
                    Debug.LogWarning("设置的重复的key:"+data.name+" at "+gameObject);
                    continue;
                }
                var nt = self.NewTable(data.name);
                setListToTable(nt, data.ObjectList);
            }
        }
        if (autoDestroy)
            Destroy(this);
        else {
            t = self;
        }
        return self;
    }

    void setListToTable(LuaTable t, List<Object> objects) {
        for (int i = 0; i < objects.Count; i++) {
            if(objects[i])
                t.Set(i + 1, objects[i]);
        }
    }

    private void OnDestroy() {
        t?.Dispose();
        t = null;
    }
}
