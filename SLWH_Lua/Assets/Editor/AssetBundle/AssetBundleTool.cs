using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using UnityEditor;
using UnityEngine;

public class AssetBundleTool
{
    public static string AssetBundle_Output_Path = "StreamingAssets";
    //fishing3d
    private static string SubgameFoldeName = "fishing3d";//使用小写，Windows上大小不第三， IOS Android大写小敏感
    private const string Version = "1.0.0.0";
    private const string Bundle_PostFix = ".bundle";
    private const string Lua_Src_Path = "Assets/Script_HotUpdate/Lua";
    private const string Lua_Output_Path = "Assets/Lua";
    private const string Lua_Bundle_Name = "Lua";
    private const string AssetBundle_Build_List_Path = "Assets/Editor/BundleToAssetsMap.txt";
    //
    private const string AssetBundle_Build_List_Name = "bundle_to_asset_map"; 
    private const string AssetBundleManifest_Name = "assetbundle_manifest";
    private const string File_List_Name = "ab_file_list.ftxt";
    static string GetBuildTargetOutputPath(BuildTarget target)
    {
        if (target == BuildTarget.Android)
            return AssetBundle_Output_Path + "/Android";

        if (target == BuildTarget.iOS)
            return AssetBundle_Output_Path + "/iOS";

        return AssetBundle_Output_Path + "/Win";
    }

    [MenuItem("AssetBundle/Build/Current")]
    static void Build_Current()
    {
#if UNITY_ANDROID
        BuildAllAssetBundles(BuildTarget.Android);
#elif UNITY_IOS
        BuildAllAssetBundles(BuildTarget.iOS);
#else
        BuildAllAssetBundles(BuildTarget.StandaloneWindows);
#endif
    }

    [MenuItem("AssetBundle/Build/CurrentEncrypt")]
    static void Build_CurrentEncrypt()
    {
#if UNITY_ANDROID
        EncrypABList(BuildTarget.Android);
#elif UNITY_IOS
        EncrypABList(BuildTarget.iOS);
#else
        EncrypABList(BuildTarget.StandaloneWindows);
#endif
    }
    [MenuItem("AssetBundle/Build/CurrentDecryptTest")]
    static void Build_CurrentEncryptTest()
    {
#if UNITY_ANDROID
        LoadEncrypAB(BuildTarget.Android);
#elif UNITY_IOS
        LoadEncrypAB(BuildTarget.iOS);
#else
        LoadEncrypAB(BuildTarget.StandaloneWindows);
#endif
    }
    [MenuItem("AssetBundle/Build/Android")]
    static void Build_Android()
    {
        BuildAllAssetBundles(BuildTarget.Android);
    }

    [MenuItem("AssetBundle/Build/iOS")]
    static void Build_iOS()
    {
        BuildAllAssetBundles(BuildTarget.iOS);
    }

    [MenuItem("AssetBundle/Build/Windows")]
    static void Build_Win()
    {
        BuildAllAssetBundles(BuildTarget.StandaloneWindows);
    }

    static void BuildAllAssetBundles(BuildTarget target)
    {
        BuildAllAssetBundles2(target);
        //BuildAllAssetBundles3(target);
    }
    //static void BuildABList(List<AssetBundleBuild> builds, BuildTarget target, string output_path)
    //{
    //    if (!Directory.Exists(output_path))
    //        Directory.CreateDirectory(output_path);
    //    var manifestcommon = BuildPipeline.BuildAssetBundles(output_path, builds.ToArray(),
    //     BuildAssetBundleOptions.AppendHashToAssetBundleName |
    //     BuildAssetBundleOptions.ChunkBasedCompression |
    //     BuildAssetBundleOptions.DeterministicAssetBundle |
    //     BuildAssetBundleOptions.StrictMode, target); 
    //    StringBuilder sb = new StringBuilder();
    //    string[] abscommon = manifestcommon.GetAllAssetBundles();
    //    foreach (var ab in abscommon)
    //    {
    //        var hash = manifestcommon.GetAssetBundleHash(ab).ToString();
    //        var ab_no_hash = ab.Replace("_" + hash + Bundle_PostFix, string.Empty);
    //        var len = new FileInfo(output_path + "/" + ab).Length;
    //        if (ab.ToLower().StartsWith(AssetBundle_Build_List_Name))
    //        {
    //            sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));continue;
    //        }
    //        if (ab.ToLower().Contains("common") && output_path.Contains("common"))
    //        { 
    //            sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
    //        }
    //        else if (!ab.ToLower().Contains("common") && !output_path.Contains("common"))
    //        {
    //            sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
    //        }
    //    }
    //    var manifestName = Path.GetFileName(output_path);
    //    var md5 = Util.md5(sb.ToString());
    //    var newFile = output_path + "/" + AssetBundleManifest_Name + "_" + md5 + Bundle_PostFix;
    //    if (File.Exists(newFile))
    //        File.Delete(newFile);
    //    File.Move(output_path + "/" + manifestName, newFile);//存在一个跟目录名相同的文件没有后缀 这儿当相当于重命名了一次


    //    var manifest_len = new FileInfo(newFile).Length;
    //    TimeSpan timeSpan = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);

    //    var new_sb = new StringBuilder();
    //    new_sb.Append(string.Format("{0}#{1}#{2}\n", Version, new_sb.Length + 1, Convert.ToInt64(timeSpan.TotalMilliseconds)));
    //    new_sb.Append(sb);
    //    new_sb.Append(string.Format("{0}|{1}|{2}\n", AssetBundleManifest_Name, md5, manifest_len));

    //    File.WriteAllText(output_path + "/" + File_List_Name, new_sb.ToString());

    //}

    static void EncrypABList(BuildTarget target)
    {
        var output_path = GetBuildTargetOutputPath(target);
        DirectoryInfo _dirCommon = new DirectoryInfo(output_path);
        foreach (var files in _dirCommon.GetFiles())
        {
            //files.FullName 
            if (files.Extension.ToLower() != ".bundle") continue;
            int EncLen = 1024;
            if (files.Length < 1024) EncLen = (int)files.Length;
            byte[] needEncData = new byte[EncLen];
            byte[] filedata = File.ReadAllBytes(files.FullName);
            Array.Copy(filedata, needEncData, EncLen);
            byte[] afterEncData = AesEncrypt(needEncData, _Enckey);
            //
            Debug.Log(" afterEncData.Length：" + afterEncData.Length);
            byte[] enc_filedata = new byte[filedata.Length + 16];
            Array.Copy(afterEncData, 0, enc_filedata, 0, afterEncData.Length);
            Array.Copy(filedata, EncLen, enc_filedata, EncLen + 16, filedata.Length - EncLen);
            string encpath = files.FullName.Replace(".bundle", ".bundleEnc");
            if (File.Exists(encpath)) File.Delete(encpath);
            FileStream fs = File.Create(encpath);
            fs.Write(enc_filedata, 0, enc_filedata.Length);
            fs.Close();
        }    
    }

    //向量偏移
    private static string _Enckey = "ABCDEFGHIJKLMN0123456789";
    //private static string _key1 = "********ABCDEFGHIJKLMN0123456789******";

    #region AES 加密

    public static byte[] AesEncrypt(byte[] needdata, string key) {
        // string text = "加密算法测试数据测试数据测试数据"; //明文  
        //string keys = "dongbinhuiasxiny";//密钥,128位     
        byte[] keyBytes = Encoding.UTF8.GetBytes(_Enckey);
        byte[] encryptBytes = UnityHelper.AESEncrypt(needdata, keyBytes);

        //string result = Encoding.UTF8.GetString(decryptBytes);//将解密后的结果转换为字符串,也可以将该步骤封装在解密算法中  
        return encryptBytes;
    }

    static void LoadEncrypAB(BuildTarget target)
    {
        var output_path = GetBuildTargetOutputPath(target);
        string _pathCommon = output_path + "/common/bundle_to_asset_map_3dbe1e49d7917fe241d949d6f4a33275.bundleEnc";
        //output_path + "/hall"); 
        if (!File.Exists(_pathCommon))
        {
            Debug.Log(_pathCommon+ " can not find!!!");
            return;
        }
        byte[] filedata = File.ReadAllBytes(_pathCommon);
        int DecLen = 1024 + 16;
        if (filedata.Length < 1024)
        {
            DecLen = (int)filedata.Length;
            return;
        }
        byte[] needDecData = new byte[DecLen];
        Array.Copy(filedata, needDecData, DecLen);
        byte[] keyBytes = Encoding.UTF8.GetBytes(_Enckey);

        byte[] decryptBytes = UnityHelper.AESDecrypt(needDecData, keyBytes); //解密  
        Array.Copy(decryptBytes, filedata, DecLen);

        byte[] aDecData = new byte[filedata.Length-16];
        Array.Copy(decryptBytes,0, aDecData, 0, DecLen - 16);
        Array.Copy(filedata, DecLen, aDecData, DecLen - 16, filedata.Length - DecLen);
        AssetBundle _tempab = AssetBundle.LoadFromMemory(aDecData);
        if (_tempab != null) Debug.LogError("ab dec success!");
        _tempab.LoadAllAssets();
    }
    #endregion
    #region  2.0版
    static void BuildAllAssetBundles2(BuildTarget target)
    {
        LuaTool.CopyLuaFilesToBytes();
        LuaTool.SetLuaAssetBundleName();
        #region 先导入一次文本资源 没有就创建
        var tempdir = Path.GetDirectoryName(AssetBundle_Build_List_Path);
        if (!Directory.Exists(tempdir))
            Directory.CreateDirectory(tempdir);
        File.WriteAllText(AssetBundle_Build_List_Path, "");

        AssetDatabase.Refresh();
        //先导入一次文本资源 
        var importer = AssetImporter.GetAtPath(AssetBundle_Build_List_Path);
        importer.SetAssetBundleNameAndVariant("" + AssetBundle_Build_List_Name + Bundle_PostFix, string.Empty);
        #endregion
        // 创建并填写 Bundles to asset map
        StringBuilder sb = new StringBuilder();
        string[] abNames = AssetDatabase.GetAllAssetBundleNames();
        List<AssetBundleBuild> builds = new List<AssetBundleBuild>();
        foreach (var abName in abNames)
        {
            var abNameNoHashPostfix = abName.EndsWith(Bundle_PostFix) ?
                abName.Substring(0, abName.Length - Bundle_PostFix.Length) : abName;
            var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(abName);

            if (assetPaths != null && assetPaths.Length > 0 && !abName.EndsWith(Bundle_PostFix))
            {
                throw new Exception("No .bundle postfix for AssetBundle " + abName);
            }
            if (abNameNoHashPostfix.Equals(AssetBundle_Build_List_Name))
            {
                foreach (var filepath in assetPaths)
                {
                    if (builds.Count > 0) continue;
                    string[] commomasset = new string[1];
                    commomasset[0] = filepath;
                    builds.Add(new AssetBundleBuild() { assetBundleName = abName, assetNames = commomasset });
                }
            }
            if (!abNameNoHashPostfix.Equals(AssetBundle_Build_List_Name) && assetPaths != null && assetPaths.Length > 0)
            {
                sb.Append(abNameNoHashPostfix).Append("\n");
                foreach (var assetPath in assetPaths)
                {
                    sb.Append("\t").Append(assetPath).Append("\n");
                }
                builds.Add(new AssetBundleBuild() { assetBundleName = abName, assetNames = assetPaths });
            }
        }

        var dir = Path.GetDirectoryName(AssetBundle_Build_List_Path);
        if (!Directory.Exists(dir))
            Directory.CreateDirectory(dir);
        File.WriteAllText(AssetBundle_Build_List_Path, sb.ToString());
        AssetDatabase.Refresh();

        // 开始打包
        var output_path = GetBuildTargetOutputPath(target);
        BuildABList2(builds, target, output_path);//为了方便 不用加前缀文件夹名 子游戏可以走hall打包流程
        Debug.Log("builds done!");



        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();

        Debug.Log("Refresh done!");
    }
    static void BuildABList2(List<AssetBundleBuild> builds, BuildTarget target, string output_path)
    {
        if (!Directory.Exists(output_path))
            Directory.CreateDirectory(output_path);
        var manifests = BuildPipeline.BuildAssetBundles(output_path, builds.ToArray(),
         BuildAssetBundleOptions.AppendHashToAssetBundleName |
         BuildAssetBundleOptions.ChunkBasedCompression |
         BuildAssetBundleOptions.DeterministicAssetBundle |
         BuildAssetBundleOptions.StrictMode, target);
        StringBuilder sb = new StringBuilder();
        string[] abscommon = manifests.GetAllAssetBundles();
        foreach (var ab in abscommon)
        {
            var hash = manifests.GetAssetBundleHash(ab).ToString();
            var ab_no_hash = ab.Replace("_" + hash + Bundle_PostFix, string.Empty);
            var len = new FileInfo(output_path + "/" + ab).Length;
            if (ab.ToLower().StartsWith(AssetBundle_Build_List_Name))
            {
                sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len)); continue;
            }
            if (ab.ToLower().Contains("common/") && output_path.EndsWith("/common_"))
            {
                sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
            }
            else if (ab.ToLower().Contains(SubgameFoldeName+"/") && output_path.EndsWith(string.Format("/{0}_", SubgameFoldeName)))
            {
                sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
            }
            else if (output_path.EndsWith("/hall_"))
            {//ab.ToLower().Contains("hall/") &&  //没有加载特殊标识的归为大厅 子游戏可以借用大厅
                sb.Append(string.Format("{0}|{1}|{2}\n", ab_no_hash, hash, len));
            }
        }
        var manifestName = Path.GetFileName(output_path);
        var md5 = Util.md5(sb.ToString());
        var newFile = output_path + "/" + AssetBundleManifest_Name + "_" + md5 + Bundle_PostFix;
        if (File.Exists(newFile))
            File.Delete(newFile);
        File.Move(output_path + "/" + manifestName, newFile);//存在一个跟目录名相同的文件没有后缀 这儿当相当于重命名了一次


        var manifest_len = new FileInfo(newFile).Length;
        TimeSpan timeSpan = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);

        var new_sb = new StringBuilder();
        new_sb.Append(string.Format("{0}#{1}#{2}\n", Version, new_sb.Length + 1, Convert.ToInt64(timeSpan.TotalMilliseconds)));
        new_sb.Append(sb);
        new_sb.Append(string.Format("{0}|{1}|{2}\n", AssetBundleManifest_Name, md5, manifest_len));

        File.WriteAllText(output_path + "/" + File_List_Name, new_sb.ToString());

    }

    //static void BuildAllAssetBundles3(BuildTarget target)
    //{
    //    SubgameFoldeName = "subgame001";
    //    #region 先导入一次文本资源 没有就创建 

    //    var tempdirSubGame = Path.GetDirectoryName(AB_Build_List_PathSubgame);//捕鱼特有 其他他游戏走hall流程
    //    if (!Directory.Exists(tempdirSubGame))
    //        Directory.CreateDirectory(tempdirSubGame);
    //    File.WriteAllText(AB_Build_List_PathSubgame, "");
    //    AssetDatabase.Refresh();
    //    //先导入一次文本资源  
    //    var importerFish = AssetImporter.GetAtPath(AB_Build_List_PathSubgame);
    //    importerFish.SetAssetBundleNameAndVariant("" + AssetBundle_Build_List_Name + Bundle_PostFix, string.Empty);
    //    #endregion
         
    //    StringBuilder sbfish = new StringBuilder();
    //    string[] abNames = AssetDatabase.GetAllAssetBundleNames(); 
    //    List<AssetBundleBuild> buildsSubGame = new List<AssetBundleBuild>();
    //    foreach (var abName in abNames)
    //    {
    //        var abNameNoHashPostfix = abName.EndsWith(Bundle_PostFix) ?
    //            abName.Substring(0, abName.Length - Bundle_PostFix.Length) : abName;
    //        var assetPaths = AssetDatabase.GetAssetPathsFromAssetBundle(abName);

    //        if (assetPaths != null && assetPaths.Length > 0 && !abName.EndsWith(Bundle_PostFix))
    //        {
    //            throw new Exception("No .bundle postfix for AssetBundle " + abName);
    //        }
    //        if (abNameNoHashPostfix.Equals(AssetBundle_Build_List_Name))
    //        {
    //            foreach (var filepath in assetPaths)
    //            {
    //                if (filepath.ToLower().Contains(SubgameFoldeName))
    //                {
    //                    if (buildsSubGame.Count > 0) continue;
    //                    string[] fishasset = new string[1];
    //                    fishasset[0] = filepath;
    //                    buildsSubGame.Add(new AssetBundleBuild() { assetBundleName = abName, assetNames = fishasset });
    //                }

    //            }
    //        }
    //        if (!abNameNoHashPostfix.Equals(AssetBundle_Build_List_Name) && assetPaths != null && assetPaths.Length > 0)
    //        {
    //            if (abNameNoHashPostfix.ToLower().Contains(SubgameFoldeName))
    //            {
    //                sbfish.Append(abNameNoHashPostfix).Append("\n");
    //                foreach (var assetPath in assetPaths)
    //                {
    //                    sbfish.Append("\t").Append(assetPath).Append("\n");
    //                }
    //                buildsSubGame.Add(new AssetBundleBuild() { assetBundleName = abName, assetNames = assetPaths });
    //            }
    //        }
    //    } 
      
    //    var dirfish = Path.GetDirectoryName(AB_Build_List_PathSubgame);
    //    if (!Directory.Exists(dirfish))
    //        Directory.CreateDirectory(dirfish);
    //    File.WriteAllText(AB_Build_List_PathSubgame, sbfish.ToString());
    //    AssetDatabase.Refresh();
         
    //    var output_path = GetBuildTargetOutputPath(target);  

    //    BuildABList2(buildsSubGame, target, output_path + string.Format("/{0}_", SubgameFoldeName)); 
    //    Debug.Log(string.Format("builds  {0} done! ", SubgameFoldeName));

    //    AssetDatabase.Refresh();
    //    AssetDatabase.SaveAssets();

    //    Debug.Log("Refresh done!");
    //}
    #endregion
}
