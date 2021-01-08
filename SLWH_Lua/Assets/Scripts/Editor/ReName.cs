using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class ReNameWindow : EditorWindow
{
    string desc = "对根节点内的所有子节按“基本名字+名字序号”规则进行重命名，需要默认从0开始，按顺序累计+1";
    [Label("需要重命名的根节点")]
    public Transform root;
    [Label("基本名字")]
    public string baseName = "";
    [Label("名字序号，累计+1")]
    public int index = 0;

    // 复制
    [Label("复制源,选中即可，也可拖放到此处")]
    public GameObject sourceGameObject;
    [Label("复制次数")]
    public int count = 1;
    ReNameWindow()
    {
        this.titleContent = new GUIContent("重命名root下所有子对象");
    }
    [MenuItem("Tools/ReName")]
    static void ShowWindow()
    {
        //获取窗口并打开
        EditorWindow.GetWindow((typeof(ReNameWindow)));
    }

    private void OnGUI()
    {
        GUILayout.BeginVertical();
        //绘制标题
        GUILayout.Space(10);
        GUI.skin.label.fontSize = 18;
        GUI.skin.label.alignment = TextAnchor.MiddleCenter;
        GUILayout.Label("重命名窗口");



        ////绘制当前正在编辑的场景
        //GUILayout.Space(10);
        //GUI.skin.label.fontSize = 12;
        //GUI.skin.label.alignment = TextAnchor.UpperLeft;
        //GUILayout.Label("Currently Scene:" + EditorSceneManager.GetActiveScene().name);

        ////绘制当前时间
        //GUILayout.Space(10);
        //GUILayout.Label("Time:" + System.DateTime.Now);

        //绘制对象
        GUILayout.Space(10);
        root = (Transform)EditorGUILayout.ObjectField("根节点", root, typeof(Transform), true);
        //绘制文本
        GUILayout.Space(10);
        baseName = EditorGUILayout.TextField("基本名字:", baseName);
        //绘制文本
        GUILayout.Space(10);
        index = int.Parse(EditorGUILayout.TextField("起始序号:", index.ToString()));

        // 复制功能
        // 复制源
        GUILayout.Space(10);
        sourceGameObject = (GameObject)EditorGUILayout.ObjectField("复制源", sourceGameObject, typeof(GameObject), true);
        // 复制数量
        GUILayout.Space(10);
        count = int.Parse(EditorGUILayout.TextField("复制数量:", count.ToString()));

        //绘制描述文本区域
        GUILayout.Space(10);
        GUILayout.BeginHorizontal();
        GUILayout.Label("Description", GUILayout.MaxWidth(80));
        desc = EditorGUILayout.TextArea(desc, GUILayout.MaxHeight(75));
        GUILayout.EndHorizontal();

        EditorGUILayout.Space();

        //添加名为"Save Bug"按钮，用于调用SaveBug()函数
        if (GUILayout.Button("重命名"))
        {
            ReName(root);
        }

        if (GUILayout.Button("复制对象并重命名"))
        {
            var go = Selection.activeGameObject;
            if (!go)
                go = sourceGameObject;
            if(!go)
            {
                Debug.LogError("请选择或设置复制对象...");
                return;
            }

            GameObject ret = null;
            for(var i = 0; i < count; i ++)
            {
                ret = EditorWindowUtil.DuplicatePrefabInstance(go);
            }
            ReName(ret.transform.parent);
            Debug.Log("复制成功...");
        }

        ////复制指定路径的资源文件到一个新的路径, 所有的路径都是相对于工程目录文件， 例如Assets/MyTextures/hello.png
        //if (GUILayout.Button("复制对象"))
        //{
        //    AssetDatabase.CopyAsset(oldPath, newPath);
        //    AssetDatabase.Refresh();
        //}

        // 复制prefab 没用明白
        //if (GUILayout.Button("复制prefab"))
        //{
        //    //Debug.Log(Selection.activeGameObject);
        //    //Object prefabRoot = PrefabUtility.GetCorrespondingObjectFromSource(Selection.activeGameObject);
        //    //Debug.Log(prefabRoot);
        //    //PrefabUtility.InstantiatePrefab(prefabRoot);
        //}


        GUILayout.EndVertical();
    }

    void ReName(Transform tf)
    {
        //foreach(Transform child in root)
        //{

        //}
        for(var i = 0; i < tf.childCount; i ++)
        {
            int t = index+i;
            tf.GetChild(i).name = baseName + t.ToString();
        }
        Debug.Log("重命名成功...");
    }
}
