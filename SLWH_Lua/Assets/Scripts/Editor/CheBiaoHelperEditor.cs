using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace SLWH
{
    [CustomEditor(typeof(CheBiaoHelper))]
    public class CheBiaoHelperEditor : Editor
    {
        CheBiaoHelper chebiaoHelper;
        private ReorderableList chebiaoList;

        string[] colorChoises;
        string[] chebiaoChoises;

        private int ptFocusedIndex = -1;
        private int ptActiveIndex = -1;

        private bool showChebiao;
        private bool showDefault;

        private void OnEnable()
        {
            chebiaoList = new ReorderableList(serializedObject, serializedObject.FindProperty("chebiaoList"),
                true, true, true, true);
            chebiaoList.onAddCallback += OnAddCallBack;
            chebiaoList.onRemoveCallback += RemoveCallback;
            chebiaoList.drawElementCallback += OnDrawCallback;
            chebiaoList.onSelectCallback += OnSelectCallBack;
            chebiaoList.drawHeaderCallback += DrawHeaderCallBack;
            chebiaoList.onChangedCallback += OnChangeCallBack;
            chebiaoList.elementHeightCallback += OnElementHeightCallback;
            //  chebiaoList.onAddDropdownCallback += OnAddDropDownCallBack;

            ptFocusedIndex = -1;
            ptActiveIndex = -1;
        }

        private void OnDisable()
        {
            if (chebiaoList != null)
            {
                chebiaoList.onAddCallback -= OnAddCallBack;
                chebiaoList.onRemoveCallback -= RemoveCallback;
                chebiaoList.drawElementCallback -= OnDrawCallback;
                chebiaoList.onSelectCallback -= OnSelectCallBack;
                chebiaoList.drawHeaderCallback -= DrawHeaderCallBack;
                chebiaoList.onChangedCallback -= OnChangeCallBack;
                chebiaoList.onAddDropdownCallback -= OnAddDropDownCallBack;
                chebiaoList.elementHeightCallback -= OnElementHeightCallback;
                //  chebiaoList.onAddDropdownCallback -= OnAddDropDownCallBack;
            }
        }
        #region 回调函数
        private void OnAddCallBack(ReorderableList list)
        {
            if (chebiaoHelper == null || chebiaoHelper.chebiaoList == null || chebiaoHelper.chebiaoRoot == null)
            {
                Debug.LogError("chebiaoHelper or chebiaoList or chebiaoRoot is null");
                return;
            }
            var count = chebiaoHelper.chebiaoList.Count;
            if (count > 0)
            {
                if (count > chebiaoHelper.chebiaoGameObjects.Length)
                {
                    Debug.LogError("添加的数量大于chebiaoRoot中的车标数量");
                    return;
                }
                var data = new CheBiaoData(chebiaoHelper.chebiaoGameObjects[count], //go自动指向下一个
                    chebiaoHelper.chebiaoList[count - 1].material,  // 其他属性复制上一个,
                    chebiaoHelper.chebiaoList[count - 1].sprite);
                chebiaoHelper.chebiaoList.Add(new CheBiaoData(data));
            }
            else
            {
                chebiaoHelper.chebiaoList.Add(new CheBiaoData(chebiaoHelper.chebiaoGameObjects[0], chebiaoHelper.colorMaterials[0], chebiaoHelper.chebiaoSprites[0]));
            }
            EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        }

        private void RemoveCallback(ReorderableList list)
        {
            //if(EditorUtility.DisplayDialog("警告！", "确定删除吗？", "是", "否"))
            {
                chebiaoHelper.chebiaoList.RemoveAt(list.index);
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
            }
        }

        private void OnDrawCallback(Rect rect, int index, bool isActive, bool isFocused)
        {
            EditorGUI.LabelField(rect, (index + 1).ToString());
            rect.y += 2;
            rect.x += 20;
            // Show
            ShowChebiao(rect, index, isActive, isFocused);
            if (isFocused) ptFocusedIndex = index;
            if (isActive) ptActiveIndex = index;
        }



        private void OnSelectCallBack(ReorderableList list)
        {
        }

        private void DrawHeaderCallBack(Rect rect)
        {
            EditorGUI.LabelField(rect, "车标配置");
        }

        private void OnChangeCallBack(ReorderableList list)
        {
            // Debug.Log("onchange");
        }

        private void OnAddDropDownCallBack(Rect buttonRect, ReorderableList list)
        {
        }

        private float OnElementHeightCallback(int index)
        {
            Repaint();
            float height = EditorGUIUtility.singleLineHeight;
            //var element = chebiaoList.serializedProperty.GetArrayElementAtIndex(index);
            return height;
        }
        #endregion
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            //
            chebiaoHelper = (CheBiaoHelper)target;

            if (chebiaoHelper.chebiaoRoot == null)
            {
                Debug.LogError("chebiaoRoot is null");
                return;
            }

            var count = chebiaoHelper.chebiaoRoot.transform.childCount;
            chebiaoHelper.chebiaoGameObjects = new GameObject[count];
            for (var i = 0; i < count; i++)
            {
                chebiaoHelper.chebiaoGameObjects[i] = chebiaoHelper.chebiaoRoot.transform.GetChild(i).gameObject;
            }
            //
            colorChoises = chebiaoHelper.GetColorMaterialNames();
            chebiaoChoises = chebiaoHelper.GetCheBiaoNames();
            serializedObject.Update();
            //
            ShowReordListBoxFoldOut("车标配置", chebiaoList, ref showChebiao);

            if (GUILayout.Button("自动关联下注区"))
            {
                // 更新名字
                foreach (var data in chebiaoHelper.chebiaoList)
                    data.UpdateData();
                // 设置关联
                AutoSetLuaInitHelperKey.Set();
                Debug.Log("关联完毕");
            }

            if (GUILayout.Button("逆序排列"))
            {
                chebiaoHelper.chebiaoList.Reverse();
                Debug.Log("逆序完毕");
            }
            #region default
            EditorGUILayout.BeginVertical("box");
            EditorGUI.indentLevel += 1;
            EditorGUILayout.Space();
            if (showDefault = EditorGUILayout.Foldout(showDefault, "Default Inspector"))
            {
                DrawDefaultInspector();
            }
            EditorGUILayout.Space();
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.EndVertical();
            #endregion default

            serializedObject.ApplyModifiedProperties();
        }

        private void ShowChebiao(Rect rect, int index, bool isActive, bool isFocused)
        {
            float width = 90;
            float height = EditorGUIUtility.singleLineHeight;
            //int count = 5;
            CheBiaoData data = chebiaoHelper.chebiaoList[index];
            if (data == null) return;
            //
            EditorGUI.ObjectField(new Rect(width, rect.y, width + 50, height), data.gameObject, typeof(GameObject), true);
            ShowColorChoise(colorChoises, rect, width, height, width * 2, 0, data, index);
            ShowChebiaoChoise(chebiaoChoises, rect, width, height, width * 3, 0, data, index);



            //float dx = rect.x + count * width + count;
            //float w = 40;
            //float h = EditorGUIUtility.singleLineHeight;

            ////
            //EditorGUI.LabelField(new Rect(dx, rect.y, w, h), "颜色 ");
            //dx += w;
            //w = 50;
            //EditorGUI.PropertyField(new Rect(dx, rect.y, w, h),
            //element.FindPropertyRelative("material"), GUIContent.none);
            //dx += w; w = 75;

            //EditorGUI.LabelField(new Rect(dx, rect.y, w, h), "车标");
            //dx += w; w = 50;
            //EditorGUI.PropertyField(new Rect(dx, rect.y, w, h),
            //element.FindPropertyRelative("sprite"), GUIContent.none);
        }

        private void ShowColorChoise(string[] choises, Rect rect, float width, float height, float dx, float dy, CheBiaoData data, int index)
        {
            if (choises == null || choises.Length == 0) return;

            var matIndex = chebiaoHelper.GetColorMaterialIndex(data.material);
            int choiseIndex = matIndex < 0 ? 0 : matIndex;
            int oldIndex = choiseIndex;
            choiseIndex = EditorGUI.Popup(new
                Rect(rect.x + dx, rect.y + dy, width, height),
                choiseIndex, choises);
            //
            bool isDirty = oldIndex != choiseIndex;
            if (isDirty)
            {
                data.material = chebiaoHelper.colorMaterials[choiseIndex];
                data.UpdateData();
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
            }
        }

        private void ShowChebiaoChoise(string[] choises, Rect rect, float width, float height, float dx, float dy, CheBiaoData data, int index)
        {
            if (choises == null || choises.Length == 0) return;
            var sprIndex = chebiaoHelper.GetChebiaoSpriteIndex(data.sprite);
            int choiseIndex = sprIndex < 0 ? 0 : sprIndex;
            int oldIndex = choiseIndex;
            choiseIndex = EditorGUI.Popup(new
                Rect(rect.x + dx, rect.y + dy, width, height),
                choiseIndex, choises);
            // 
            bool isDirty = oldIndex != choiseIndex;
            if (isDirty)
            {
                data.sprite = chebiaoHelper.chebiaoSprites[choiseIndex];
                if(choiseIndex <4)
                    data.material = chebiaoHelper.colorMaterials[1];    // 高级车自动金色
                else
                    data.material = chebiaoHelper.colorMaterials[0];    // 低级车自动银色
                data.UpdateData();
                EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
            }
        }

        #region showProperties
        private void ShowProperties(string[] properties, bool showHierarchy)
        {
            for (int i = 0; i < properties.Length; i++)
            {
                EditorGUILayout.PropertyField(serializedObject.FindProperty(properties[i]), showHierarchy);
            }
        }

        private void ShowPropertiesBox(string[] properties, bool showHierarchy)
        {
            EditorGUILayout.BeginVertical("box");
            EditorGUI.indentLevel += 1;
            EditorGUILayout.Space();
            ShowProperties(properties, showHierarchy);
            EditorGUILayout.Space();
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.EndVertical();
        }

        private void ShowPropertiesBoxFoldOut(string bName, string[] properties, ref bool fOut, bool showHierarchy)
        {
            EditorGUILayout.BeginVertical("box");
            EditorGUI.indentLevel += 1;
            EditorGUILayout.Space();
            if (fOut = EditorGUILayout.Foldout(fOut, bName))
            {
                ShowProperties(properties, showHierarchy);
            }
            EditorGUILayout.Space();
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.EndVertical();
        }

        private void ShowReordListBoxFoldOut(string bName, ReorderableList rList, ref bool fOut)
        {
            EditorGUILayout.BeginVertical("box");
            EditorGUI.indentLevel += 1;
            EditorGUILayout.Space();
            if (fOut = EditorGUILayout.Foldout(fOut, bName))
            {
                rList.DoLayoutList();
            }
            EditorGUILayout.Space();
            EditorGUI.indentLevel -= 1;
            EditorGUILayout.EndVertical();
        }
        #endregion showProperties
    }
}