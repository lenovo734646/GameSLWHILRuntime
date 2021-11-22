using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CustomKeys
{
    [MenuItem("Custom快捷键/打开LoginScene并运行(停止) _F5")]
    static void OpenLoginSceneAndRun()
    {
        if (EditorApplication.isPlaying)
        {
            EditorApplication.isPlaying = false;
        }
        else
        {
            AssetDatabase.SaveAssets();
            EditorSceneManager.SaveOpenScenes();
            EditorSceneManager.OpenScene("Assets/Scenes/LoginScene.unity");
            EditorApplication.isPlaying = true;
        }
    }

    [MenuItem("Custom快捷键/暂停(恢复) _F6")]
    static void Pause()
    {
        EditorApplication.isPaused = !EditorApplication.isPaused;
    }

    [MenuItem("Custom快捷键/打开LoginScene并运行 _F4")]
    static void OpenMainScene()
    {
        if (EditorApplication.isPlaying)
        {
            EditorApplication.isPlaying = false;
        }
        AssetDatabase.SaveAssets();
        EditorSceneManager.SaveOpenScenes();
        EditorSceneManager.OpenScene("Assets/Scenes/MainScene.unity");
    }
}