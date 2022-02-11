using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
[LuaCallCSharp]
public class LuaObjectBind : MonoBehaviour
{
    public LuaTable luaTable;
    public LuaFunction luaFunction;
    public void Bind(LuaTable luaTable) {
        this.luaTable = luaTable;
    }
    public void BindFunc(LuaFunction func) {
        luaFunction = func;
    }

    private void OnDestroy() {
        luaTable.Dispose();
        luaFunction.Dispose();
    }
}
