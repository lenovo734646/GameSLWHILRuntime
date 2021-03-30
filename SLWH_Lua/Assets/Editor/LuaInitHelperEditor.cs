using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;
using static LuaInitHelper;
using Object = UnityEngine.Object;
[CustomEditor(typeof(LuaInitHelper)), CanEditMultipleObjects]
public class LuaInitHelperEditor : Editor {

    //float time = 0;
    string findchildstr = "";
    public override void OnInspectorGUI() {

        DrawDefaultInspector();

        if (Event.current.type == EventType.KeyDown || Event.current.type == EventType.KeyUp) return;
        var targetcom = (LuaInitHelper)target;

        for (int i = 0; i < targetcom.initList.Count; i++) {
            var data = targetcom.initList[i];
            var name = data.name;

            if (string.IsNullOrEmpty(data.name)) {
                EditorGUILayout.HelpBox($"警告！index:{i} name没有值！", MessageType.Warning);
            } else if (!data.anyType) {
                EditorGUILayout.HelpBox($"警告！{name}没有值！", MessageType.Warning);
            }

        }

        if (targets.Length == 1 && GUILayout.Button("添加一个InitObject")) {
            var data = new TypeData();
            data.name = "";
            targetcom.initList.Add(data);
            EditorUtility.SetDirty(target);
        }
        if (targetcom.initList != null && targetcom.initList.Count > 0 && targets.Length == 1 && GUILayout.Button("删除一个元素")) {
            var window = (DeleteSeletWindow)EditorWindow.GetWindow(typeof(DeleteSeletWindow), true, "注意！删除不可撤销！");
            window.targetcom = targetcom;
            window.Show();
        }
        //if (GUILayout.Button("从children获取特定类型来初始化Objects")) {
        //    var window = (TypeSeletWindow)EditorWindow.GetWindow(typeof(TypeSeletWindow));
        //    window.target = targetcom.gameObject;
        //    window.Show();
        //    window.onClose = selectedType => {
        //        var list = targetcom.GetComponentsInChildren(selectedType);
        //        List<Object> objects = new List<Object>(targetcom.objects);
        //        objects.AddRange(list);
        //        targetcom.objects = objects.ToArray();
        //    };
        //}
        if (targetcom.objects != null && targetcom.objects.Length > 0) {
            var obj_ = targetcom.objects[0];
            if (obj_ is Texture2D) {
                if (targets.Length == 1 && GUILayout.Button("转换objects中的Texture2D到Sprite")) {
                    for (int i = 0; i < targetcom.objects.Length; i++) {
                        var path = AssetDatabase.GetAssetPath(targetcom.objects[i]);
                        var spr = AssetDatabase.LoadAssetAtPath<Sprite>(path);
                        targetcom.objects[i] = spr;
                    }
                    EditorUtility.SetDirty(target);
                }
            } else {
                if (((obj_ is Component) || (obj_ is GameObject)) && targets.Length == 1 && GUILayout.Button("转换Objects到可选类型")) {

                    var window = (TypeSeletWindow)EditorWindow.GetWindow(typeof(TypeSeletWindow));
                    window.target = targetcom.objects[0];
                    window.getChildrenType = false;
                    window.Show();
                    window.onClose = selectedType => {
                        for (int i = 0; i < targetcom.objects.Length; i++) {
                            var obj = targetcom.objects[i];
                            if (obj is Component) {
                                var cobj = obj as Component;
                                if (!ReferenceEquals(cobj, null)) {
                                    var com = cobj.GetComponent(selectedType);
                                    if (com) {
                                        targetcom.objects[i] = com;
                                    }
                                }
                            } else {
                                var gobj = obj as GameObject;
                                if (!ReferenceEquals(gobj, null)) {
                                    var com = gobj.GetComponent(selectedType);
                                    if (com) {
                                        targetcom.objects[i] = com;
                                    }
                                }
                            }
                        }
                        EditorUtility.SetDirty(target);
                    };
                }

            }
            if (targetcom.objects.Length > 2) {
                if (targets.Length == 1 && GUILayout.Button("选择Objects中的一个进行转换")) {
                    var window = (SelectObjectCovertWindow)EditorWindow.GetWindow(typeof(SelectObjectCovertWindow));
                    window.objects = targetcom.objects;
                    window.Show();
                    EditorUtility.SetDirty(target);
                }
                if (targets.Length == 1 && GUILayout.Button("移出None项并排序Objects")) {
                    // 移出空项
                    var objList = targetcom.objects.ToList();
                    for (var i = 0; i < objList.Count;)
                    {
                        if (objList[i] == null)
                            objList.Remove(objList[i]);
                        else
                        {
                            i++;
                        }
                    }
                    // 排序
                    objList.Sort((a, b) => { return a.name.CompareTo(b.name); });
                    targetcom.objects = objList.ToArray();
                    EditorUtility.SetDirty(target);
                }
            }
        }
        GUILayout.BeginHorizontal();
        findchildstr = GUILayout.TextField(findchildstr);
        if (targets.Length==1 && GUILayout.Button("条件查找子节点添加到Objects")) {
            List<Object> objects = new List<Object>(targetcom.objects);
            ForeachChildren(targetcom.transform, t=> {
                if (t.name == findchildstr) {
                    objects.Add(t.gameObject);
                }
            });
            targetcom.objects = objects.ToArray();
        }
        if (GUILayout.Button("条件查找子节点添加到IniList")) {
            TypeSeletWindow window = null;
            var findsobjs = new List<KeyValuePair<TypeData, Transform>>();
            foreach (LuaInitHelper targetcom_ in targets) {
                ForeachChildren(targetcom_.transform, t => {
                    if (t.name == findchildstr) {
                       
                        if (window == null) {
                            window = EditorWindow.GetWindow<TypeSeletWindow>();
                            window.target = t;
                            window.Show();
                            window.onClose = type_ => {
                                foreach (var p in findsobjs) {
                                    p.Key.anyType = p.Value.GetComponent(type_);
                                    p.Key.name =( p.Value.name + "_" + p.Key.anyType.GetType().Name).ToLower();
                                }
                            };
                        }
                        TypeData typeData = new TypeData();
                        typeData.anyType = t.gameObject;
                        targetcom_.initList.Add(typeData);
                        findsobjs.Add(new KeyValuePair<TypeData, Transform>(typeData,t));
                        DoAutoSetValue(targetcom_);
                    }
                });
            }

        }
        GUILayout.EndHorizontal();
        if (targets.Length == 1 && Selection.gameObjects.Length>0 && GUILayout.Button("添加选中到InitList")) {
            var window = EditorWindow.GetWindow<TypeSeletWindow>();
            window.target = Selection.gameObjects[0];
            window.Show();
            window.onClose = selectedType => {
                foreach (var obj in Selection.gameObjects) {
                    TypeData typeData = new TypeData();
                    if (selectedType != null) {
                        typeData.anyType = obj.GetComponent(selectedType);
                        typeData.name = (typeData.anyType.name + "_" + selectedType.Name).ToLower();
                    } else {
                        typeData.anyType = obj;
                    }
                    targetcom.initList.Add(typeData);
                    EditorUtility.SetDirty(targetcom);
                }
            };
        }

        //if (GUILayout.Button("检查是否有空值")) {
        
        //}




        DoAutoSetValue(targetcom);
    }

    void ForeachChildren(Transform transform, Action<Transform> action) {
        foreach (Transform t in transform) {
            action(t);
            if (t.childCount > 0) {
                ForeachChildren(t, action);
            }
        }
    }

    void DoAutoSetValue(LuaInitHelper targetcom) {
        foreach (var data in targetcom.initList) {
            if (!string.IsNullOrEmpty(data.manualName)) {
                data.name = data.manualName;
                data.manualName = "";
            } else if (string.IsNullOrEmpty(data.name)) {
                if (data.anyType) {
                    data.name = data.anyType.name;
                } else if (data.t) {
                    data.name = data.t.name;
                }
            }
            if (!data.anyType) {
                if (data.monoType) {
                    data.anyType = data.monoType;
                }else if (data.t) {
                    data.anyType = data.t;
                    data.t = null;
                }
            } else {
                if (data.monoType && data.anyType != data.monoType) {
                    data.anyType = data.monoType;
                }
            }

        }

        var map = new Dictionary<string, int>();
        for (int i = 0; i < targetcom.initList.Count; i++) {
            var data = targetcom.initList[i];
            if (!data.anyType) continue;
            var name = data.name;
            if (map.ContainsKey(name)) {
                var index2 = map[name];
                Debug.LogWarning("包含重复的key:" + name + " target:" + data.name + " index:" + i + " index2:" + index2);
                if(data.anyType is GameObject) {
                    var obj = (data.anyType as GameObject);
                    var parent = obj.transform.parent;
                    parent = parent ? parent : obj.transform;
                    name = parent.name+"_"+name;
                }else if(data.anyType is Component) {
                    var obj = (data.anyType as Component);
                    var parent = obj.transform.parent;
                    parent = parent ? parent : obj.transform;
                    name = parent.name + "_" + name;
                }
                data.name = name;
                continue;
            }
            map.Add(name, i);
        }
    }
}

class SelectObjectCovertWindow : EditorWindow {
    public Object[] objects;
    Vector2 scrollPos;
    private void OnGUI() {
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        for (int i = 0; i < objects.Length; i++) {
            var obj = objects[i];
            if (GUILayout.Button($"{obj}(index:{i})")) {
                var window = (TypeSeletWindow)EditorWindow.GetWindow(typeof(TypeSeletWindow));
                window.target = obj;
                window.getChildrenType = false;
                window.Show();
                window.onClose = selectedType => {
                    if (obj is Component) {
                        var cobj = obj as Component;
                        if (!ReferenceEquals(cobj, null)) {
                            var com = cobj.GetComponent(selectedType);
                            if (com) {
                                objects[i] = com;
                            }
                        }
                    } else {
                        var gobj = obj as GameObject;
                        if (!ReferenceEquals(gobj, null)) {
                            var com = gobj.GetComponent(selectedType);
                            if (com) {
                                objects[i] = com;
                            }
                        }
                    }
                };
                Close();
                break;
            }
        }
        EditorGUILayout.EndScrollView();
    }
}

class DeleteSeletWindow : EditorWindow {
    public LuaInitHelper targetcom;
    Vector2 scrollPos;
    private void OnGUI() {
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);
        for (int i = 0; i < targetcom.initList.Count; i++) {
            var data = targetcom.initList[i];
            if (GUILayout.Button($"{data.name}(index:{i})")) {
                targetcom.initList.RemoveAt(i);
                Close();
                EditorUtility.SetDirty(targetcom);
                break;
            }
        }
        EditorGUILayout.EndScrollView();
    }

}

