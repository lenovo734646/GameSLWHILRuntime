using UnityEngine;
using System.Collections.Generic;
using System;
using System.IO;
using System.Collections;

public class BundleManager {
    public bool loadDependencies = false;
    public string name = "NoName";
    bool autoInit = false;
    bool isInit = false;
    Func<string, bool, string> getPathFunc;
    //  private readonly Context _context;
    private AssetBundleManifest _manifest;
    private readonly Dictionary<string, string> _assetPath_to_bundleName = new Dictionary<string, string>();
    private readonly Dictionary<string, string> _bundleName_to_hashName = new Dictionary<string, string>();
    private readonly Dictionary<string, AssetBundle> _bundleCache = new Dictionary<string, AssetBundle>();



#if UNITY_EDITOR
    struct _debugdata {
        public BundleManager mgr;
        public AssetBundle bundle;
    }
    static Dictionary<string, _debugdata> debugCheckMap = new Dictionary<string, _debugdata>();

#endif

    public BundleManager(Context context, bool isUpdate) {
        // _context = context;
        getPathFunc = (a, b) => context.Config.GetPath(a, b);
    }
    public BundleManager(Func<string, bool, string> getPathFunc_) {
        getPathFunc = getPathFunc_;
    }

    public BundleManager(Func<string, bool, string> getPathFunc_, bool autoInit) {
        getPathFunc = getPathFunc_;
        this.autoInit = autoInit;
    }

    public void Init() {
        Clear();
        LoadABFileList();
        LoadManifest();
        LoadAssetsMap();
        isInit = true;
    }

    private void LoadABFileList() {
        var path = getPathFunc(AssetConfig.File_List_Name, false);
        if (path == null) {
            Debug.LogError("No ab_file_list! path:" + path);
            autoInit = false;
            return;
        }
        if (!File.Exists(path)) {
            Debug.LogError("No ab_file_list! path:" + path);
            autoInit = false;
            return;
        }


        var text = UnityHelper.ReadFile(path);
        if (string.IsNullOrEmpty(text)) {
            Debug.LogError("ab_file_list read error!");
            autoInit = false;
            return;
        }

        var lines = text.Split('\n');
        foreach (var line in lines) {
            if (string.IsNullOrEmpty(line) || line.Contains("#"))
                continue;

            var strs = line.Split('|');
            if (strs.Length >= 3) {
                var bundleName = strs[0];
                var hashName = strs[0] + "_" + strs[1] + AssetConfig.Bundle_PostFix;
                if (_bundleName_to_hashName.ContainsKey(bundleName)) {
                    _bundleName_to_hashName[bundleName] = hashName;
                } else {
                    _bundleName_to_hashName.Add(bundleName, hashName);
                }
            }
        }
        if (_bundleName_to_hashName.Count == 0) {
            autoInit = false;
        }
    }

    private void LoadManifest() {
        string bundlename = GetAssetBundleHashName(AssetConfig.AssetBundleManifest_Name);
        if (string.IsNullOrEmpty(bundlename)) {
            Debug.LogError("No AssetBundleManifest in file list");
            autoInit = false;
            return;
        }

        var fullPath = getPathFunc(bundlename, true);
        if (string.IsNullOrEmpty(fullPath)) {
            Debug.LogError("No AssetBundleManifest path");
            autoInit = false;
            return;
        }
        AssetBundle bundle = AssetBundle.LoadFromFile(fullPath);
        if (bundle == null) {
            Debug.LogError("AssetBundleManifest bundle load error");
            autoInit = false;
            return;
        }

        _manifest = bundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        if (_manifest == null) {
            Debug.LogError("AssetBundleManifest load error");
            bundle.Unload(true);
            autoInit = false;
            return;
        }

        bundle.Unload(false);
    }

    private void LoadAssetsMap() {
        string hashName = GetAssetBundleHashName(AssetConfig.AssetBundle_Build_List_Name);
        if (string.IsNullOrEmpty(hashName)) {
            Debug.LogError("No AssetBundle_Build_List in file list");
            return;
        }

        var fullPath = getPathFunc(hashName, true);
        if (string.IsNullOrEmpty(fullPath)) {
            Debug.LogError("No AssetBundle_Build_List path");
            return;
        }
        AssetBundle bundle = AssetBundle.LoadFromFile(fullPath);
        if (bundle == null) {
            Debug.LogError("AssetBundle_Build_List bundle load error");
            return;
        }
        var names = bundle.GetAllAssetNames();//里面应该只能包含一个文件，不限定名字
        var textAsset = bundle.LoadAsset<TextAsset>(names[0]);
        if (textAsset == null) {
            Debug.LogError("AssetBundle_Build_List load error");
            bundle.Unload(true);
            return;
        }

        var lines = textAsset.text.Split('\n');
        bundle.Unload(true);
        string bundleName = null;
        foreach (var line in lines) {
            if (string.IsNullOrEmpty(line))
                continue;

            if (line.StartsWith("\t")) {
                if (bundleName != null) {
                    var assetPath = line.Substring(1);

                    if (_assetPath_to_bundleName.ContainsKey(assetPath)) {
                        _assetPath_to_bundleName[assetPath] = bundleName;
                    } else {
                        _assetPath_to_bundleName.Add(assetPath, bundleName);
                    }
                }
            } else {
                bundleName = line;
            }
        }
    }

    public string GetAssetBundleHashName(string bundleName) {
        string hashName = null;
        if (_bundleName_to_hashName.Count == 0 && !isInit && autoInit) {
            Init();
        }
        _bundleName_to_hashName.TryGetValue(bundleName, out hashName);
        return hashName;
    }

    public string GetAssetBundleName(string assetPath) {
        string bundleName = null;
        if (_assetPath_to_bundleName.Count == 0 && !isInit && autoInit) {
            Init();
        }
        _assetPath_to_bundleName.TryGetValue(assetPath, out bundleName);
        return bundleName;
    }

    public AssetBundle LoadAssetBundleByPath(string path) {

        return LoadAssetBundle(GetAssetBundleName(path));
    }


    public AssetBundle LoadAssetBundle(string bundleName) {
        if (string.IsNullOrEmpty(bundleName))
            return null;

        var hashName = GetAssetBundleHashName(bundleName);
        if (string.IsNullOrEmpty(hashName))
            return null;

        return LoadAssetBundleByHashName(hashName);
    }

    public AssetBundle LoadAssetBundleByHashName(string hashName) {
        if (loadDependencies && _manifest != null) {
            string[] dependencies = _manifest.GetAllDependencies(hashName);
            foreach (var dependency in dependencies) {
                LoadAssetBundleFromFileByHashName(dependency);
            }
        }
        return LoadAssetBundleFromFileByHashName(hashName);
    }

    public AssetBundle LoadAssetBundleFromFileByHashName(string hashName) {

        if (string.IsNullOrEmpty(hashName))
            return null;

        AssetBundle assetBundle = null;
        if (_bundleCache.TryGetValue(hashName, out assetBundle))
            return assetBundle;

        var fullPath = getPathFunc(hashName, true);
        if (string.IsNullOrEmpty(fullPath))
            return null;
#if UNITY_EDITOR
        _debugdata _debugdata;
        if (debugCheckMap.TryGetValue(hashName, out _debugdata)) {
            Debug.LogError($"资源已经被加载过 hashName:{hashName} name:{_debugdata.mgr.name} id:{_debugdata.mgr.GetHashCode()}\n this.name:{name} this.id:{GetHashCode()} this.isInit:{isInit}");
            return null;
        }
#endif

        assetBundle = AssetBundle.LoadFromFile(fullPath);
        if (assetBundle == null)
            return null;

#if UNITY_EDITOR
        //Debug.LogWarning($"add hashName:{hashName} this.name:{name} this.id:{GetHashCode()}");
        debugCheckMap.Add(hashName, new _debugdata() { mgr = this, bundle = assetBundle });
#endif

        _bundleCache.Add(hashName, assetBundle);
        return assetBundle;
    }

    public AssetBundle GetAssetBundleFromCache(string hashName) {
        AssetBundle assetBundle = null;
        if (_bundleCache.TryGetValue(hashName, out assetBundle))
            return assetBundle;
        return null;
    }

    public string[] GetAllDependencies(string hashName) {
        if (_manifest != null) {
            return _manifest.GetAllDependencies(hashName);
        }
        return null;
    }

    public void AddCache(string name, AssetBundle ab) {
        _bundleCache.Add(name, ab);
    }



    public AssetBundle GetCachedAssetBundle(string bundleName) {
        var hashName = GetAssetBundleHashName(bundleName);
        if (string.IsNullOrEmpty(hashName))
            return null;

        AssetBundle assetBundle = null;
        if (_bundleCache.TryGetValue(hashName, out assetBundle))
            return assetBundle;

        return null;
    }

    public void UnloadAssetBundle(string bundleName) {
        var hashName = GetAssetBundleHashName(bundleName);
        if (string.IsNullOrEmpty(hashName))
            return;

        AssetBundle assetBundle = null;
        if (_bundleCache.TryGetValue(hashName, out assetBundle)) {
            assetBundle.Unload(false);
            _bundleCache.Remove(hashName);
        }
    }

    public void Clear() {
        if (_manifest != null)
            Resources.UnloadAsset(_manifest);
        _manifest = null;

#if UNITY_EDITOR
        foreach (var p in _bundleName_to_hashName) {
            debugCheckMap.Remove(p.Value);
        }
#endif

        _assetPath_to_bundleName.Clear();
        _bundleName_to_hashName.Clear();
        foreach (var pair in _bundleCache) {
            var bundle = pair.Value;
            bundle.Unload(false);

        }
        _bundleCache.Clear();
        isInit = false;
    }
}
