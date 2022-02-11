using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using static XLua.LuaEnv;
using System.Text;

public class LuaFileLoaderEx
{
    public string _searchPath;

    public bool useEncrypted;

    CustomLoader initedLoader;

    public LuaFileLoaderEx(string searchPath, CustomLoader initedLoader_=null) {
        _searchPath = searchPath;
        bundleLoader = initedLoader = initedLoader_;
    }

    public CustomLoader bundleLoader;
    public bool onlyUesbundleLoader = true;

    byte[] key = null;

    public byte[] LoadFile(ref string filePath) {
        if (bundleLoader != null) {
            var r = bundleLoader(ref filePath);
            if (r == null) {
                if (onlyUesbundleLoader) return null;
            } else {
                return r;
            }
        }
        //Debug.Log("filePath:"+ filePath);
        return LoadFileRaw(filePath);
    }

    public byte[] LoadFileRaw(string filePath) {
#if UNITY_EDITOR
        if (useEncrypted) {
            if (key == null) {
                key = Encoding.ASCII.GetBytes("thSrVNQDEGtrHW5q");
            }
            var path_ = _searchPath + filePath.Replace('.', '/') + ".lc";
            var bytes = UnityHelper.ReadAllBytes(path_);
            if (bytes == null) {
                if(!path_.Contains("xlua/"))
                    Debug.LogWarning("can not read:"+ path_);
                return null;
            }
            try {
                bytes = UnityHelper.fck(bytes, key);
                for (int i = bytes.Length - 1; i >= 0; i--) {
                    if (bytes[i] == 0) {
                        bytes[i] = 32;
                    } else {
                        break;
                    }
                }
            } catch (System.Exception e) {
#if DEV_VER
                Debug.LogError("fck error:" + e.Message + " \npath:" + path_+"\n"+e.StackTrace);
#else
                Debug.LogError("fck error:\npath:" + path_);
#endif
                return null;
            }
            return bytes;
        } else {
            return UnityHelper.ReadAllBytes(_searchPath + filePath.Replace('.', '/') + ".lua");
        }
#else
        if (key == null) {
            key = Encoding.ASCII.GetBytes("thSrVNQDEGtrHW5q");
        }
        var path_ = _searchPath + filePath.Replace('.', '/') + ".lc";
        var bytes = UnityHelper.ReadAllBytes(path_);
        if (bytes == null) {
            if(!path_.Contains("xlua/"))
                Debug.LogWarning("can not read:"+ path_);
                return null;
        }
        try {
            bytes = UnityHelper.fck(bytes, key);
            for (int i = bytes.Length - 1; i >= 0; i--) {
                if (bytes[i] == 0) {
                    bytes[i] = 32;
                } else {
                    break;
                }
            }
        } catch (System.Exception e) {
#if DEV_VER
                Debug.LogError("fck error:" + e.Message + " \npath:" + path_+"\n"+e.StackTrace);
#else
                Debug.LogError("fck error:\npath:" + path_);
#endif
            return null;
        }
        return bytes;
#endif
    }

    public void Reset() {
        bundleLoader = initedLoader;
    }
}
