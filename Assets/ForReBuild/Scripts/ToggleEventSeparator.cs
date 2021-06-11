using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ToggleEventSeparator : MonoBehaviour
{
    public UnityEvent toggleTrueEvent;
    public UnityEvent toggleFalseEvent;
    public void OnToggleValueChange(bool b) {
        if (b) {
            toggleTrueEvent?.Invoke();
        } else {
            toggleFalseEvent?.Invoke();
        }
    }
}
