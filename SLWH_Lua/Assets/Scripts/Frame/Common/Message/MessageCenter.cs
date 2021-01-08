
/******************************************************************************
 * 
 *  Title:  捕鱼项目
 *
 *  Version:  1.0版
 *
 *  Description:
 *
 *  Author:  WangXingXing
 *       
 *  Date:  2018
 * 
 ******************************************************************************/

using System.Collections.Generic;
using UnityEngine;

public class MessageCenter : Singleton<MessageCenter> {

    //public static MessageCenter Instance { get; private set; }
    //private void Awake() {
    //    Instance = this;
    //}

    class MessageEventData {
        public MessageEvent messageEvent;
        public bool autoRemove;
    }

    private Dictionary<string, List<MessageEventData>> dicMsgEvents = new Dictionary<string, List<MessageEventData>>();

    HashSet<string> redirectToLua = new HashSet<string>();


    public void AddToRedirectToLua(string messageName) {
        redirectToLua.Add(messageName);
    }
    public void RemoveFromRedirectToLua(string messageName) {
        redirectToLua.Remove(messageName);
    }

    public void ClearRedirectToLua() {
        redirectToLua.Clear();
    }


    public void AddListener(string messageName, MessageEvent messageEvent, bool autoRemove = false)
    {
        MessageEventData messageEventData = new MessageEventData();
        messageEventData.messageEvent = messageEvent;
        messageEventData.autoRemove = autoRemove;

        List<MessageEventData> list;
        if (!dicMsgEvents.TryGetValue(messageName, out list)) {
            list = new List<MessageEventData>();
            dicMsgEvents.Add(messageName, list);
        }
        list.Add(messageEventData);
    }

    public void RemoveListener(string messageName, MessageEvent messageEvent)
    {
        List<MessageEventData> list;
        if (dicMsgEvents.TryGetValue(messageName, out list)) {
            var index = list.FindIndex(0,data=>data.messageEvent==messageEvent);
            if (index>=0) {
                list.RemoveAt(index);
                if (list.Count <= 0) {
                    dicMsgEvents.Remove(messageName);
                }
            }
        }
    }
    public void RemoveOneTypeListener(string messageName) {
        dicMsgEvents.Remove(messageName);
    }

    public void RemoveAllListener()
    {
        dicMsgEvents.Clear();
    }

    public void SendMessage(Message message)
    {
        DoMessageDispatcher(message);
    }

    public void SendMessage(string name, object sender, object content = null, params object[] dicParams)
    {
        SendMessage(new Message(name, sender, content, dicParams));
    }

    private void DoMessageDispatcher(Message message)
    {
        if (redirectToLua.Contains(message.Name)) {//让Lua可以做到事件拦截处理
            var objs = GLuaSharedHelper.CallLua(message.Name, message.Sender, message.Content, message.DicParamsRaw);
            if (objs == null) return;
            if (objs.Length < 0 || (bool)objs[0] == false) {
                return;
            }
        }

        if(dicMsgEvents.TryGetValue(message.Name, out List<MessageEventData> list)) {
            for (int i = list.Count-1; i >=0; i--) {
                list[i].messageEvent?.Invoke(message);
                if (list[i].autoRemove) {
                    list.RemoveAt(i);
                    if (list.Count == 0) {
                        dicMsgEvents.Remove(message.Name);
                        break;
                    }
                }
            }
        }
    }



    List<Message> msgQueue = new List<Message>();

    //线程安全
    public void PostMessage(Message message) {
        lock (msgQueue) {
            msgQueue.Add(message);
        }
    }

    private void Update() {
        if(msgQueue.Count > 0) {
            Message[] copy = null;
            lock (msgQueue) {
                copy = msgQueue.ToArray();
                msgQueue.Clear();
            }
            if (copy != null) {
                foreach(var msg in copy) {
                    SendMessage(msg);
                }
            }
        }
    }
}