using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class CustomObjectEvent : UnityEvent<object> {}
[System.Serializable]
public class CustomUnityObjectEvent : UnityEvent<Object> {}
[System.Serializable]
public class CustomUnityBoolEvent : UnityEvent<bool> {}
[System.Serializable]
public class CustomUnityStringEvent : UnityEvent<string> {}
[System.Serializable]
public class CustomUnityIntEvent : UnityEvent<int> {}
[System.Serializable]
public class CustomUnityFloatEvent : UnityEvent<float> {}