using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using static UnityEngine.UI.Toggle;

// 一个开关事件调用脚本

public class SwitchEvent : MonoBehaviour
{
    public UnityEvent onEvent = new UnityEvent();
    public UnityEvent offEvent = new UnityEvent();
    ///public ToggleEvent switchEvent = new ToggleEvent();
    public bool isOn = false;

    //public void Invoke()
    //{
    //    switchEvent.Invoke(isOn);
    //}

    public void OnSwitch()
    {
        isOn = !isOn;
        Invoke();

    }

    private void Invoke()
    {
        if(isOn)
        {
            onEvent.Invoke();
        }
        else
        {
            offEvent.Invoke();
        }
    }
}
