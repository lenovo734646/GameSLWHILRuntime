using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using TMPro;
using DG.Tweening;
using static LuaInitHelper;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEditor.Events;
using System;
using Object = UnityEngine.Object;
using System.Reflection;

public class SetObjHelper {

    static void print(object str) {
        Debug.Log(str);
    }

    [MenuItem("SubGameHelpers/DoSomething...")]
    static void Fun1() {
        //var EventBroadcaster = GameObject.Find("View").GetComponent<EventBroadcaster>();
        //EventBroadcaster.Init();
        //var betState = EventBroadcaster.GetEvent("betState");
        //var showState = EventBroadcaster.GetEvent("showState");
        
        var betbuttons = GameObject.Find("betbuttons");
        foreach (Transform btn in betbuttons.transform) {
            var hp = btn.GetComponent<LuaInitHelper>();
            print(hp);
            foreach(var v in hp.initList) {
                if (v.name == "totalBetScore"|| v.name == "selfBetScore") {
                    print(v.anyType);
                    if (!(v.anyType is Transform)) continue;
                    var hpt = (v.anyType as Transform).GetComponent<TextMeshProUGUI>();
                    
                    v.anyType = hpt;
                }
            }
            //btn.interactable
            //UnityEventTools.AddBoolPersistentListener(betState, btn.interactable as UnityAction<bool>, true);
            //var prop = typeof(Button).GetProperty("interactable");
            //var action = (UnityAction<bool>)
            //    Delegate.CreateDelegate(typeof(UnityAction<bool>), btn,
            //        prop.GetSetMethod());
            //UnityEventTools.AddBoolPersistentListener(showState, action, false);
        }
        EditorUtility.SetDirty(betbuttons);
        //    var targetinfo = UnityEvent.GetValidMethodInfo(myScriptInstance,
        //"OnButtonClick", new Type[] { typeof(GameObject) });

        //    UnityAction<GameObject> action = Delegate.CreateDelegate(typeof(UnityAction<GameObject>), myScriptInstance, targetinfo, false) as UnityAction<GameObject>;

        //    UnityEventTools.AddObjectPersistentListener<GameObject>(btn.onClick, action, go);


        //UnityEventTools.AddBoolPersistentListener(betState, dotween.DORestart);
        //var obj = GameObject.Find("Road").GetComponent<LuaInitHelper>();
        //for(int i = 0; i < obj.objects.Length; i++) {

        //    var path = AssetDatabase.GetAssetPath(obj.objects[i]);
        //    var spr = AssetDatabase.LoadAssetAtPath<Sprite>(path);
        //    obj.objects[i] = spr;

        //}
        //EditorUtility.SetDirty(obj);
        //var obj = GameObject.Find("Canvas3D").transform.Find("betbuttons");
        //foreach (Transform t in obj) {
        //   var coms = t.GetComponentsInChildren<Image>();
        //    foreach (var img in coms) {
        //        if (img.gameObject == t.gameObject) continue;
        //        var con = img.GetComponent<UGUIColorContrants>();
        //        if (!con) {
        //            con = img.gameObject.AddComponent<UGUIColorContrants>();
        //            con.target = t.GetComponent<CanvasRenderer>();
        //            EditorUtility.SetDirty(t);
        //        }
        //    }
        //}
        //var obj = GameObject.Find("Canvas2D").transform.Find("BetSelectBtns");
        ////var obj = GameObject.Find("View").transform.Find("Canvas3D/BetSelectBtns");

        ////float scale = 1700;
        //var lstner = obj.GetComponent<LuaUnityEventListener>();

        //var list = new List<Object>();
        //foreach(Transform t in obj) {
        //    var chouma = t.Find("chouma");
        //var ToggleEventConverter = chouma.gameObject.GetOrAddComponent<ToggleEventConverter>();
        //    //var dotween = chouma.GetComponent<DOTweenAnimation>();
        //    //if (dotween) {
        //var com = t.GetComponent<Toggle>();

        //        if (com) {
        //        //        UnityEditor.Events.UnityEventTools.RegisterPersistentListener(com.onValueChanged, 0,
        //        //             ToggleEventConverter.OnToggleValueChange);
        //        //        ToggleEventConverter.unityEvent = new UnityEvent();
        //        //        UnityEditor.Events.UnityEventTools.AddPersistentListener(ToggleEventConverter.unityEvent, dotween.DORestart);
        //        UnityEventTools.AddObjectPersistentListener<Object>(com.onValueChanged, lstner.OnCustumEvent2, com);
        //        }
        //   // EditorUtility.SetDirty(com);
        //    //}
        //    //chouma3dobj.localScale = new Vector3(scale, scale, scale);

        //    //list.Add(com);
        //    //var text = t.Find("totalscorebg").GetChild(0).GetComponent<TextMeshProUGUI>();
        //    //if (com.initList.Count != 0) continue;
        //    //TypeData typeData = new TypeData();
        //    //typeData.monoType = text;
        //    //typeData.manualName = "totalBetScore";
        //    //com.initList.Add(typeData);
        //    //text = t.Find("Title").GetChild(0).Find("Text (TMP)").GetComponent<TextMeshProUGUI>();
        //    //typeData = new TypeData();
        //    //typeData.monoType = text;
        //    //typeData.manualName = "selfBetScore";
        //    //com.initList.Add(typeData);
        //    //typeData.monoType = initHelper;
        //    //typeData.manualName = "DataListHelper";
        //    //com.initList.Add(typeData);

        //    //var btn = t.GetComponent<Button>();
        //    //btn.onClick.RemoveAllListeners();
        //    ////UnityEditor.Events.UnityEventTools.AddPersistentListener(btn.onClick);
        //    //UnityEditor.Events.UnityEventTools.RegisterObjectPersistentListener<Object>(btn.onClick, 0,
        //    //     lstner.OnCustumEvent2, com);
        //}
        //initHelper.objects = list.ToArray();

        //var stage = GameObject.Find("View").transform.Find("Environment/animals/stage");
        //var LuaInitHelper = stage.GetComponent<LuaInitHelper>();

        //var count = obj.transform.childCount;
        //foreach (var data in LuaInitHelper.initList) {
        //    data.manualName = "";
        //}
        //foreach (var data in LuaInitHelper.initList) {
        //    var name = data.t.name.Replace("fbx_feiqinzoushou_", "");
        //    for (int i = 0; i < count; i++) {
        //        var t = obj.transform.GetChild(i);
        //        var fbxname = t.Find("animal").GetChild(0).name;
        //        fbxname = fbxname.Replace("fbx_feiqinzoushou_", "").Replace("_jian", "");
        //        if (fbxname == name) {
        //            data.manualName += t.name + ",";
        //        }

        //    }
        //}
        //foreach (var data in LuaInitHelper.initList) {
        //    var name = data.t.name.Replace("fbx_feiqinzoushou_", "");
        //    print(name + " "+ data.manualName);
        //    data.manualName = data.manualName.TrimEnd(',');
        //}
        //GameObject template = null;
        //foreach (Transform t in obj.transform) {
        //    if (t.name == "animal_02") {
        //        template = t.gameObject;
        //    }
        //}
        //foreach (Transform t in obj.transform) {
        //    if (t.name.Contains("animal_")) {
        //        var Animation = t.Find("animal").GetChild(0).GetComponent<Animation>();
        //        var AnimationHelper = t.GetOrAddComponent<AnimationHelper>();
        //        AnimationHelper.animationTarget = Animation;
        //        var list = new List<AnimationClip>();
        //        foreach (AnimationState state in Animation) {
        //            list.Add(state.clip);
        //        }
        //        AnimationHelper.animationClips = list.ToArray();
        //    }
        //}
        //foreach (Transform t in obj.Find("stage")) {
        //    var AnimationHelper = t.GetOrAddComponent<AnimationHelper>();
        //    var Animation = t.GetComponent<Animation>();
        //    var list = new List<AnimationClip>();
        //    AnimationHelper.animationTarget = Animation;
        //    foreach (AnimationState state in Animation) {
        //        list.Add(state.clip);
        //    }
        //    AnimationHelper.animationClips = list.ToArray();
        //}
        //foreach(GameObject gameObject in obj.GetComponent<LuaInitHelper>().objects) {
        //    var dt = gameObject.transform.Find("texiao").gameObject.GetComponent<DOTweenAnimation>();
        //    dt.duration = 0.3f;
        //    dt.animationType = DOTweenAnimation.AnimationType.Fade;
        //    dt.autoKill = false;
        //    dt.isFrom = true;
        //    dt.easeType = Ease.InQuad;
        //    dt.autoPlay = true;
        //    dt.endValueFloat = 1;
        //}

    }

    [MenuItem("SubGameHelpers/切换stage可见")]
    static void Fun4() {
        var obj = GameObject.Find("View").transform.Find("Environment/animals/stage");
        //obj.gameObject.SetActive(!obj.gameObject.activeInHierarchy);
        foreach (Transform t in obj.transform) {
            var o = t.gameObject;
            o.SetActive(!o.activeInHierarchy);
        }
        EditorUtility.SetDirty(obj);
    }

    [MenuItem("SubGameHelpers/切换动物可见")]
    static void Fun2() {
        var obj = GameObject.Find("View").transform.Find("Environment/animals/animalIndexs");

        foreach (Transform t in obj.transform) {
            var o = t.Find("animal").gameObject;
            o.SetActive(!o.activeInHierarchy);
        }
        EditorUtility.SetDirty(obj);
    }

    [MenuItem("SubGameHelpers/切换动物中奖特效")]
    static void Fun3() {
        var obj = GameObject.Find("View").transform.Find("Environment/animals/animalIndexs");

        foreach (Transform t in obj.transform) {
            var o = t.Find("animal").GetChild(0).Find("Effect_FeiQinZouShou_XuanZhong").gameObject;
            o.SetActive(!o.activeInHierarchy);
        }
        EditorUtility.SetDirty(obj);
    }

    [MenuItem("SubGameHelpers/切换路径碰撞体显示")]
    static void Fun5() {
        var o = GameObject.Find("View").transform.Find("Environment/animals/IconPos/ForDebugCube").gameObject;
        o.SetActive(!o.activeInHierarchy);
        print(o+" "+o.activeInHierarchy);
        EditorUtility.SetDirty(o);
    }
}
