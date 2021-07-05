using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EventBroadcasterWithParam : MonoBehaviour
{
    [System.Serializable]
    public class Event {
        public string name;
        public CustomObjectEvent UnityEvent;
    }

    public List<Event> events;

    Dictionary<string, CustomObjectEvent> eventMap = new Dictionary<string, CustomObjectEvent>();

    public void Init() {
        eventMap.Clear();
        foreach (var e in events) {
            eventMap.Add(e.name, e.UnityEvent);
        }
    }

    private void Awake() {
        Init();
    }

    private void OnDestroy() {
        eventMap.Clear();
        foreach (var e in events) {
            e.UnityEvent.RemoveAllListeners();
        }
    }

    public void Broadcast(string eveName, object param) {
        if (eventMap.TryGetValue(eveName,out CustomObjectEvent @event)) {
            @event?.Invoke(param);
        } else {
            Debug.LogWarning($"事件 {eveName} 不存在");
        }
    }

    public void AddListner(string eveName, System.Action<object> action) {
        var e = new CustomObjectEvent();
        e.AddListener((param)=> {
            action(param);
        });
        eventMap.Add(eveName, e);
    }
    public void RemoveListner(string eveName) {
        eventMap.Remove(eveName);
    }

    public CustomObjectEvent GetEvent(string eveName) {
        eventMap.TryGetValue(eveName, out CustomObjectEvent @event);
        return @event;
    }
}
