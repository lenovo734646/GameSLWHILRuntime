using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UGUIColorContrants : MonoBehaviour
{
    public CanvasRenderer target;

    CanvasRenderer canvasRederer;
    Material material;
    private void Awake() {
        var render = GetComponent<Renderer>();
        if (render)
            material = render.material;
        else
            canvasRederer = GetComponent<CanvasRenderer>();
    }

    private void Update() {
        if (material)
            material.color = target.GetColor();
        else {
            canvasRederer.SetColor(target.GetColor());
        }
    }
}
