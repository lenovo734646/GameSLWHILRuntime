using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;
public static class EditorUtil 
{

    //获取ALLPrefab
    public static List<Object> GetAllPrefabs(string directory)
    {
        string[] subFolders = Directory.GetDirectories(directory);
        List<Object> objlist = new List<Object>();
        getobjsindir(directory, objlist);
        foreach (var folder in subFolders)
        {
            getobjsindir(folder, objlist);
        }

        return objlist;
    }

    static void getobjsindir(string dir, List<Object> objlist)
    {
        var guids = AssetDatabase.FindAssets("t:Prefab", new string[] { dir });
        var assetPaths = new string[guids.Length];
        int i;
        int iMax;
        for (i = 0, iMax = assetPaths.Length; i < iMax; ++i)
        {
            assetPaths[i] = AssetDatabase.GUIDToAssetPath(guids[i]);
            string[] arr = assetPaths[i].Split('/');
            string prefabName = arr[arr.Length - 1].Split('.')[0];
            GameObject obj = AssetDatabase.LoadMainAssetAtPath(assetPaths[i]) as GameObject;
            obj.name = prefabName;
            objlist.Add(obj);
        }
    }

    public static object GetParent(SerializedProperty prop) {
        var path = prop.propertyPath.Replace(".Array.data[", "[");
        object obj = prop.serializedObject.targetObject;
        var elements = path.Split('.');
        foreach (var element in elements.Take(elements.Length - 1)) {
            if (element.Contains("[")) {
                var elementName = element.Substring(0, element.IndexOf("["));
                var index = System.Convert.ToInt32(element.Substring(element.IndexOf("[")).Replace("[", "").Replace("]", ""));
                obj = GetValue(obj, elementName, index);
            } else {
                obj = GetValue(obj, element);
            }
        }
        return obj;
    }

    public static object GetValue(object source, string name) {
        if (source == null)
            return null;
        var type = source.GetType();
        var f = type.GetField(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
        if (f == null) {
            var p = type.GetProperty(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
            if (p == null)
                return null;
            return p.GetValue(source, null);
        }
        return f.GetValue(source);
    }

    public static object GetValue(object source, string name, int index) {
        var enumerable = GetValue(source, name) as IEnumerable;
        if (enumerable == null) return null;
        var enm = enumerable.GetEnumerator();
        while (index-- >= 0)
        {
            var b = enm.MoveNext();
            if (b == false)
            {
                Debug.Log($"index = {index}, b = {b}");
            }
            
        }
            
        return enm.Current;
    }
}


class TypeSeletWindow : EditorWindow {

    public Object target;
    public Type selectedType;

    public bool getChildrenType = true;

    public Action<Type> onClose;
    Vector2 scrollPos;
    private void OnGUI() {
        List<Component> list = new List<Component>();
        if (target is Component) {
            ((Component)target).GetComponents<Component>(list);
            if (getChildrenType)
                ((Component)target).GetComponentsInChildren<Component>(true, list);
        } else if (target is GameObject) {
            //Debug.Log(((GameObject)target).GetComponents<Toggle>());
            ((GameObject)target).GetComponents<Component>(list);
            if (getChildrenType)
                ((GameObject)target).GetComponentsInChildren<Component>(true, list);
        } else {
            return;
        }

        var stringSet = new Dictionary<string, Type>();

        foreach (var com in list) {
            stringSet[com.GetType().FullName] = com.GetType();
        }
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        foreach (var p in stringSet) {
            if (GUILayout.Button(p.Key)) {
                selectedType = p.Value;
                onClose?.Invoke(selectedType);
                onClose = null;
                Close();
                break;
            }
        }
        if(target is GameObject) {
            if (GUILayout.Button("GameObject")) {
                selectedType = typeof(GameObject);
                onClose?.Invoke(selectedType);
                onClose = null;
                Close();
            }
        }
        EditorGUILayout.EndScrollView();
    }

    private void OnDestroy() {
        onClose?.Invoke(null);
    }
}

class ObjectsSeletWindow : EditorWindow {

    public List<Object> targetList = new List<Object>();
    public Action<Object> onClose;
    Vector2 scrollPos;
    private void OnGUI() {

        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        foreach (var obj in targetList) {
            if (GUILayout.Button(obj.name + $"({obj.GetType().FullName})")) {
                Close();
                onClose?.Invoke(obj);
                break;
            }
        }
        EditorGUILayout.EndScrollView();

    }
}

class ObjectsDragSelectWindow : EditorWindow
{
    public List<GameObject> targetList = new List<GameObject>();
    public Action<GameObject> onClose;
    Vector2 scrollPos;
    private void OnGUI()
    {
        GUILayout.BeginVertical();
        GUILayout.Label("拖拽添加，左键点击移出", GUILayout.Width(300));
        // 此矩形框用来接收拖拽的obj
        Rect rect = EditorGUILayout.GetControlRect(GUILayout.Width(300), GUILayout.Height(150));
        EditorGUI.TextField(rect, "拖放需要设置的Object到此");
        //如果鼠标正在拖拽中或拖拽结束时，并且鼠标所在位置在文本输入框内  
        if ((Event.current.type == EventType.DragUpdated
          || Event.current.type == EventType.DragExited)
          && rect.Contains(Event.current.mousePosition))
        {
            //改变鼠标的外表  
            DragAndDrop.visualMode = DragAndDropVisualMode.Generic;
            if (DragAndDrop.objectReferences != null && DragAndDrop.objectReferences.Length > 0)
            {
                foreach (var obj in DragAndDrop.objectReferences)
                {
                    if (obj)
                    {
                        if (!targetList.Contains(obj))
                            targetList.Add((GameObject)obj);
                    }
                }
                return; // OnGUI函数中，不可以同时做改动pathList和绘制pathList会报错，这里return下一帧做绘制
            }
        }

        // 绘制列表
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        foreach (var obj in targetList)
        {
            if (GUILayout.Button(obj.name + $"({obj.GetType().FullName})"))
            {
                targetList.Remove(obj);
                break;
            }
        }
        EditorGUILayout.EndScrollView();
        //
        GUILayout.Space(10);
        if (GUILayout.Button("设置"))
        {
            foreach (var obj in targetList)
            {
                onClose?.Invoke(obj);
            }
            //Close();
            Debug.Log("设置完毕");
        }
        GUILayout.Space(10);
        if (GUILayout.Button("清空"))
        {
            targetList.Clear();
        }
        GUILayout.EndVertical();
    }
}

class MethodSelecteWindows : EditorWindow {
    public Type targetType;
    Vector2 scrollPos;
    public Action<MethodInfo> onClose;
    public Func<MethodInfo, MethodInfo> funcfilter;

    private void OnGUI() {
        if (funcfilter == null) funcfilter = info => { return info; };
         scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        var infos = targetType.GetMethods();
        foreach (var info in infos) {
            var info_ = funcfilter(info);
            if (info_ !=null&& GUILayout.Button(info.Name)) {
                Close();
                onClose?.Invoke(info_);
                break;
            }
        }

        EditorGUILayout.EndScrollView();
    }
}