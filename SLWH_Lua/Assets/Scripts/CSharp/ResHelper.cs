using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Object = UnityEngine.Object;
using XLua;
#if UNITY_EDITOR
using UnityEditor;
#endif
[LuaCallCSharp]
public class ResHelper {

    public static Object Load(string path) {
        var r = Resources.Load(path);
#if UNITY_EDITOR
        if (r == null)
            r = AssetDatabase.LoadMainAssetAtPath(path);
#endif
        return r;
    }

    public static Object Load(string path, Type type) {
        var r = Resources.Load(path, type);
#if UNITY_EDITOR
        if (r == null)
            r = AssetDatabase.LoadAssetAtPath(path, type);
#endif
        return r;
    }

}
