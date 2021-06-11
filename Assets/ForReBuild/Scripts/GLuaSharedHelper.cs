using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;


public static class GLuaSharedHelper
{

    public static LuaTable g_Env;

    static LuaFunction callLua = null;
    public static LuaFunction CallLuaFunc {
        get {
            if (callLua == null) {
                callLua = g_Env.Get<LuaFunction>("CallLua");
            }
            return callLua;
        }
    }

    public static T GetUnityObject<T>(string name) where T: Object {
        
        return g_Env.Get<LuaTable>("sharedMap").Get<T>(name);
    }
    public static T Get<T>(string name) {

        return g_Env.Get<LuaTable>("sharedMap").Get<T>(name); ;
    }

    public static int CurState {
        get {
            return g_Env.Get<LuaTable>("luaAppRoot").Get<int>("curState");
        }
    }

    public static object[] CallLua(params object[] args) {
        return CallLuaFunc.Call(args);
    }



}
