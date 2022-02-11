using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EventBroadcaster : MonoBehaviour
{
    [System.Serializable]
    public class Event {
        public string name;
        [CustomEditorName("延迟广播（毫秒）")]
        public int delayInMillisecond = 0;//延迟广播，毫秒
        public UnityEvent UnityEvent;
    }
    public bool showLog = false;
    public Event[] events;

    

    Dictionary<string, Event> eventMap = new Dictionary<string, Event>();

    public void Init() {
        eventMap.Clear();
        foreach (var e in events) {
            eventMap.Add(e.name, e);
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

    public void Broadcast(string evetName) {
        
        if (eventMap.TryGetValue(evetName, out Event @event)) {
            if(@event.delayInMillisecond > 0) {
                StartCoroutine(cDelay(@event));
            } else {
                if (showLog)
                    print("Broadcast " + evetName);
                @event.UnityEvent?.Invoke();
            }
            
        } else {
            Debug.LogWarning($"事件 {evetName} 不存在，或组件未激活（GameObject UnActive）");
        }
    }

    public void BroadcastDefault() {
        BroadcastByIndex(1);
    }

    public void BroadcastByRawIndex(int index) {
        index++;
        BroadcastByIndex(index);
    }

    public void BroadcastByIndex(int index) {
        index -= 1;//转换成C#下标
        if (index >= 0 && index < events.Length) {
            var @event = events[index];
            if (@event.delayInMillisecond > 0) {
                StartCoroutine(cDelay(@event));
            } else {
                if (showLog)
                    print("BroadcastByIndex " + @event.name+ " index:"+index);
                @event.UnityEvent?.Invoke();
            }
        } else {
            Debug.LogWarning($"事件 index:{index} 不存在");
        }
    }

    IEnumerator cDelay(Event @event) {
        yield return new WaitForSeconds(@event.delayInMillisecond/1000.0f);
        if (showLog) {
            print("Broadcast " + @event.name);
        }
        @event.UnityEvent?.Invoke();
    }


   

    public void AddListner(string evetName, System.Action action, int delayInMillisecond) {
        var e = new UnityEvent();
        e.AddListener(()=> {
            action();
        });
        eventMap.Add(evetName, new Event() 
        { name=evetName, UnityEvent = e , delayInMillisecond = delayInMillisecond});
    }
    public void RemoveListner(string evetName) {
        eventMap.Remove(evetName);
    }

    public UnityEvent GetEvent(string evetName) {
        eventMap.TryGetValue(evetName, out Event @event);
        return @event.UnityEvent;
    }
}
