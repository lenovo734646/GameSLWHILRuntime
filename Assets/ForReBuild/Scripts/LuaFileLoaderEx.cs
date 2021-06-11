using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using static XLua.LuaEnv;

public class LuaFileLoaderEx
{
    public string _searchPath;

    public LuaFileLoaderEx(string searchPath) {
        _searchPath = searchPath;
    }

    public CustomLoader bundleLoader;
    public bool onlyUesbundleLoader = true;

    public byte[] LoadFile(ref string filePath) {
        
        // Debug.Log("path="+path);
        if (bundleLoader != null) {
            var r = bundleLoader(ref filePath);
            if (r == null) {
                if (onlyUesbundleLoader) return null;
            } else {
                return r;
            }
        }
        var path = _searchPath + filePath.Replace('.', '/') + ".lua";
      //  Debug.Log("File.Exists(path)="+ File.Exists(path)+" path:"+path);
        return UnityHelper.ReadAllBytes(path);
    }

    public void Reset() {
        bundleLoader = null;
    }
}
