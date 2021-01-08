using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;
using XLua;

public class LuaAutoInitHelper : MonoBehaviour
{
    public LuaTable t;

    public string[] typefilter;

    public LuaTable Init(LuaTable self, object[] typefilter_ = null, bool autoDestroy = false) {
        t = self;
        if (typefilter_ == null) {
            typefilter_ = typefilter;
        }
        ForeachChildren(self, transform, (t,table) => {
            if (typefilter_ != null && typefilter_.Length > 0) {
                foreach (var type in typefilter_) {
                    Component com;
                    string typename = "";
                    if(type is Type) {
                        var type_ = type as Type;
                        typename = type_.FullName;
                        com = t.GetComponent(type_);
                    } else {
                        var type_ = type as string;
                        typename = type_;
                        com = t.GetComponent(type_);
                    }
                    
                    if (com) {
                        var name = com.name + "_" + typename;
                        if (table.ContainsKey(name)) {
                            name += "_1";
                            Debug.LogWarning($"重复的key 重命名为 {name} 父级:{t.parent.name}");
                        }
                        table.Set(name, com);
                    }
                }
            } else {
                var name = t.name;
                if (table.ContainsKey(name)) {
                    name += "_1";
                    Debug.LogWarning($"重复的key 重命名为 {name} 父级:{t.parent.name}");
                }
                table.Set(name, t);
            }
        });

        if (autoDestroy)
            Destroy(this);
        return t;
    }

    void ForeachChildren(LuaTable table, Transform transform, Action<Transform,LuaTable> action) {
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
