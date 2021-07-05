using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;


public class EventForwarding : MonoBehaviour
{
    public float delayForwarding = 0;

    //不增加参数的转发，由OnEventCall启动
    public CustomObjectEvent customObjectEvent;


    //新的转发,0.83后支持
    public CustomObjectsEvent customObjectsEvent;
    public CustomUnityObjectsEvent customUnityObjectsEvent;

    public bool use_customUnityObjectsEvent = true;
    public string addStrParam;
    public string[] addStrsParam;
    public Object addObjectParam;
    public Object[] addObjectsParam;

    public void ForwardAddStrParam(object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj as Object, new object[] { addStrParam });
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addStrParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addStrParam }));
        }
    }

    public void ForwardAddStrParamU(Object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj, new object[] { addStrParam });
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addStrParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj,addStrParam}));
        }
    }
    public void ForwardAddStrsParam(object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj as Object, addStrsParam);
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addStrsParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addStrsParam }));
        }
    }
    public void ForwardAddStrsParamU(Object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj, addStrsParam);
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addStrsParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addStrsParam }));
        }
    }
    public void ForwardAddObjectParam(object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj as Object, new object[] { addObjectParam });
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addObjectParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addObjectParam }));
        }
    }
    public void ForwardAddObjectParamU(Object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj, new object[] { addObjectParam });
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addObjectParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addObjectParam }));
        }
    }

    public void ForwardAddObjectsParam(object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj as Object, addObjectsParam);
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addObjectsParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addObjectsParam }));
        }
    }
    public void ForwardAddObjectsParamU(Object obj) {
        if (delayForwarding == 0) {
            if (use_customUnityObjectsEvent) {
                customUnityObjectsEvent?.Invoke(obj, addObjectsParam);
            } else
                customObjectsEvent?.Invoke(new object[] { obj, addObjectsParam });
        } else {
            StartCoroutine(cForwardCall(new object[] { obj, addObjectsParam }));
        }
    }

    IEnumerator cForwardCall(object[] objs) {
        yield return new WaitForSeconds(delayForwarding);
        if (use_customUnityObjectsEvent) {
            object[] objs_ = null;
            if (objs.Length > 1) {
                objs_ = new object[objs.Length-1];
                Array.Copy(objs,1,objs_,0,objs_.Length);
            }
            customUnityObjectsEvent?.Invoke(objs[0] as Object, objs_);
        } else
            customObjectsEvent?.Invoke(objs);
    }

    public void OnEventCall(object @object) {
        if (delayForwarding == 0) {
            customObjectEvent?.Invoke(@object);
        } else {
            StartCoroutine(cDelayCall(@object));
        }
    }

    IEnumerator cDelayCall(object @object) {
        yield return new WaitForSeconds(delayForwarding);
        customObjectEvent?.Invoke(@object);
    }

    private void OnDestroy() {
        customObjectEvent.RemoveAllListeners();
    }
}
