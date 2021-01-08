using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;
using static LuaInitHelper;
using Object = UnityEngine.Object;

[CustomPropertyDrawer(typeof(TypeData))]
public class TypeDataDrawer : PropertyDrawer {




    public override float GetPropertyHeight(SerializedProperty property, GUIContent label) {
        var height = EditorGUIUtility.singleLineHeight;
        if (property.isExpanded) {
            if (!isShowOldPptDic.TryGetValue(property.propertyPath, out bool isShowOldPpt)) {
                isShowOldPptDic.Add(property.propertyPath, false);
            }
            if (isShowOldPpt) {
                height *= 8;
            } else {
                height *= 4;
            }
        }
        return height;
    }

    Dictionary<string, bool> isShowOldPptDic = new Dictionary<string, bool>();

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {

        var width = position.width;
        var x = position.x;

        //property.serializedObject.Update();

        var height = EditorGUIUtility.singleLineHeight;

        position.height = height;

        property.isExpanded = EditorGUI.Foldout(position, property.isExpanded, new GUIContent(property.displayName));

        position.y += height;

        if (property.isExpanded) {
            EditorGUI.indentLevel++;

            EditorGUI.PropertyField(position, property.FindPropertyRelative(nameof(TypeData.name)), 
                new GUIContent("LuaTable中的Key"));
            position.y += height;


            var w = position.width;
            position.width = w - 100;
            var anyTypePpt = property.FindPropertyRelative(nameof(TypeData.anyType));
            EditorGUI.PropertyField(position, anyTypePpt, new GUIContent("需要绑定的对象或组件")); 
            position.x += position.width; 
            position.width = w - position.width;
            if (GUI.Button(position, "设置类型")) {
                var window = (SetAnyTypeWindow)EditorWindow.GetWindow(typeof(SetAnyTypeWindow));
                window.target = anyTypePpt.objectReferenceValue;
                window.setTargetFunc = (com,b) => {
                    var TypeData = ((TypeData)EditorUtil.GetParent(anyTypePpt));
                    TypeData.anyType = com;
                    if (b) {

                        TypeData.name = (com.name+"_"+com.GetType().Name).ToLower();
                    }
                    EditorUtility.SetDirty(TypeData.anyType);
                };
                window.Show();
            }
            position.x = x;
            position.y += height;
            position.width = width;

            if (!isShowOldPptDic.TryGetValue(property.propertyPath, out bool isShowOldPpt)) {
                isShowOldPptDic.Add(property.propertyPath, false);
            }
            
            isShowOldPpt = EditorGUI.Toggle(position, "显示弃用的属性", isShowOldPpt);
            isShowOldPptDic[property.propertyPath] = isShowOldPpt;
            if (isShowOldPpt) {
                position.y += height;
                var ppt = property.FindPropertyRelative(nameof(TypeData.t));
                EditorGUI.PropertyField(position, ppt, new GUIContent("需要绑定的Transform"));
                position.y += height;
                ppt = property.FindPropertyRelative(nameof(TypeData.monoType));
                EditorGUI.PropertyField(position, ppt, new GUIContent("需要绑定的对象或组件"));
                position.y += height;
                ppt = property.FindPropertyRelative(nameof(TypeData.sType));
                EditorGUI.PropertyField(position, ppt, new GUIContent("自定义类型"));
                position.y += height;
                ppt = property.FindPropertyRelative(nameof(TypeData.manualName));
                EditorGUI.PropertyField(position, ppt, new GUIContent("自定义LuaTable中的Key"));
            }
            
            //position.y += height;
            //position.x += position.width / 4;
            //position.width /= 2;
            //if (GUI.Button(position, "移除此项")) { 
            //    if(EditorUtility.DisplayDialog("删除确认",
            //    "确定要删除吗?","是","否") ){
            //        Debug.Log("111111");
            //    }
            //    EditorUtility.FocusProjectWindow();
            //}

                EditorGUI.indentLevel--;
        }

        //property.serializedObject.ApplyModifiedProperties();
    }
}

class SetAnyTypeWindow : EditorWindow {
    public Object target;
    public Action<Object,bool> setTargetFunc;
    Vector2 scrollPos;
    Dictionary<string, bool> checkDic = new Dictionary<string, bool>();
    private void OnGUI() {
        //GUI.skin.label.normal.textColor = Color.red;
        EditorGUILayout.LabelField("若不希望自动命名可右键单击选择类型，不必取消勾选");
        //GUI.skin.label.normal.textColor = Color.white;
        Component[] list;
        GameObject gameObject;
        if (target is Component) {
            var com = (Component)target;
            gameObject = com.gameObject;
            list = com.GetComponents<Component>();
        } else if (target is GameObject) {
            gameObject = ((GameObject)target);
            list = gameObject.GetComponents<Component>();
        } else {
            return;
        }
        var stringSet = new Dictionary<string, Component>();

        foreach (var com in list) {
            stringSet[com.GetType().FullName] = com;
        }
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        if (GUILayout.Button("设置为GameObject")){
            setTargetFunc(gameObject, false);
            Close();
        }

        foreach (var p in stringSet) {
            GUILayout.BeginHorizontal();
            var clickbtn = GUILayout.Button(p.Key);
            if (!checkDic.ContainsKey(p.Key))
                checkDic.Add(p.Key, true);
            var b = checkDic[p.Key] = GUILayout.Toggle(checkDic[p.Key], "自动设置名字");

            if (clickbtn && Event.current.button == (int)MouseButton.LeftMouse)
            {
                Debug.Log(Event.current.type);
                setTargetFunc(p.Value, b);
                Close();
            }

            if (clickbtn && Event.current.button == (int)MouseButton.RightMouse)
            {
                setTargetFunc(p.Value, false);
                Close();
            }
            GUILayout.EndHorizontal();
        }
        EditorGUILayout.EndScrollView();
    }

    //bool bleft = false;
    //bool bright = false;
    //private void Update()
    //{
        
    //    if (Input.GetMouseButtonDown(0))
    //    {
    //        bleft = true;
    //        Debug.Log("你按下了鼠标左键");
    //    }
    //    if (Input.GetMouseButtonUp(0))
    //    {
    //        bleft = false;
    //        Debug.Log("你抬起了鼠标左键");
    //    }
    //    //
    //    if (Input.GetMouseButtonDown(1))
    //    {
    //        bright = true;
    //        Debug.Log("你按下了鼠标右键");
    //    }
    //    if (Input.GetMouseButtonUp(1))
    //    {
    //        bright = false;
    //        Debug.Log("你抬起了鼠标左键");
    //    }
    //}
}