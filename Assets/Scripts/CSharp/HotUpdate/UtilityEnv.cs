using System;
using System.IO;
using System.Text;
using UnityEngine;

public static class UtilityEnv
{
    // Bundle Build path config
    public const string Game_Name = "ShuiHuZhuan";
    public const string Version = "1.0.0.0";
    public const string Bundle_PostFix = ".bundle";
    public const string Lua_Src_Path = "Assets/Scripts/Lua";
    public const string Lua_Output_Path = "Assets/Lua";
    public const string Lua_Bundle_Name = "Lua";
    public const string AssetBundle_Build_List_Path = "Assets/Editor/BundleToAssetsMap.txt"; // 资源文件列表
    public const string AssetBundle_Build_List_Name = "bundle_to_asset_map";
    public const string AssetBundleManifest_Name = "assetbundle_manifest";
    public const string File_List_Name = "ab_file_list.ftxt";

    /// <summary>
    /// 小游戏目录
    /// </summary>
    public const string GameDataPath = "game";
    /// <summary>
    /// 更新数据临时存储根目录
    /// </summary>
    public const string Url_Origin = "Game/";

    #region lua file Encrype/Decript
    private static readonly char[] key = "Secret".ToCharArray();
    public static byte[] Encrypt(byte[] bytes)
    {
        var len = key.Length;
        for (int i = 0; i < bytes.Length; i++)
        {
            var j = i % len;
            bytes[i] ^= (byte)key[j];
        }
        return bytes;
    }

    public static byte[] Decrypt(byte[] bytes)
    {
        return Encrypt(bytes);
    }
    #endregion

    #region String Concat
    private static readonly StringBuilder _sb = new StringBuilder();    // 字符串连接缓存
    public static string StringConcat(string param1, string param2)
    {
        _sb.Length = 0;
        _sb.Append(param1);
        _sb.Append(param2);

        var ret = _sb.ToString();
        _sb.Length = 0;
        return ret;
    }

    public static string StringConcat(string param1, string param2, string param3)
    {
        _sb.Length = 0;
        _sb.Append(param1);
        _sb.Append(param2);
        _sb.Append(param3);

        var ret = _sb.ToString();
        _sb.Length = 0;
        return ret;
    }

    public static string StringConcat(string param1, string param2, string param3, string param4)
    {
        _sb.Length = 0;
        _sb.Append(param1);
        _sb.Append(param2);
        _sb.Append(param3);
        _sb.Append(param4);

        var ret = _sb.ToString();
        _sb.Length = 0;
        return ret;
    }


    #endregion

    #region ReadFile 
    public static string ReadFile(string path)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        string header = Application.streamingAssetsPath + "/";
        if (path.StartsWith(header))
        {
            try
            {
                object[] args = { path.Substring(header.Length) };
                AndroidJavaClass jc = new AndroidJavaClass("com.");
                IntPtr methodID = AndroidJNIHelper.GetMethodID<byte[]>(jc.GetRawClass(), "readAsset", args, true);
                jvalue[] array = AndroidJNIHelper.CreateJNIArgArray(args);
                try
                {
                    IntPtr array2 = AndroidJNI.CallStaticObjectMethod(jc.GetRawClass(), methodID, array);
                    if (array2 != IntPtr.Zero)
                    {
                        byte[] ret = AndroidJNIHelper.ConvertFromJNIArray<byte[]>(array2);
                        return Encoding.UTF8.GetString(ret);
                    }
                }
                finally
                {
                    AndroidJNIHelper.DeleteJNIArgArray(args, array);
                }
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }

            return null;
        }
#endif
        return File.ReadAllText(path);
    }
    #endregion
}
