using UnityEngine;
using System.Collections.Generic;
using System;
using System.IO;
using System.Collections;
using ForReBuild;

public class BundlePathHelper {
    Func<string, string> getPathFunc;
    private Dictionary<string, string> _assetPath_to_bundleName = new Dictionary<string, string>();
    private Dictionary<string, string> _bundleName_to_hashName = new Dictionary<string, string>();
    private Dictionary<string, string[]> _hashname_to_dependencies = new Dictionary<string, string[]>();

    string basepath = "";
    bool isEncripted = false;

    public string LoadfailedReson { get; private set; } = "";

    public bool Loadfailed { get; private set; } = false;

    public BundlePathHelper(string basepath) {
        if (!Directory.Exists(basepath)) {
            Loadfailed = true;
            LoadfailedReson = "Directory not Exists path:" + basepath;
            return;
        }
        this.basepath = basepath;

        getPathFunc = path => {
            return basepath + path;
        };

        Init();
    }

    public void Init() {
        LoadABFileList();
        if (Loadfailed) return;
        LoadAssetsMap();
        LoadManifest();
    }

    private void LoadABFileList() {
        var path = getPathFunc(AssetConfig.File_List_Name);

        if (!File.Exists(path)) {
            Loadfailed = true;
            LoadfailedReson = "No ab_file_list! path:" + path;
            return;
        }
        var text = UnityHelper.ReadFile(path);
        if (string.IsNullOrEmpty(text)) {
            Debug.LogError("ab_file_list read error!");
            Loadfailed = true;
            return;
        }

        var lines = text.Split('\n');
        foreach (var line in lines) {
            if (line.Contains("#")) {
                if (line.Contains("encrypted"))
                    isEncripted = true;
                continue;
            }
            if (string.IsNullOrEmpty(line))
                continue;

            var strs = line.Split('|');
            if (strs.Length >= 3) {
                var bundleName = strs[0];
                var realpath = StringUtil.Concat(strs[0], "_", strs[1], AssetConfig.Bundle_PostFix);
                if (_bundleName_to_hashName.ContainsKey(bundleName)) {
                    _bundleName_to_hashName[bundleName] = realpath;
                } else {
                    _bundleName_to_hashName.Add(bundleName, realpath);

                }
            }
        }
    }

    private void LoadManifest() {
        string bundlename = GetHashName(AssetConfig.AssetBundleManifest_Name);
        if (string.IsNullOrEmpty(bundlename)) {
            Debug.LogError("No BundleInfoManifest in file list");
            return;
        }

        var fullPath = getPathFunc(bundlename);
        if (string.IsNullOrEmpty(fullPath)) {
            Debug.LogError("No BundleInfoManifest path!fullPath:" + fullPath);
            return;
        }
        AssetBundle bundle;
        if (fullPath.EndsWith(".bundleEnc")) {
            bundle = AssetBundle.LoadFromMemory(BundleRecycler.fck(fullPath));
        } else
            bundle = AssetBundle.LoadFromFile(fullPath);
        if (bundle == null) {
            Debug.LogError("BundleInfoManifest bundle load error!fullPath:" + fullPath);
            return;
        }

        var _manifest = bundle.LoadAsset<AssetBundleManifest>("BundleInfoManifest");
        if (_manifest == null) {
            //Debug.LogError("BundleInfoManifest load error!fullPath:"+ fullPath);
            bundle.Unload(true);
            return;
        }

        foreach (var p in _bundleName_to_hashName) {
            var realpath = p.Value;
            var dps = _manifest.GetAllDependencies(realpath);
            _hashname_to_dependencies.Add(realpath, dps);
        }

        Resources.UnloadAsset(_manifest);

        bundle.Unload(true);
    }

    private void LoadAssetsMap() {
        string realpath = GetHashName(AssetConfig.AssetBundle_Build_List_Name);
        if (string.IsNullOrEmpty(realpath)) {
            Debug.LogError("No BundleInfo_Build_List in file list.\nbasepath:" + basepath);
            return;
        }

        var fullPath = getPathFunc(realpath);
        if (string.IsNullOrEmpty(fullPath)) {
            Debug.LogError("No BundleInfo_Build_List path");
            return;
        }
        AssetBundle bundle;
        if (fullPath.EndsWith(".bundleEnc")) {
            var bytes = BundleRecycler.fck(fullPath);
            bundle = AssetBundle.LoadFromMemory(bytes);
        } else
            bundle = AssetBundle.LoadFromFile(fullPath);

        if (bundle == null) {
            Debug.LogError("BundleInfo_Build_List bundle load error");
            return;
        }
        var names = bundle.GetAllAssetNames();//里面应该只能包含一个文件，不限定名字
        var textAsset = bundle.LoadAsset<TextAsset>(names[0]);
        if (textAsset == null) {
            Debug.LogError("BundleInfo_Build_List load error");
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

    public string GetHashName(string bundleName) {
        if (bundleName == null) {
            Debug.LogWarning("bundleName == null");
            return "";
        }
        _bundleName_to_hashName.TryGetValue(bundleName, out string realpath);
        if (string.IsNullOrEmpty(realpath)) {
            Debug.LogError("realpath == null\nbundleName:"+ bundleName+ "\nbasepath:"+ basepath);
            return null;
        }
        if (isEncripted) {
            realpath = realpath.Replace(".bundle", ".bundleEnc");
        }
        return realpath;
    }

    public string GetAssetBundleNameByPath(string assetPath, bool rawPath) {
        if (!rawPath) {
            assetPath = SysDefines.AB_BASE_PATH + assetPath;
        }
        if (!_assetPath_to_bundleName.TryGetValue(assetPath, out string bundleName)) {
            Debug.LogWarning($"can not find bundleName \nassetPath:{assetPath} \nbasepath:{basepath}");
        }
        return bundleName;
    }

    public string GetBundleRealPath(string assetPath, bool rawPath) {
        if (!rawPath) {
            assetPath = SysDefines.AB_BASE_PATH + assetPath;
        }
        var bundlename = GetAssetBundleNameByPath(assetPath, true);
        if (bundlename == null) {
            Debug.LogWarning("Can not get bundle name.\nassetPath:" + assetPath);
            return null;
        }
        return GetRealPathByName(bundlename);
    }

    public string GetRealPathByName(string bundlename) {
        var hashName = GetHashName(bundlename);
        if (string.IsNullOrEmpty(hashName)) {
            Debug.LogWarning("Can not get hashName. bundlename:" + bundlename);
            return "";
        }
        return getPathFunc(hashName);
    }

    public string[] GetAllDependencies(string realpath) {
        if (_hashname_to_dependencies.TryGetValue(realpath, out string[] value)) {
            return value;
        }
        return null;
    }

    public void Clear() {
        _hashname_to_dependencies.Clear();
        _assetPath_to_bundleName.Clear();
        _bundleName_to_hashName.Clear();
    }
}
