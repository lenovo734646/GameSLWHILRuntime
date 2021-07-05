using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Check3DObjOutScreen : MonoBehaviour {
    public CustomUnityBoolEvent OutScreenCheck = new CustomUnityBoolEvent();
    public Camera cam;
    public Vector2 offsetmin = new Vector2();
    public Vector2 offsetmax = new Vector2();
    public bool justDoInStart = false;
    public bool justDoInStartDestroy = true;
    [HideInInspector]
    public bool lastInscreen = false;

    Rect rect;
    Transform t;
    
    void Awake() {
        t = transform;

    }

    private void Start() {
        if (!cam) {
            cam = Camera.main;
        }
        lastInscreen = CheckOutScreen();
        //print("lastInscreen:" + lastInscreen);
        OutScreenCheck.Invoke(lastInscreen);
        if (justDoInStart && justDoInStartDestroy)
            Destroy(gameObject);
    }

    public bool CheckOutScreen() {
        var pos = cam.WorldToScreenPoint(t.position);


        rect = Screen.safeArea;
        rect.min += offsetmin;
        rect.max += offsetmax;

        return rect.Contains(pos);
    }

    // Update is called once per frame
    void Update() {
        if (justDoInStart) return;
        var b = CheckOutScreen();
        if (b != lastInscreen) {
            OutScreenCheck.Invoke(b);
            //print("inscreen2:" + lastInscreen);
            lastInscreen = b;
        }
    }

    private void OnDestroy() {
        OutScreenCheck.RemoveAllListeners();
    }
}
