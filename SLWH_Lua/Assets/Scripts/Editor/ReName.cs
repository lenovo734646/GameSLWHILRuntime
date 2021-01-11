using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class ReNameWindow : EditorWindow
{
    [Label("需要重命名的根节点")]
    public Transform root;

    [Label("是否使用原始文件名")]
    public bool bUserOrigin = true;
    [Label("保留原始文件名起点")]
    public int startIndex = 0;
    [Label("保留原始文件名长度")]
    public int len = 0;
    [Label("名字固定字段")]
    public string baseName = "";
    


    [Label("名字序号，累计+1")]
    public int index = 0;
    [Label("序号位数（不足补0）")]
    public int indexCount = 1;
    [Label("序号和名字分隔符")]
    public string gapStr = "";
    [Label("是否序号在前")]
    public bool bPrefix = false;
    

    // 复制
    [Label("复制源,选中即可，也可拖放到此处")]
    public GameObject sourceGameObject;
    [Label("复制次数")]
    public int count = 1;
    ReNameWindow()
    {
        this.titleContent = new GUIContent("重命名root下所有子对象");
    }
    [MenuItem("Tools/重命名和复制")]
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

        // 是否使用原始文件名
        bUserOrigin = EditorGUILayout.Toggle("是否使用原始文件名", bUserOrigin);
        //
        if(!bUserOrigin)
        {
            // 名字固定字段
            baseName = EditorGUILayout.TextField("名字固定字段:", baseName);
        }
        else
        {
            // 保留原始文件名长度
            startIndex = EditorGUILayout.IntField("保留原始文件名起点:", startIndex);
            // 保留原始文件名长度
            len = EditorGUILayout.IntField("保留原始文件名长度:", len);
        }

        // 名字起始序号
        index = EditorGUILayout.IntField("起始序号:", index);
        // 序号位数（不足补0）
        indexCount = EditorGUILayout.IntField("序号位数:", indexCount);
        // 序号分隔符
        gapStr = EditorGUILayout.TextField("序号和名字分隔符:", gapStr);
        // 序号加在前面
        bPrefix = EditorGUILayout.Toggle("序号加在前面", bPrefix);

        //添加名为"Save Bug"按钮，用于调用SaveBug()函数
        if (GUILayout.Button("重命名"))
        {
            ReName(root);
        }

        // 复制功能
        GUILayout.Space(20);
        GUILayout.BeginHorizontal();
        GUILayout.Label("复制功能：", GUILayout.MaxWidth(80));
        EditorGUILayout.TextArea("设置复制源，设置复制数量", GUILayout.MaxHeight(75));
        GUILayout.EndHorizontal();
        // 复制源
        GUILayout.Space(10);
        sourceGameObject = (GameObject)EditorGUILayout.ObjectField("复制源", sourceGameObject, typeof(GameObject), true);
        // 复制数量
        GUILayout.Space(10);
        count = EditorGUILayout.IntField("复制数量:", count);


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
        // 


        //
        for(var i = 0; i < tf.childCount; i ++)
        {
            int t = index+i;
            var name = tf.GetChild(i).name;
            if(bUserOrigin)
            {
                if (len > 0)
                    name = name.Substring(startIndex, len);
                else
                    name = name.Substring(startIndex);
            }
            else
            {
                name = baseName;
            }

            var indexStr = t.ToString().PadLeft(indexCount, '0');

            if (bPrefix)
                name = indexStr+ gapStr + name;
            else
                name = name + gapStr + indexStr;

            tf.GetChild(i).name = name;
        }
        Debug.Log("重命名成功...");
    }
}
