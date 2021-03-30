using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Events;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using Object = UnityEngine.Object;
[CustomPropertyDrawer(typeof(EventBroadcaster.Event))]
public class EventBroadcaster_EventDrawer : PropertyDrawer {
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
        var target = property.serializedObject.targetObject as EventBroadcaster;
        EditorGUI.PropertyField(position, property, label, true);
        
        if (target && target.events !=null && target.events.Length > 0) {
            position.y += EditorGUI.GetPropertyHeight(property);
            position.height = 20;
            var nameppt = property.FindPropertyRelative(nameof(EventBroadcaster.Event.name));
            var eventdata = (EventBroadcaster.Event)EditorUtil.GetParent(nameppt);
            if (GUI.Button(position, $"测试{eventdata.name}事件(有些事件只在Play有效)")) {

                target.Init();
                target.Broadcast(eventdata.name);
            }
            position.y += 20;
            position.height = 20;
            if (GUI.Button(position, "批量添加所选Object事件")) {
                var objs = Selection.gameObjects;
                Array.Sort(objs, (a,b)=> { return a.name.CompareTo(b.name); });
                if (objs.Length > 0) {
                    var window = EditorWindow.GetWindow<TypeSeletWindow>();
                    window.target = objs[0];
                    window.Show();
                    window.onClose = selectedType => {
                        if (selectedType == null) { 
                            return;
                        }
                        Object objOrCom;
                        var infos = selectedType.GetMethods();
                        if (selectedType == typeof(GameObject)) {
                            objOrCom = objs[0];
                        } else {
                            objOrCom = objs[0].GetComponent(selectedType);
                        }
                        var w = EditorWindow.GetWindow<MethodSelecteWindows>();
                        w.targetType = selectedType;
                        w.Show();
                        w.funcfilter = methodinfo => {
                            if (methodinfo.Name.ToLower().StartsWith("get")) return null;

                            var info = UnityEventBase.GetValidMethodInfo(objOrCom, methodinfo.Name, new Type[] { });
                            if(info==null)
                                info = UnityEventBase.GetValidMethodInfo(objOrCom, methodinfo.Name, new Type[] { typeof(bool)});
                            return info;
                        };
                        w.onClose = methodinfo => {
                            Debug.Log("selected " + methodinfo.Name);
                            foreach (var obj in objs) {
                                objOrCom = selectedType == typeof(GameObject)? (Object)obj : obj.GetComponent(selectedType);
                                var info = objOrCom.GetType().GetMethod(methodinfo.Name);
                                //Debug.Log(info.Name);
                                if (info.GetParameters().Length == 1) {
                                    if(info.GetParameters()[0].ParameterType == typeof(bool)) {
                                        var execute = Delegate.CreateDelegate(
                                    typeof(UnityAction<bool>), objOrCom, info) as UnityAction<bool>;
                                        UnityEventTools.AddBoolPersistentListener(eventdata.UnityEvent, execute, false);
                                    }
                                } else {
                                    var execute = Delegate.CreateDelegate(
                                    typeof(UnityAction), objOrCom, info) as UnityAction;
                                    UnityEventTools.AddPersistentListener(eventdata.UnityEvent, execute);
                                }
                                
                            }
                        };

                        EditorUtility.SetDirty(target);
                    };
                }
            }
        }
        
    }

    public override float GetPropertyHeight(SerializedProperty property, GUIContent label) {
        return EditorGUI.GetPropertyHeight(property)+ EditorGUIUtility.singleLineHeight*2;
    }
}
