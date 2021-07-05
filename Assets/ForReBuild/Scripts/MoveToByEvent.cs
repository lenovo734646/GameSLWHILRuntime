using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class MoveToByEvent : MonoBehaviour
{
    public UnityEvent trigger;
    public void OnEventCall(Transform t) {
        transform.position = t.position;
        trigger?.Invoke();
    }

    private void OnDestroy() {
        trigger.RemoveAllListeners();
    }
}
