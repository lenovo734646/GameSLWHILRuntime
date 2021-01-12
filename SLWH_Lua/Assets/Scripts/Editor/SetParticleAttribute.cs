using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEditor;
using UnityEngine;


public class SetParticleAttribute : EditorWindow
{
    public Transform root;
    public string targetName;
    bool bLoop = false;
    //
    string textValue = "";
    //
    Color color;
    //
    float scale = 1;

    // 角度渐进
    int startRotate = 0;
    int gapRotate = 0;
    bool xAxis = false;
    bool yAxis = true;
    bool zAxis = false;
    //
    SetParticleAttribute()
    {
        titleContent = new GUIContent("3D圆形布局");
    }

    [MenuItem("Tools/设置Root下所有粒子属性")]
    static void ShowWindow()
    {
        Debug.Log("SetParticleAttribute ShowWindows");
        //获取窗口并打开
        EditorWindow.GetWindow((typeof(SetParticleAttribute)));
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
        GUILayout.Space(10);
        targetName = EditorGUILayout.TextField("名字筛选", targetName);
        bLoop = GUILayout.Toggle(bLoop, "粒子是否循环");
        if (GUILayout.Button("设置"))
        {
            SetParticlesLoop(bLoop, targetName);
        }

        GUILayout.Space(20);
        GUILayout.Label("设置Root下所有TMP_Text的值");
        GUILayout.Space(10);
        textValue = GUILayout.TextField(textValue);
        GUILayout.Space(10);
        if (GUILayout.Button("设置"))
        {
            SetTMPTextValue(textValue, targetName);
        }

        GUILayout.Space(20);
        GUILayout.Label("设置Root下所有TMP_Text的颜色");
        GUILayout.Space(10);
        color = EditorGUILayout.ColorField(color);
        GUILayout.Space(10);
        if (GUILayout.Button("设置"))
        {
            SetTMPTextColor(color, targetName);
        }

        GUILayout.Space(10);
        GUILayout.Label("逆向重新排列子对象，并重新命名");
        if (GUILayout.Button("反向重命名"))
        {
            var count = root.childCount;
            for (var i = 0; i < count; i++)
            {
                root.GetChild(i).name = (count - i).ToString();
            }

            for (var i = 0; i < count; i++)
            {
                root.GetChild(0).SetSiblingIndex(count - i - 1); // 设置层级关系SetAsFirstSibling()最上SetAsLastSibling()最下
            }
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

    TMP_Text[] GetTMPTextTargets(string targetName)
    {
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

