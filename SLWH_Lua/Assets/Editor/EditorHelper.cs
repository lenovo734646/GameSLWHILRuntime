using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;
public static class EditorUtil 
{
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
            enm.MoveNext();
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