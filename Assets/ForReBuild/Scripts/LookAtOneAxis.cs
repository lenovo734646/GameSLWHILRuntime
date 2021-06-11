using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class LookAtOneAxis : MonoBehaviour {
    public Transform target;
    public bool keepX = false;
    public bool keepY = true;
    public bool keepZ = true;

    Vector3 originalRot;
    // Start is called before the first frame update
    void Start() {
        originalRot = transform.eulerAngles;
    }

    // Update is called once per frame
    void Update() {
        if (!target) return;
        if (keepX && keepY && keepZ) return;
        var pos = transform.position;
        var tpos = target.position;
        var offset = pos - tpos;
        transform.LookAt(transform.position + offset);
        var eulerAngles = transform.eulerAngles;
        if (keepX) eulerAngles.x = originalRot.x;
        if (keepY) eulerAngles.y = originalRot.y;
        if (keepZ) eulerAngles.z = originalRot.z;
        transform.eulerAngles = eulerAngles;
    }
}
