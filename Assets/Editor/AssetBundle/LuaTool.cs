using UnityEngine;
using UnityEditor;
using System.IO;

public class LuaTool
{
    public static void CopyLuaFilesToBytes()
    {
        var guids = AssetDatabase.FindAssets("", new string[] { UtilityEnv.Lua_Output_Path });
        foreach (var guid in guids)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            if (File.Exists(assetPath))
                File.Delete(assetPath);
        }

        guids = AssetDatabase.FindAssets("", new string[] { UtilityEnv.Lua_Src_Path });
        foreach (var guid in guids)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            if (assetPath.EndsWith(".lua"))
            {
                var newAssetPath = assetPath.Replace(UtilityEnv.Lua_Src_Path, UtilityEnv.Lua_Output_Path) + ".bytes";
                var dir = Path.GetDirectoryName(newAssetPath);
                Directory.CreateDirectory(dir);
                byte[] buffer = File.ReadAllBytes(assetPath);
                File.WriteAllBytes(newAssetPath, UtilityEnv.Encrypt(buffer));
            }
        }

        AssetDatabase.Refresh();
        Debug.Log("Copy lua files over");
    }

    public static void SetLuaAssetBundleName()
    {
        var guids = AssetDatabase.FindAssets("", new string[] { UtilityEnv.Lua_Output_Path });
        foreach (var guid in guids)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            var importer = AssetImporter.GetAtPath(assetPath);
            if (importer != null)
            {
                importer.SetAssetBundleNameAndVariant(UtilityEnv.Lua_Bundle_Name + UtilityEnv.Bundle_PostFix, string.Empty);
            }
        }
    }
}