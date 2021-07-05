using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class LuaGraphicEventListener : LuaBaseEventListener {



    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        call("OnRenderImage", source, destination);
    }

    private void OnRenderObject() {
        call("OnRenderObject");
    }
    private void OnPostRender() {
        call("OnPostRender");
    }
    private void OnPreRender() {
        call("OnPreRender");
    }
    private void OnPreCull() {
        call("OnPreCull");
    }
    private void OnWillRenderObject() {
        call("OnWillRenderObject");
    }
    private void OnBecameVisible() {
        call("OnBecameVisible");
    }
    private void OnBecameInvisible() {
        call("OnBecameInvisible");
    }
}
