using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Events;
using UnityEngine;
using UnityEngine.UI;

public class ButtonSoundHelper : MonoBehaviour
{
    [MenuItem("Assets/添加按钮音效到文件夹中的prefab")]
    static void AddBtnSoundToSelectedFolder()
    {
        string[] strs = Selection.assetGUIDs;

        string path = AssetDatabase.GUIDToAssetPath(strs[0]);
        Debug.Log("path:" + path);
        AddBtnSoundToFolder(path);
    }
    [MenuItem("Assets/添加按钮音效到选中的prefab")]
    static void AddBtnSoundToSelected()
    {
        var obj = Selection.activeGameObject;
        var btns = obj.GetComponentsInChildren<Button>(true);
        foreach (var btn in btns)
        {
            addbtnsoundtobtn(btn);
        }
    }
    static void AddBtnSoundToFolder(string flodername)
    {
        var prefabs = EditorUtil.GetAllPrefabs(flodername);
        foreach (GameObject item in prefabs)
        {
            var btns = item.GetComponentsInChildren<Button>(true);
            bool isdirty = false;
            foreach (var btn in btns)
            {
                addbtnsoundtobtn(btn);
                isdirty = true;
            }
            if (isdirty)
                PrefabUtility.SavePrefabAsset(item);
        }
        AssetDatabase.Refresh();
    }
    static void addbtnsoundtobtn(Button button)
    {
        var onClick = button.onClick;
        var count = onClick.GetPersistentEventCount();
        for (int i = 0; i < count; i++)
        {
            var obj = onClick.GetPersistentTarget(i);
            if (obj is EventPlayAudio)
            {
                return;
            }
        }
        var eventPlayAudio = button.transform.root.GetOrAddComponent<EventPlayAudio>();
        UnityEventTools.AddStringPersistentListener(onClick, eventPlayAudio.PlaySoundEff2D, "btnSound");
        Debug.Log($"添加EventPlayAudio到 {button.name} root:{button.transform.root.gameObject.name}");



        EditorUtility.SetDirty(button.transform.root.gameObject);
        //PrefabUtility.SavePrefabAsset(button.transform.root.gameObject);
    }
}
