//using ICSharpCode.SharpZipLib.Zip;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

public enum ResBuildType
{
    全部,
    大厅,
    公共,
    捕鱼,
}

class BuildWindow : EditorWindow
{

    [MenuItem("打包工具/打开窗口")]
    static void CreateBuildWindow()
    {
        GetWindow<BuildWindow>();
    }

    //ResBuildType buildType = ResBuildType.大厅;





    //bool hallupload = true;
    //bool commonupload = true;
    //bool fishupload = true;

    bool clearoldfiles = false;


    int curSelectedPlatform = 0;



    int platformtargettoindex(BuildTarget buildTarget)
    {
        switch (buildTarget)
        {
            case BuildTarget.Android: return 0;
            case BuildTarget.iOS: return 1;
            default: return 2;
        }
    }

    BuildTarget indextoplatformtarget(int index)
    {
        switch (index)
        {
            case 0: return BuildTarget.Android;
            case 1: return BuildTarget.iOS;
            default: return BuildTarget.StandaloneWindows;
        }
    }

    string platformtargettostring(BuildTarget buildTarget)
    {
        switch (buildTarget)
        {
            case BuildTarget.Android: return "Android";
            case BuildTarget.iOS: return "iOS";
            default: return "Win";
        }
    }

    //bool uploadres = false;
    private void OnEnable()
    {
        curSelectedPlatform = platformtargettoindex(AssetBundleTool.GetCurBuildTarget());
    }

    private void OnDisable()
    {
    }

    private void OnGUI()
    {

        clearoldfiles = GUILayout.Toggle(clearoldfiles, "重新打包（清空之前的打包文件）");
        curSelectedPlatform = EditorGUILayout.Popup("选择打包平台", curSelectedPlatform, new string[] {
        "Android","iOS","Windows"
        });

        if (GUILayout.Button("开始打包"))
        {
            var target = indextoplatformtarget(curSelectedPlatform);
            AssetBundleTool.BuildAllAssetBundles(target, clearoldfiles);
        }

    }



}

public class AssetBundleTool
{
    public static string AssetBundle_Output_Path = "StreamingAssets";

    private const string Version = "1.0.0.0";
    private const string Bundle_PostFix = ".bundle";
    //private const string Lua_Src_Path = "Assets/Script_HotUpdate/Lua";
    //private const string Lua_Output_Path = "Assets/Lua";
    //private const string Lua_Bundle_Name = "Lua";

    private const string AssetBundle_Build_List_Name = "bundle_to_asset_map";
    private const string AssetBundleManifest_Name = "assetbundle_manifest";
    private const string File_List_Name = "ab_file_list.ftxt";

    public static string curbuildpath = "";
    static void genpath(BuildTarget target)
    {
        if (target == BuildTarget.Android)
        {
            curbuildpath = AssetBundle_Output_Path + "/Android";
        }
        else if (target == BuildTarget.iOS)
        {
            curbuildpath = AssetBundle_Output_Path + "/iOS";
        }
        else curbuildpath = AssetBundle_Output_Path + "/Win";
    }

    static string GetBuildTargetOutputPath(BuildTarget target)
    {
        genpath(target);
        return curbuildpath;
    }


    public static BuildTarget GetCurBuildTarget()
    {
#if UNITY_ANDROID
        return BuildTarget.Android;
#elif UNITY_IOS
        return BuildTarget.iOS;
#else
        return BuildTarget.StandaloneWindows;
#endif
    }

    public static bool bclearOldFiles = false;

    //[MenuItem("AssetBundle/Build/Current")]
    public static void Build_Current()
    {
        BuildAllAssetBundles(GetCurBuildTarget(), bclearOldFiles);
    }

    public static void Build_Android()
    {
        BuildAllAssetBundles(BuildTarget.Android, bclearOldFiles);
    }

    public static void Build_iOS()
    {
        BuildAllAssetBundles(BuildTarget.iOS, bclearOldFiles);
    }

    public static void Build_Win()
    {
        BuildAllAssetBundles(BuildTarget.StandaloneWindows, bclearOldFiles);
    }

    public static void BuildAllAssetBundles(BuildTarget target, bool bclearOldFiles)
    {
        build(target, bclearOldFiles);
    }

    static void createEmptyBundleToAssetsMap()
    {
        var path = $"Assets/Editor/BundleToAssetsMap.txt";
        File.WriteAllText(path, "");

        AssetDatabase.Refresh();
        //加标签
        path = $"Assets/Editor/BundleToAssetsMap.txt";
        var importer = AssetImporter.GetAtPath(path);
        importer.SetAssetBundleNameAndVariant(AssetBundle_Build_List_Name, "bundle");
    }

    static void clearOldFiles()
    {
        DirectoryInfo directoryInfo = new DirectoryInfo(curbuildpath);
        if (directoryInfo.Exists)
        {
            directoryInfo.Delete(true);
        }
        directoryInfo.Create();
    }
    static void build(BuildTarget target, bool bclearOldFiles)
    {
        genpath(target);
        if (bclearOldFiles)
        {
            clearOldFiles();
        }

        LuaTool.CopyLuaFilesToBytes();
        LuaTool.SetLuaAssetBundleName();

        createEmptyBundleToAssetsMap();
        genChangeHashFiles();

        

        List<AssetBundleBuild> build_list = new List<AssetBundleBuild>();
        StringBuilder stringbuilder = new StringBuilder();
        string[] abNames = AssetDatabase.GetAllAssetBundleNames();
        foreach (var abName in abNames)
        {
            var abNameNoHashPostfix = abName.EndsWith(Bundle_PostFix) ?
                abName.Substring(0, abName.Length - Bundle_PostFix.Length) : abName;
            var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(abName);

            if (assetPaths != null && assetPaths.Length > 0 && !abName.EndsWith(Bundle_PostFix))
            {
                throw new Exception("No .bundle postfix for AssetBundle " + abName);
            }
            if (assetPaths != null && assetPaths.Length > 0)
            {
                var sb = stringbuilder;
                sb.Append(abNameNoHashPostfix).Append("\n");
                foreach (var assetPath in assetPaths)
                {
                    sb.Append("\t").Append(assetPath).Append("\n");
                }
                build_list.Add(new AssetBundleBuild() { assetBundleName = abName, assetNames = assetPaths });
            }
        }



        //写入ABList

        var path = $"Assets/Editor/BundleToAssetsMap.txt";
        var dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir))
            Directory.CreateDirectory(dir);
        var text = stringbuilder.ToString();
        File.WriteAllText(path, text);

        AssetDatabase.Refresh();


        var output_path = GetBuildTargetOutputPath(target);

        BuildABList(build_list, target, output_path);
        Debug.Log($"打包完成!");

        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();

        //Debug.Log("全部打包完成!");
    }

    static void BuildABList(List<AssetBundleBuild> builds, BuildTarget target, string output_path)
    {
        if (!Directory.Exists(output_path))
            Directory.CreateDirectory(output_path);
        List<AssetBundleBuild> buildvediolist = new List<AssetBundleBuild>();
        StringBuilder abliststrinfo = new StringBuilder();
        if (target == BuildTarget.Android)
        {
            foreach (var item in builds)
            {
                if (item.assetBundleName.ToLower().Contains("video"))
                {
                    buildvediolist.Add(item);
                }
            }
            foreach (var item in buildvediolist)
            {
                builds.Remove(item);
            }

            startbuild(output_path, abliststrinfo, builds, target);
            if (buildvediolist.Count > 0)
            {
                startbuild(output_path, abliststrinfo, buildvediolist, target, false);
            }
            writeabfile(abliststrinfo, output_path);
        }
        else
        {
            startbuild(output_path, abliststrinfo, builds, target);
            writeabfile(abliststrinfo, output_path);
        }



    }
    static void startbuild(string output_path, StringBuilder abliststrinfo, List<AssetBundleBuild> builds, BuildTarget target, bool isCompress = true)
    {
        AssetBundleManifest manifests;
        BuildAssetBundleOptions buildAssetBundleOptions;
        if (!isCompress)
        {
            buildAssetBundleOptions = BuildAssetBundleOptions.AppendHashToAssetBundleName |
         BuildAssetBundleOptions.DeterministicAssetBundle |
         BuildAssetBundleOptions.StrictMode |
         BuildAssetBundleOptions.UncompressedAssetBundle |
         BuildAssetBundleOptions.ForceRebuildAssetBundle;
        }
        else
        {
            buildAssetBundleOptions = BuildAssetBundleOptions.AppendHashToAssetBundleName |
         BuildAssetBundleOptions.ChunkBasedCompression |
         BuildAssetBundleOptions.DeterministicAssetBundle |
         BuildAssetBundleOptions.StrictMode;
        }
        manifests = BuildPipeline.BuildAssetBundles(output_path, builds.ToArray(),
         buildAssetBundleOptions, target);

        string[] abscommon = manifests.GetAllAssetBundles();
        foreach (var ab in abscommon)
        {
            var hash = manifests.GetAssetBundleHash(ab).ToString();
            var ab_no_hash = ab.Replace("_" + hash + Bundle_PostFix, string.Empty);
            var len = new FileInfo(output_path + "/" + ab).Length;
            abliststrinfo.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
        }

    }

    static void writeabfile(StringBuilder abliststrinfo, string output_path)
    {
        var manifestName = Path.GetFileName(output_path);
        var sbstr = abliststrinfo.ToString();
        var md5 = Util.md5(sbstr);
        var newFile = output_path + "/" + AssetBundleManifest_Name + "_" + md5 + Bundle_PostFix;
        if (File.Exists(newFile))
            File.Delete(newFile);
        File.Move(output_path + "/" + manifestName, newFile);//存在一个跟目录名相同的文件没有后缀 这儿当相当于重命名了一次


        var manifest_len = new FileInfo(newFile).Length;
        TimeSpan timeSpan = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);

        var new_sb = new StringBuilder();
        new_sb.Append(string.Format("{0}#{1}#{2}\n", Version, new_sb.Length + 1, Convert.ToInt64(timeSpan.TotalMilliseconds)));
        new_sb.Append(abliststrinfo);
        new_sb.Append(string.Format("{0}|{1}|{2}\n", AssetBundleManifest_Name, md5, manifest_len));

        File.WriteAllText(output_path + "/" + File_List_Name, new_sb.ToString());
    }

    static void genChangeHashFiles()
    {
        if (Directory.Exists("Assets/Editor/changehash"))
        {
            Directory.Delete("Assets/Editor/changehash", true);
        }
        Directory.CreateDirectory("Assets/Editor/changehash");
        AssetDatabase.Refresh();

        string[] abNames = AssetDatabase.GetAllAssetBundleNames();

        

        //生成一个txt放到bundle中，用来改变bundle的hash
        Dictionary<string, StringBuilder> changeHashTextMap = new Dictionary<string, StringBuilder>();
        foreach (var abName in abNames)
        {
            if (abName.Contains(AssetBundle_Build_List_Name) || abName.Contains("scene")) continue;
            StringBuilder sb = null;
            changeHashTextMap.TryGetValue(abName, out sb);
            var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(abName);
            foreach (var item in assetPaths)
            {
                if (item.Contains("changehash_")) continue;
                if (sb == null)
                {
                    sb = new StringBuilder();
                    changeHashTextMap.Add(abName, sb);
                }
                sb.Append(item + "\n");
            }
        }



        foreach (var item in changeHashTextMap)
        {
            var bundlename = item.Key;
            var path_ = $"Assets/Editor/changehash/_{bundlename.Replace("/", "_")}.txt";
            File.WriteAllText(path_, item.Value.ToString());
        }
        AssetDatabase.Refresh();
        foreach (var item in changeHashTextMap)
        {
            var bundlename = item.Key;
            var path_ = $"Assets/Editor/changehash/_{bundlename.Replace("/", "_")}.txt";
            var importer = AssetImporter.GetAtPath(path_);
            importer.SetAssetBundleNameAndVariant(bundlename, bundlename.EndsWith(Bundle_PostFix) ? "" : Bundle_PostFix.Replace(".", ""));
        }
    }

}
