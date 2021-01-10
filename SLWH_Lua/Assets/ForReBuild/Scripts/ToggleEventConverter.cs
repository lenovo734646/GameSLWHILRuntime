using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

public class ToggleEventConverter : MonoBehaviour {
    [CustomEditorName("在True的时候发送")]
    public bool playWithTrue = true;

    public UnityEvent unityEvent;

    public Toggle.ToggleEvent onValueChangedReverse;

    public void OnToggleValueChange(bool b) {
        if (!playWithTrue) {
            b = !b;
        }
        if (b) {
            unityEvent?.Invoke();
        }
    }

    public void OnToggleValueReverse(bool b)
    {
        b = !b;
        onValueChangedReverse?.Invoke(b);
    }
}
