using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.SceneManagement;

[CustomEditor(typeof(LuaObjectsExInitHelper)), CanEditMultipleObjects]
public class EditorObjectArrayEditor : Editor
{
    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();
        DrawDefaultInspector();

        var targetcom = (LuaObjectsExInitHelper)target;
        if (targetcom.objects != null && targetcom.objects.Length > 0)
        {
            var obj_ = targetcom.objects[0];
            if (obj_ is Texture2D)
            {
                if (targets.Length == 1 && GUILayout.Button("转换objects中的Texture2D到Sprite"))
                {
                    for (int i = 0; i < targetcom.objects.Length; i++)
                    {
                        var path = AssetDatabase.GetAssetPath(targetcom.objects[i]);
                        var spr = AssetDatabase.LoadAssetAtPath<Sprite>(path);
                        targetcom.objects[i] = spr;
                    }
                }
            }
            else
            {
                if (((obj_ is Component) || (obj_ is GameObject)) && targets.Length == 1 && GUILayout.Button("转换Objects到可选类型"))
                {

                    var window = (TypeSeletWindow)EditorWindow.GetWindow(typeof(TypeSeletWindow));
                    window.target = targetcom.objects[0];
                    window.getChildrenType = false;
                    window.Show();
                    window.onClose = selectedType => {
                        for (int i = 0; i < targetcom.objects.Length; i++)
                        {
                            var obj = targetcom.objects[i];
                            if (obj is Component)
                            {
                                var cobj = obj as Component;
                                if (!ReferenceEquals(cobj, null))
                                {
                                    var com = cobj.GetComponent(selectedType);
                                    if (com)
                                    {
                                        targetcom.objects[i] = com;
                                    }
                                }
                            }
                            else
                            {
                                var gobj = obj as GameObject;
                                if (!ReferenceEquals(gobj, null))
                                {
                                    var com = gobj.GetComponent(selectedType);
                                    if (com)
                                    {
                                        targetcom.objects[i] = com;
                                    }
                                }
                            }
                        }
                        EditorUtility.SetDirty(target);
                    };
                }

            }
            if (targetcom.objects.Length > 2)
            {
                if (targets.Length == 1 && GUILayout.Button("选择Objects中的一个进行转换"))
                {
                    var window = (SelectObjectCovertWindow)EditorWindow.GetWindow(typeof(SelectObjectCovertWindow));
                    window.objects = targetcom.objects;
                    window.Show();
                    EditorUtility.SetDirty(target);
                }
                if (targets.Length == 1 && GUILayout.Button("移出None项并排序Objects"))
                {
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
    }
}
