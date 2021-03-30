using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEditor;
using UnityEngine;


public class SetObjectAttribute : EditorWindow
{
    public Transform root;
    public string targetName;
    bool bLoop = false;
    // 设置值
    string textValue = "";
    // 设置颜色
    Color color;
    // 替换TMP_Text字体
    TMP_FontAsset targetFont;
    //
    float scale = 1;

    // 角度渐进
    int startRotate = 0;
    int gapRotate = 0;
    bool xAxis = false;
    bool yAxis = true;
    bool zAxis = false;
    //
    SetObjectAttribute()
    {
        titleContent = new GUIContent("通用小工具（脚本名：SetObjectAttribute）");
    }

    [MenuItem("Tools/设置Root下所有Object属性")]
    static void ShowWindow()
    {
        Debug.Log("SetParticleAttribute ShowWindows");
        //获取窗口并打开
        EditorWindow.GetWindow((typeof(SetObjectAttribute)));
    }

    private void OnEnable()
    {
        Debug.Log("SetParticleAttribute OnEnable");
    }

    private void OnGUI()
    {
        GUILayout.BeginVertical();

        GUILayout.Label("设置Root下所有粒子属性");
        root = (Transform)EditorGUILayout.ObjectField("根节点", root, typeof(Transform), true);
        if (root == null)
        {
            root = Selection.activeTransform;
            if (root == null)
            {
                Debug.LogError("请设置或选中根节点");
                return;
            }
        }
        GUILayout.Space(10);
        targetName = EditorGUILayout.TextField("名字筛选", targetName);
        bLoop = GUILayout.Toggle(bLoop, "粒子是否循环");
        if (GUILayout.Button("设置"))
        {
            SetParticlesLoop(bLoop, targetName);
            Debug.Log("设置完毕");
        }

        GUILayout.Label("==============================================================");
        GUILayout.Label("==============================================================");
        GUILayout.Label("设置Root下所有TMP_Text的值");
        GUILayout.Space(5);
        textValue = GUILayout.TextField(textValue);
        if (GUILayout.Button("设置"))
        {
            SetTMPTextValue(textValue, targetName);
            Debug.Log("设置完毕");
        }

        GUILayout.Space(10);
        GUILayout.Label("-----------------------------------------------------------------");
        GUILayout.Label("设置Root下所有TMP_Text的颜色");
        GUILayout.Space(5);
        color = EditorGUILayout.ColorField(color);
        if (GUILayout.Button("设置"))
        {
            SetTMPTextColor(color, targetName);
            Debug.Log("设置完毕");
        }

        GUILayout.Space(10);
        GUILayout.Label("-----------------------------------------------------------------");
        GUILayout.Label("设置Root下所有TMP_Text的字体");
        GUILayout.Space(5);
        targetFont = (TMP_FontAsset)EditorGUILayout.ObjectField("被替换字体", targetFont, typeof(TMP_FontAsset), true);
        if (GUILayout.Button("设置"))
        {
            SetTMPTextFont(targetFont, targetName);
            Debug.Log("设置完毕");
        }


        GUILayout.Space(20);
        GUILayout.Label("设置Root下所有targetNameGameObject的Scale值");
        GUILayout.Space(10);
        scale = float.Parse(GUILayout.TextField(scale.ToString()));
        GUILayout.Space(10);
        if (GUILayout.Button("设置"))
        {
            SetScale(scale, targetName);
        }

        GUILayout.Space(20);
        GUILayout.Label("设置Root子对象rotate渐进");
        GUILayout.Space(10);
        startRotate = EditorGUILayout.IntField("渐进起始角度", startRotate);
        gapRotate = EditorGUILayout.IntField("渐进角度", gapRotate);
        xAxis = EditorGUILayout.Toggle("X轴", xAxis);
        yAxis = EditorGUILayout.Toggle("Y轴", yAxis);
        zAxis = EditorGUILayout.Toggle("Z轴", zAxis);
        if (GUILayout.Button("设置"))
        {
            SetRotate();
        }

        GUILayout.EndVertical();
    }

    void SetRotate()
    {
        if (gapRotate == 0)
        {
            Debug.LogError("角度间隔为0");
            return;
        }
        for(var i = 0; i < root.transform.childCount; i++)
        {
            var child = root.transform.GetChild(i);
            var x = startRotate + gapRotate * i;
            var y = startRotate + gapRotate * i;
            var z = startRotate + gapRotate * i;

            Vector3 rot = child.eulerAngles;
            if (xAxis)
                rot.x = x;
            if (yAxis)
                rot.y = y;
            if (zAxis)
                rot.z = z;
            child.eulerAngles = rot;
        }
    }

    void SetScale(float v, string targetName = null)
    {
        var trans = GetTransforms(targetName);
        foreach (var t in trans)
        {
            t.localScale = new Vector3(scale, scale, scale);
        }
    }

    void SetParticlesLoop(bool bLoop, string targetName = null)
    {
        var pars = GetParticleTargets(targetName);
        foreach (var par in pars)
        {
            var m = par.main;
            m.loop = bLoop;
        }
    }

    void SetTMPTextValue(string v, string targetName = null)
    {
        var tmpTexts = GetTMPTextTargets(targetName);
        foreach (var text in tmpTexts)
        {
            text.text = v;
        }
    }

    void SetTMPTextColor(Color color, string targetName = null)
    {
        var tmpTexts = GetTMPTextTargets(targetName);
        foreach (var text in tmpTexts)
        {
            text.color = color;
        }
    }

    void SetTMPTextFont(TMP_FontAsset font, string targetName = null)
    {
        var tmpTexts = GetTMPTextTargets(targetName);
        foreach (var text in tmpTexts)
        {
            text.font = font;
        }
    }

    TMP_Text[] GetTMPTextTargets(string targetName)
    {
        if (root == null)
            root = Selection.activeTransform;
        var targetTexts = root.GetComponentsInChildren<TMP_Text>();
        if (string.IsNullOrEmpty(targetName))
            return targetTexts;
        else
        {
            var list = from t in targetTexts where t.name == targetName select t;
            return list.ToArray();
        }
    }

    ParticleSystem[] GetParticleTargets(string targetName)
    {
        var targetTexts = root.GetComponentsInChildren<ParticleSystem>();
        if (string.IsNullOrEmpty(targetName))
            return targetTexts;
        else
        {
            var list = from t in targetTexts where t.name == targetName select t;
            return list.ToArray();
        }
    }

    Transform[] GetTransforms(string targetName)
    {
        var objs = root.transform.GetComponentsInChildren<Transform>();
        var list = from t in objs where t.name == targetName select t;
        return list.ToArray();
    }
}

