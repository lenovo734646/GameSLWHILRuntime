using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Events;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using Object = UnityEngine.Object;
[CustomEditor(typeof(LuaUnityEventListener))]
public class LuaUnityEventListenerEditor : Editor {


    //float time = 0;
    List<KeyValuePair<string, Object>> uiobjs = new List<KeyValuePair<string, Object>>();
    //List<Toggle> toggles;

    public override void OnInspectorGUI() {
        var targetcom = (LuaUnityEventListener)target;
        DrawDefaultInspector();

        //
        //foreach (var p in uiobjs) {
        //    if (nameSet.Contains(p.Value.name)) {
        //        EditorGUILayout.HelpBox($"警告！事件调用者名字相同，可能会出现key覆盖 name:{p.Value}", MessageType.Warning);
        //    } else
        //        nameSet.Add(p.Value.name);
        //}

        findAllRef(targetcom);
        if (uiobjs.Count>0)
            GUILayout.Label("此监听被以下组件引用(前面是被引用的函数)");

        foreach (var p in uiobjs) {
            var uiobj = p.Value;
            EditorGUILayout.ObjectField(p.Key,uiobj,uiobj.GetType(),false);
        }

        if (GUILayout.Button("添加Btton事件监听(CallLuaByGameObjectName)")) {
            findAllRef(targetcom);
            var root = targetcom.transform.root;
            var btns = root.GetComponentsInChildren<Button>(true);
            var window = (ObjectsSeletWindow)EditorWindow.GetWindow(typeof(ObjectsSeletWindow));
            window.targetList.AddRange(btns);
            foreach (var p in uiobjs) {
                foreach (var btn in window.targetList) {
                    if (btn == p.Value) {
                        window.targetList.Remove(btn);
                        break;
                    }
                }
            }
            
            window.onClose = obj => {
                var btn = obj as Button;
                UnityEventTools.AddObjectPersistentListener(btn.onClick, targetcom.CallLuaByGameObjectName, btn);
                uiobjs.Clear();
                EditorUtility.SetDirty(targetcom);
            };
            window.Show();
        }
        if (GUILayout.Button("添加Btton事件监听(OnCustumObjectEvent)")) {
            findAllRef(targetcom);
            var root = targetcom.transform.root;
            var btns = root.GetComponentsInChildren<Button>(true);
            var window = (ObjectsSeletWindow)EditorWindow.GetWindow(typeof(ObjectsSeletWindow));
            window.targetList.AddRange(btns);
            foreach (var p in uiobjs) {
                foreach (var btn in window.targetList) {
                    if (btn == p.Value) {
                        window.targetList.Remove(btn);
                        break;
                    }
                }
            }

            window.onClose = obj => {
                var btn = obj as Button;
                UnityEventTools.AddObjectPersistentListener(btn.onClick, targetcom.OnCustumObjectEvent, btn);
                uiobjs.Clear();
                EditorUtility.SetDirty(targetcom);
            };
            window.Show();
        }
        if (GUILayout.Button("添加Children的全部Btton事件监听(CallLuaByGameObjectName)")) {
            List<Button> buttons = new List<Button>();
            targetcom.GetComponentsInChildren(true,buttons);
            foreach (var p in uiobjs) {
                foreach (var btn in buttons) {
                    if (btn == p.Value) {
                        buttons.Remove(btn);
                        break;
                    }
                }
            }
            foreach(var btn in buttons) {
                UnityEventTools.AddObjectPersistentListener(btn.onClick, targetcom.CallLuaByGameObjectName, btn);
            }
            EditorUtility.SetDirty(targetcom);
            uiobjs.Clear();
        }
        if (GUILayout.Button("添加Children的全部Btton事件监听(OnCustumObjectEvent)")) {
            List<Button> buttons = new List<Button>();
            targetcom.GetComponentsInChildren(true, buttons);
            foreach (var p in uiobjs) {
                foreach (var btn in buttons) {
                    if (btn == p.Value) {
                        buttons.Remove(btn);
                        break;
                    }
                }
            }
            foreach (var btn in buttons) {
                UnityEventTools.AddObjectPersistentListener(btn.onClick, targetcom.OnCustumObjectEvent, btn);
            }
            EditorUtility.SetDirty(targetcom);
            uiobjs.Clear();
        }
        //if (GUILayout.Button("清楚所有引用的事件监听")) {

        //}
        HashSet<string> eventNameSet = new HashSet<string>();
        if (GUILayout.Button("把CallLuaByGameObjectName事件生成Lua代码并复制到剪贴板")) {
            string s = "";
            foreach (var p in uiobjs) {
                var uiobj = p.Value;
                if(p.Key== "CallLuaByGameObjectName") {
                    if (eventNameSet.Contains(uiobj.name)) continue;
                    eventNameSet.Add(uiobj.name);
                    s += $"function Class:On_{uiobj.name}_Event({uiobj.name})\n    \n";
                    s += "end\n\n";
                }
            }
            GUIUtility.systemCopyBuffer = s;
        }

        }

    void findAllRef(LuaUnityEventListener luaUnityEventListener) {
        if (uiobjs.Count != 0) return;
        var root = luaUnityEventListener.transform.root;
        var btns = root.GetComponentsInChildren<Button>(true);
        foreach (var btn in btns) {
            if (isContainListener(luaUnityEventListener, btn.onClick, out string refname)) {
                uiobjs.Add(new KeyValuePair<string, Object>(refname, btn));
            }
        }
        var toggles = root.GetComponentsInChildren<Toggle>(true);
        foreach (var toggle in toggles) {
            if (isContainListener(luaUnityEventListener, toggle.onValueChanged, out string refname)) {
                uiobjs.Add(new KeyValuePair<string, Object>(refname, toggle));
            }
        }
    }

    bool isContainListener(LuaUnityEventListener luaUnityEventListener, UnityEventBase unityEventBase, out string refname) {
        refname = "";
        for (var i = 0;i< unityEventBase.GetPersistentEventCount(); i++) {
           if(unityEventBase.GetPersistentTarget(i)==luaUnityEventListener) {
                refname = unityEventBase.GetPersistentMethodName(i);
                return true;
            }
        }

        return false;
    }

}


