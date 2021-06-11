using UnityEditor;
using UnityEngine;


public class RadialLayout : EditorWindow
{
    public float fDistance = 20f;
    public float MinAngle = 0f;
    public float MaxAngle = 360f;
    public float StartAngle = -90f;
    public Transform layoutRoot;

    public int indexStart = 0;
    public int indexEnd = 0;
    // 
    public bool bReverse = false;


    RadialLayout()
    {
        titleContent = new GUIContent("3D圆形布局");
    }

    [MenuItem("Tools/车标布局")]
    static void ShowWindow()
    {
        //获取窗口并打开
        EditorWindow.GetWindow((typeof(RadialLayout)));
    }

    private void OnGUI()
    {
        GUILayout.BeginVertical();
        
        //GUI.skin.label.fontSize = 18;
        //GUI.skin.label.alignment = TextAnchor.MiddleCenter;
        //GUILayout.Label("车标布局窗口");
        //fDistance = float.Parse(GUILayout.TextField("半径", fDistance.ToString()));
        GUILayout.Space(10);
        layoutRoot = (Transform)EditorGUILayout.ObjectField("根节点", layoutRoot, typeof(Transform), true);
        GUILayout.Space(20);

        MinAngle = float.Parse(EditorGUILayout.TextField("最小角度:", MinAngle.ToString()));
        MinAngle = GUILayout.HorizontalSlider(MinAngle, 0, 360, new[] { GUILayout.Width(100) });
        GUILayout.Space(20);

        MaxAngle = float.Parse(EditorGUILayout.TextField("最大角度:", MaxAngle.ToString()));
        MaxAngle = GUILayout.HorizontalSlider(MaxAngle, 0, 360, new[] { GUILayout.Width(100) });
        GUILayout.Space(20);

        StartAngle = float.Parse(EditorGUILayout.TextField("起始角度:", StartAngle.ToString()));
        StartAngle = GUILayout.HorizontalSlider(StartAngle, 0, 360, new[] { GUILayout.Width(100) });
        GUILayout.Space(20);

        fDistance = float.Parse(EditorGUILayout.TextField("半径:", fDistance.ToString()));
        GUILayout.Space(20);
        GUILayout.TextField("以下两个参数决定本次布局影响的对象数量，默认影响所有对象");
        indexStart = int.Parse(EditorGUILayout.TextField("起始位置:", indexStart.ToString()));
        indexEnd = int.Parse(EditorGUILayout.TextField("结束位置:", indexEnd.ToString()));


        GUILayout.Space(10);
        if (GUILayout.Button("圆形布局"))
        {
            CalculateRadial();
        }
        GUILayout.Space(10);
        if (GUILayout.Button("水平布局"))
        {
            CalculateHorizontal();
        }

        GUILayout.Space(10);
        bReverse = GUILayout.Toggle(bReverse, "是否反向");

        // 事件
        if (Event.current.type == EventType.MouseUp)
        {
            Debug.Log("鼠标抬起事件");//鼠标抬起
            //CalculateRadial();
        }

        if (Event.current.type == EventType.MouseDrag)
        {
            Debug.Log("鼠标拖动事件");//鼠标拖动
            //CalculateRadial();
        }

        GUILayout.EndVertical();
    }

    void CalculateRadial()
    {
        if (layoutRoot.childCount == 0)
            return;
        if(indexEnd <= 0 || indexEnd > layoutRoot.childCount)
            indexEnd = layoutRoot.childCount;
        if (indexStart < 0 || indexStart > indexEnd)
            indexStart = 0;

        var count = indexEnd - indexStart;

        float fOffsetAngle = ((MaxAngle - MinAngle)) / (count - 1);

        float fAngle = StartAngle;
        for (int i = indexStart; i < indexEnd; i++)
        {
            Transform child = layoutRoot.GetChild(i);
            if (child != null)
            {
                Vector3 vPos = new Vector3(Mathf.Cos(fAngle * Mathf.Deg2Rad), 0, Mathf.Sin(fAngle * Mathf.Deg2Rad));
                child.localPosition = vPos * fDistance;
                fAngle += fOffsetAngle;
            }
        }
    }

    void CalculateHorizontal()
    {
        if (layoutRoot.childCount == 0)
            return;
        if (indexEnd <= 0 || indexEnd > layoutRoot.childCount)
            indexEnd = layoutRoot.childCount;
        if (indexStart < 0 || indexStart > indexEnd)
            indexStart = 0;

        var count = indexEnd - indexStart;
        float fOffect = fDistance / count;
        Vector3 startPos = layoutRoot.GetChild(indexStart).localPosition;
        int t = 0;
        for(int i = indexStart; i <= indexEnd; i ++)
        {
            var offst = (t * fOffect);
            if (bReverse)
                offst = -offst;
            Transform child = layoutRoot.GetChild(i);
            Vector3 vPos = new Vector3(startPos.x + offst, startPos.y, startPos.z);
            child.localPosition = vPos;
            t++;
        }
    }
}


// 响应事件
//private void OnGUI()
//{
//    if (Event.current.type == EventType.MouseDown)
//    {
//        Debug.LogError(EventType.MouseDown);//鼠标按下
//    }
//    else if (Event.current.type == EventType.MouseUp)
//    {
//        Debug.LogError(EventType.MouseUp);//鼠标抬起
//    }
//    else if (Event.current.type == EventType.MouseMove)
//    {
//        Debug.LogError(EventType.MouseMove);
//    }
//    else if (Event.current.type == EventType.MouseDrag)
//    {
//        Debug.LogError(EventType.MouseDrag);//鼠标拖动
//    }
//    else if (Event.current.type == EventType.KeyDown)
//    {
//        Debug.LogError(EventType.KeyDown);//按键按下
//    }
//    else if (Event.current.type == EventType.KeyUp)
//    {
//        Debug.LogError(EventType.KeyUp);//按键抬起
//    }
//    else if (Event.current.type == EventType.ScrollWheel)
//    {
//        Debug.LogError(EventType.ScrollWheel);//中轮滚动
//    }
//    else if (Event.current.type == EventType.Repaint)
//    {
//        Debug.LogError(EventType.Repaint);//每一帧重新渲染会发
//    }
//    else if (Event.current.type == EventType.Layout)
//    {
//        Debug.LogError(EventType.Layout);
//    }
//    else if (Event.current.type == EventType.DragUpdated)
//    {
//        Debug.LogError(EventType.DragUpdated);//拖拽的资源进入界面
//    }
//    else if (Event.current.type == EventType.DragPerform)
//    {
//        Debug.LogError(EventType.DragPerform);//拖拽的资源放到了某个区域里
//    }
//    else if (Event.current.type == EventType.Ignore)
//    {
//        Debug.LogError(EventType.Ignore);//操作被忽略
//    }
//    else if (Event.current.type == EventType.Used)
//    {
//        Debug.LogError(EventType.Used);//操作已经被使用过了
//    }
//    else if (Event.current.type == EventType.ValidateCommand)
//    {
//        Debug.LogError(EventType.ValidateCommand);//有某种操作被触发（例如复制和粘贴）
//    }
//    else if (Event.current.type == EventType.ExecuteCommand)
//    {
//        Debug.LogError(EventType.ExecuteCommand);//有某种操作被执行（例如复制和粘贴）
//    }
//    else if (Event.current.type == EventType.DragExited)
//    {
//        Debug.LogError(EventType.DragExited);//松开拖拽的资源
//    }
//    else if (Event.current.type == EventType.ContextClick)
//    {
//        Debug.LogError(EventType.ContextClick);//右键点击
//    }
//    else if (Event.current.type == EventType.MouseEnterWindow)
//    {
//        Debug.LogError(EventType.MouseEnterWindow);
//    }
//    else if (Event.current.type == EventType.MouseLeaveWindow)
//    {
//        Debug.LogError(EventType.MouseLeaveWindow);
//    }
//}