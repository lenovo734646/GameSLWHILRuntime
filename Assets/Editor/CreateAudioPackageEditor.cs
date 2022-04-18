using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CreateAudioPackageEditorWindow : EditorWindow
{
    [Label("音频资源目录")]
    public string resPath = "";
    [Label("Prefab 名字")]
    public string prefabName = "";

    CreateAudioPackageEditorWindow()
    {
        this.titleContent = new GUIContent("创建AudioPackage");
    }


    [MenuItem("Tools/Audio/创建AudioPackage")]
    static void ShowWindow()
    {
        //获取窗口并打开
        EditorWindow.GetWindow((typeof(CreateAudioPackageEditorWindow)));
    }

    private void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Space(10);

        //将上面的框作为文本输入框  
        Rect rect = EditorGUILayout.GetControlRect(GUILayout.Width(600));
        resPath = EditorGUI.TextField(rect, "音频资源目录", resPath);
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
                        resPath = path+"/";
                        //Debug.Log("resPath = " + resPath);
                        break;
                    }
                }
            }
        }
       
        // 
        prefabName = EditorGUILayout.TextField("Prefab Name:", prefabName);

        GUILayout.Space(10);
        if (GUILayout.Button("创建"))
        {
            ToAudio.Tools.Generate_AudioInfo(resPath, prefabName);
        }
        GUILayout.Label("生成的Prefab保存在 Assets/AssetsFinal/目录下");
        GUILayout.EndVertical();
    }
}
