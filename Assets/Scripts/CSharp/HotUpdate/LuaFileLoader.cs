using System.IO;
using UnityEngine;

public class LuaFileLoader
{
    private string _searchPath;

    public LuaFileLoader(string searchPath)
    {
        _searchPath = searchPath;
    }

    public byte[] LoadFile(ref string filePath)
    {
        var path = StringUtil.Concat(_searchPath, filePath.Replace('.', '/'), ".lua");
       // Debug.Log("path="+path);
        if (File.Exists(path))
            return File.ReadAllBytes(path);
        return null;
    }
}