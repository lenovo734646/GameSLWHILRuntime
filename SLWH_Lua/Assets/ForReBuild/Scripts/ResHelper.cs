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

public class ResHelper {

    public static Object Load(string path, bool rawPath = false) {
        if (!rawPath) {
            path = SysDefines.AB_BASE_PATH + path;
        }
        var r = Resources.Load(path);
#if UNITY_EDITOR
        if (r == null)
            r = AssetDatabase.LoadMainAssetAtPath(path);
#endif
        return r;
    }

    public static Object Load(string path, Type type, bool rawPath = false) {
        if (!rawPath) {
            path = SysDefines.AB_BASE_PATH + path;
        }
        var r = Resources.Load(path, type);
#if UNITY_EDITOR
        if (r == null)
            r = AssetDatabase.LoadAssetAtPath(path, type);
#endif
        return r;
    }

    public static Object[] LoadAll(string path, bool rawPath = false)
    {
        if (!rawPath)
        {
            path = SysDefines.AB_BASE_PATH + path;
        }
        var r = Resources.LoadAll(path, typeof(Sprite));
#if UNITY_EDITOR
        r = AssetDatabase.LoadAllAssetRepresentationsAtPath(path);
#endif
        return r;
    }

}
