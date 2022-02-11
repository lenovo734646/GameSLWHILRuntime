using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

public class KeyEventListener : LuaBaseEventListener {
    public enum KeyEventType{
        KeyDown = 1,
        KeyUp,
        Key,
    }

    [System.Serializable]
    public class KeyEvent {
        public KeyCode keyCode = KeyCode.None;
        public KeyEventType keyEventType = KeyEventType.KeyDown;
        public CustomObjectEvent keyEvent;
    }

    [System.Serializable]
    public class MouseButtonEvent {
        public int keyCode;
        public KeyEventType keyEventType;
        public CustomObjectEvent keyEvent;
    }

    public List<KeyEvent> keyEvents = new List<KeyEvent>();
    public List<MouseButtonEvent> mouseButtonEvents = new List<MouseButtonEvent>();

    protected override void OnDestroyPrecall() {
        foreach (var e in keyEvents) {
            e.keyEvent.RemoveAllListeners();
        }
        foreach (var e in mouseButtonEvents) {
            e.keyEvent.RemoveAllListeners();
        }
    }

    private void Update() {
        for (int i = 0; i < keyEvents.Count; i++) {
            var value = keyEvents[i];
            switch (value.keyEventType) {
                case KeyEventType.Key:
                    if (Input.GetKey(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call($"On{value.keyCode}Key");
                    }
                    break;

                case KeyEventType.KeyDown:
                    if (Input.GetKeyDown(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call($"On{value.keyCode}KeyDown");
                    }
                    break;

                case KeyEventType.KeyUp:
                    if (Input.GetKeyUp(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call($"On{value.keyCode}KeyUp");
                    }
                    break;
            }
        }
        for (int i = 0; i < mouseButtonEvents.Count; i++) {
            var value = mouseButtonEvents[i];
            switch (value.keyEventType) {
                case KeyEventType.Key:
                    if (Input.GetMouseButton(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call("OnMouseButton", value.keyCode);
                    }
                    break;

                case KeyEventType.KeyDown:
                    if (Input.GetMouseButtonDown(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call("OnMouseButtonDown", value.keyCode);
                    }
                    break;

                case KeyEventType.KeyUp:
                    if (Input.GetMouseButtonUp(value.keyCode)) {
                        value.keyEvent?.Invoke(value.keyCode);
                        call("OnMouseButtonUp", value.keyCode);
                    }
                    break;
            }
        }
    }
}
