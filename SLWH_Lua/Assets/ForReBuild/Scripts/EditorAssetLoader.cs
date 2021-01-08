using UnityEngine;
using System;
using Object = UnityEngine.Object;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif


public interface ILoader {
    TextAsset LoadTextAsset(string assetPath, bool logError = true);
    T LoadAsset<T>(string assetPath, bool logError = true) where T : Object;


    Object LoadAsset(string assetPath, Type type, bool logError = false);
    void LoadAssetAsync(MonoBehaviour coroutineStatrer, 
        Action<Object> onDone,
        Action<object> onProgeress,
        Type type, string assetPath, bool logError = false);
    void LoadAllAssetAsync(MonoBehaviour coroutineStatrer,
        Action<List<object>> onDone,
        Action<object> onProgeress,
        string assetPath, bool logError = false);
    /// <summary>
    /// 此次释放需要明确没有引用才能释放 因为是强制释放正在使用的也会释放
    /// </summary>
    /// <param name="assetPath"></param>
    /// <returns></returns>
    bool UnloadTrueAB(string assetPath);
}

public class EditorAssetLoader: ILoader {

    public TextAsset LoadTextAsset(string assetPath, bool logError = true) {
        return LoadAsset<TextAsset>(assetPath, logError);
    }
    public T LoadAsset<T>(string assetPath, bool logError = true) where T : Object {
        return (T)LoadAsset(assetPath, typeof(T), logError);
    }

    public static Object LoadEditorAsset(string assetPath, Type type, bool logError) {
#if UNITY_EDITOR
        var importer = AssetImporter.GetAtPath(assetPath);
        if (importer == null) {
            if (logError)
                Debug.LogError("No Asset:" + assetPath);
            return null;
        }

        if (string.IsNullOrEmpty(importer.assetBundleName)) {
            if (logError)
                Debug.LogError("No AssetBundle:" + assetPath);
        }

        return AssetDatabase.LoadAssetAtPath(assetPath, type);
#else
        Debug.LogError("EditorAssetLoader can not run in Player mode");
        return null;
#endif
    }

    public static Object[] LoadEditorAssetAll(string assetPath, bool logError) {
#if UNITY_EDITOR
        var importer = AssetImporter.GetAtPath(assetPath);
        if (importer == null) {
            if (logError)
                Debug.LogError("No Asset:" + assetPath);
            return null;
        }

        if (string.IsNullOrEmpty(importer.assetBundleName)) {
            if (logError)
                Debug.LogError("No AssetBundle:" + assetPath);
        }

        return AssetDatabase.LoadAllAssetsAtPath(assetPath);
#else
        Debug.LogError("EditorAssetLoader can not run in Player mode");
        return null;
#endif
    }

    public Object LoadAsset(string assetPath, Type type, bool logError = false) {
        if (string.IsNullOrEmpty(assetPath))
            return null;

        return LoadEditorAsset(assetPath, type, logError);
    }

    public void LoadAssetAsync(MonoBehaviour coroutineStatrer, 
        Action<Object> onDone,
        Action<object> onProgeress,
        Type type, string assetPath, bool logError = false) {
        onDone(LoadEditorAsset(assetPath, type, logError));
    }

    public void LoadAllAssetAsync(MonoBehaviour coroutineStatrer, 
        Action<List<object>> onDone, Action<object> onProgeress, string assetPath, bool logError = false) {
        onDone(new List<object>(LoadEditorAssetAll(assetPath, logError)));
    }
    public bool UnloadTrueAB(string assetPath)
    {
        
        return false;
    }
}
