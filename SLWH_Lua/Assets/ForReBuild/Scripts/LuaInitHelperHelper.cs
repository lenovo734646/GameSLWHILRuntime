using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;
[LuaCallCSharp]
public class LuaInitHelperHelper : MonoBehaviour{


    public void InitHelperTree(LuaTable luaTable,
        bool autoDestroy = true, bool autoDestroyInitHelper = false) {

        var initHelepr = GetComponent<LuaInitHelper>();
        if (initHelepr) {
            foreach (var data in initHelepr.initList) {
                if(data.monoType && data.monoType is LuaInitHelper) {

                    var name = data.monoType.name;
                    if (luaTable.ContainsKey(name)) {
                        name += "_1";
                        Debug.LogWarning($"重复的key 重命名为 {name} 父级:{data.monoType.transform.parent.name}");
                    }
                    var initHelepr_ = data.monoType as LuaInitHelper;
                    if(!initHelepr_.HasInit)
                        initHelepr_.Init(luaTable.NewTable(name), autoDestroyInitHelper);
                }
            }
            initHelepr.Init(luaTable, autoDestroyInitHelper);
        }
        if (autoDestroy)
            Destroy(this);
    }

    public void InitChildrenByTableCreator(LuaFunction tableCreator,
         bool autoDestroy = true, bool autoDestroyInitHelper = false) {
        foreach (Transform t in transform) {
            var com = t.GetComponent<LuaInitHelper>();
            if (com) {
                com.Init(tableCreator.Call()[0] as LuaTable, autoDestroyInitHelper);
            }
        }
        if (autoDestroy)
            Destroy(this);
    }

    public void InitWithChildren(LuaTable luaTable, 
        bool autoDestroy = true, bool autoDestroyInitHelper = false) {
        var initHelepr = GetComponent<LuaInitHelper>();
        if(initHelepr)
            initHelepr.Init(luaTable, autoDestroyInitHelper);

        ForeachChildren(luaTable, transform, (t, table) => {
            initHelepr = t.GetComponent<LuaInitHelper>();
            if (initHelepr)
                initHelepr.Init(table, autoDestroyInitHelper);
        });

        if (autoDestroy)
            Destroy(this);
    }

    void ForeachChildren(LuaTable table, Transform transform, Action<Transform, LuaTable> action) {
        foreach (Transform t in transform) {
            action(t, table);
            if (t.childCount > 0) {
                var name = t.name;
                if (table.ContainsKey(name)) {
                    name += "_1";
                    Debug.LogWarning($"重复的key 重命名为 {name} 父级:{t.parent.name}");
                }
                ForeachChildren(table.NewTable(name), t, action);
            }
        }
    }



}
