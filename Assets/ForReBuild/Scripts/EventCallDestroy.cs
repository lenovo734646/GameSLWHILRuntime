using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EventCallDestroy : MonoBehaviour
{
    public Object target;
    public void DoDestroy() {
        if (target) {
            Destroy(target);
        } else {
            Destroy(gameObject);
        }
    }
}
