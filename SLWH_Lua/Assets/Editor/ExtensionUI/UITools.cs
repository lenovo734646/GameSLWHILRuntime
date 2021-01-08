using UnityEditor;
using UnityEditor.Events;
using UnityEngine;
using UnityEngine.UI;

public class UITools
{
    [MenuItem("GameObject/UI/复制名字列表到剪贴板",false,0)]
    static void CopyNames() {
        if (Selection.objects.Length <= 0) return;
        var objs = Selection.gameObjects;
        var s = "";
        foreach (GameObject obj in objs) {
            s += obj.name+"\n";
        }
        GUIUtility.systemCopyBuffer = s;
        Selection.objects = null;
    }
    [MenuItem("GameObject/UI/移除一个Button事件(从index0)", false, 0)]
    static void ButtonEventRemove() {
        if (Selection.objects.Length <= 0) return;
        var objs = Selection.gameObjects;
        foreach(GameObject obj in objs) {
            var btn = obj.GetComponent<Button>();
            if (btn && btn.onClick.GetPersistentEventCount()>0) {
                UnityEventTools.RemovePersistentListener(btn.onClick,0);
                EditorUtility.SetDirty(btn);
            }  
        }
        Selection.objects = null;
    }
    [MenuItem("GameObject/UI/添加一个Button事件到Root的LuaUnityEventListener(OnCustumObjectEvent)", false, 0)]
    static void ButtonEventAdd() {
        if (Selection.objects.Length <= 0) return;
        var objs = Selection.gameObjects;
        var oneofobj = objs[0];
        var root = oneofobj.transform.root;
        if(root.name.Contains("Canvas (Environment)")) {
            root = root.transform.GetChild(0);
        }
        var lstner = root.GetComponent<LuaUnityEventListener>();
        if (!lstner) {
            Debug.LogWarning("root 不存在LuaUnityEventListener "+ root);
            return;
        }
        foreach (GameObject obj in objs) {
            var btn = obj.GetComponent<Button>();
            if (btn) {
                UnityEventTools.AddObjectPersistentListener(btn.onClick, lstner.OnCustumObjectEvent, btn);
                EditorUtility.SetDirty(btn);
            }
        }
        Selection.objects = null;
    }


    //#region 自动取消RatcastTarget
    //Image
    [MenuItem("GameObject/UI/Image(自动取消RaycastTarget)")]
    static void CreatImage()
    {
        var activeTrans = Selection.activeTransform;
        if (activeTrans)
        {
            if (activeTrans.GetComponentInParent<Canvas>())
            {
                GameObject creatObj = new GameObject("Image", typeof(Image));
                creatObj.GetComponent<Image>().raycastTarget = false;
                creatObj.transform.SetParent(activeTrans, false);
                Selection.activeGameObject = creatObj;
            }
        }
    }

    [MenuItem("Component/UI/Image(自动取消RaycastTarget)")]
    static void AddComponentImage()
    {
        var activeObj = Selection.activeGameObject;
        if (activeObj)
        {
            if (activeObj.GetComponent<RectTransform>())
            {
                var image = activeObj.AddComponent<Image>();
                image.raycastTarget = false;
            }
        }
    }

    //Text
    [MenuItem("GameObject/UI/MyText")]
    static void CreatText()
    {
        var activeTrans = Selection.activeTransform;
        if (activeTrans)
        {
            if (activeTrans.GetComponentInParent<Canvas>())
            {
                GameObject creatObj = new GameObject("Text", typeof(Text));
                creatObj.GetComponent<RectTransform>().sizeDelta = new Vector2(160, 30);
                var text = creatObj.GetComponent<Text>();
                text.supportRichText = false;
                text.raycastTarget = false;
                creatObj.transform.SetParent(activeTrans, false);
                Selection.activeGameObject = creatObj;
            }
        }
    }

    [MenuItem("Component/UI/MyText")]
    static void AddComponentText()
    {
        var activeObj = Selection.activeGameObject;
        if (activeObj)
        {
            if (activeObj.GetComponent<RectTransform>())
            {
                var text = activeObj.AddComponent<Text>();
                text.raycastTarget = false;
                text.supportRichText = false;
            }
        }
    }
    //#endregion

    [MenuItem("Tools/通用工具/切换物体显隐状态 %q")]
    static void SetObjActive()
    {
        GameObject[] selectObjs = Selection.gameObjects;
        int objCtn = selectObjs.Length;
        for (int i = 0; i < objCtn; i++)
        {
            bool isAcitve = selectObjs[i].activeSelf;
            selectObjs[i].SetActive(!isAcitve);
        }
    }
}
