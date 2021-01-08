using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Object = UnityEngine.Object;


public class EventForwarding : MonoBehaviour
{
    public float delayForwarding = 0;

    public CustomObjectEvent customObjectEvent;

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
}
