using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class LuaUIEventListener : LuaBaseEventListener {


    private void OnMouseDown() {
        call("OnMouseDown");
    }
    private void OnMouseDrag() {
        call("OnMouseDrag");
    }
    private void OnMouseEnter() {
        call("OnMouseEnter");
    }
    private void OnMouseExit() {
        call("OnMouseExit");
    }
    private void OnMouseOver() {
        call("OnMouseOver");
    }
    private void OnMouseUp() {
        call("OnMouseUp");
    }
    private void OnMouseUpAsButton() {
        call("OnMouseUpAsButton");
    }
    private void OnCanvasGroupChanged() {
        call("OnCanvasGroupChanged");
    }
    private void OnRectTransformDimensionsChange() {
        call("OnRectTransformDimensionsChange");
    }
    private void OnRectTransformRemoved() {
        call("OnRectTransformRemoved");
    }
    private void OnTransformChildrenChanged() {
        call("OnTransformChildrenChanged");
    }
    private void OnTransformParentChanged() {
        call("OnTransformParentChanged");
    }
    private void OnBeforeTransformParentChanged() {
        call("OnBeforeTransformParentChanged");
    }
    
}
