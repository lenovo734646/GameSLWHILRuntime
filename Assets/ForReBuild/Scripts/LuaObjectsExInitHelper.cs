using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;

[LuaCallCSharp]
[Serializable]
public class LuaObjectsExInitHelper : MonoBehaviour
{
    public new string name;
    public Object[] objects;

    public bool sortByName = false;
    public LuaTable t;
    private void Awake()
    {
        if (sortByName)
        {
            Array.Sort(objects, (a, b) => { return a.name.CompareTo(b.name); });
        }
    }

    public void ObjectsSetToLuaTable(LuaTable self, bool autoDestroy = false)
    {
        t = self;
        for (int i = 0; i < objects.Length; i++)
        {
            t.Set(i + 1, objects[i]);
        }
        if (autoDestroy)
            Destroy(this);
    }

    public void InitList(LuaTable self, bool autoDestroy = true)
    {
        t = self;
        for (int i = 0; i < objects.Length; i++)
        {
            self.Set(i + 1, objects[i]);
        }
        if (autoDestroy)
            Destroy(this);
    }

    private void OnDestroy() {
        t?.Dispose();
        t = null;
    }
}