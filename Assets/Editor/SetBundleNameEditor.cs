using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class SetBundleNameEditor : EditorWindow
{
    //string desc = "设置所选文件夹下所有asset的bundle包名";
    // AB包名字，可带路径，需自带扩展名
    string bundleName;
    public List<string> pathList = new List<string>();
    SetBundleNameEditor()
    {
        this.titleContent = new GUIContent("设置所选文件夹下所有asset的bundle包名");
    }
    [MenuItem("Tools/设置Bundle名字")]
    static void ShowWindow()
    {
        //获取窗口并打开
        EditorWindow.GetWindow(typeof(SetBundleNameEditor));
    }
    private void Update()
    {

    }
    private void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Space(10);
        bundleName = EditorGUILayout.TextField("Bundle名字不用带扩展:", bundleName, GUILayout.Width(300));

        GUILayout.Space(20);
        //将上面的框作为文本输入框  
        Rect rect = EditorGUILayout.GetControlRect(GUILayout.Width(300));
        EditorGUI.TextField(rect, "拖放需要设置BundleName的文件或文件夹到此");
        //如果鼠标正在拖拽中或拖拽结束时，并且鼠标所在位置在文本输入框内  
        if ((Event.current.type == EventType.DragUpdated
          || Event.current.type == EventType.DragExited)
          && rect.Contains(Event.current.mousePosition))
        {
            //改变鼠标的外表  
            DragAndDrop.visualMode = DragAndDropVisualMode.Generic;
            if (DragAndDrop.paths != null && DragAndDrop.paths.Length > 0)
            {
                foreach (var path in DragAndDrop.paths)
                {
                    if (!string.IsNullOrEmpty(path))
                    {
                        if (!pathList.Contains(path))
                            pathList.Add(path);
                    }
                }
                return; // OnGUI函数中，不可以同时做改动pathList和绘制pathList会报错，这里return下一帧做绘制
            }
        }



        foreach (var p in pathList)
        {
            GUILayout.Label(p, GUILayout.Width(300));
        }

        GUILayout.Space(10);
        if (GUILayout.Button("设置"))
        {
            SetBundleName(bundleName+ ".bundle");
            pathList.Clear();
            AssetDatabase.Refresh();
            Debug.Log("设置完毕");
        }
        GUILayout.Space(10);
        if (GUILayout.Button("清空目录"))
        {
            pathList.Clear();
        }

        GUILayout.Space(10);
        if (GUILayout.Button("清空所选文件夹下资源的Bundle标签"))
        {
            SetBundleName("");
        }
        GUILayout.EndVertical();

    }

    public void SetBundleName(string bundleNameNoEx)
    {
        var guids = AssetDatabase.FindAssets("", pathList.ToArray());
        foreach (var guid in guids)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            SetAssetBundleName(assetPath, bundleNameNoEx);
        }
        //var selectGuids = Selection.assetGUIDs;

    }

    void SetAssetBundleName(string folderPath, string bundleName)
    {
        var guids = AssetDatabase.FindAssets("", new string[] { folderPath });
        foreach (var guid in guids)
        {
            var assetPath = AssetDatabase.GUIDToAssetPath(guid);
            var importer = AssetImporter.GetAtPath(assetPath);
            //Debug.Log("importer = "+ importer.GetType());
            if (importer != null && importer.GetType() != typeof(UnityEditor.MonoImporter))
            {

                importer.SetAssetBundleNameAndVariant(bundleName, string.Empty);
                Debug.Log($"已设置：{assetPath}");
            }
        }
    }

    void DrawPathList()
    {
        //GUILayout.BeginVertical();
        foreach (var path in pathList)
        {
            GUILayout.Label(path, GUILayout.Width(300));
        }
        //GUILayout.EndVertical();
    }
}
