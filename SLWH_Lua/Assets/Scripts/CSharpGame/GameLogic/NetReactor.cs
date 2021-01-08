using Google.Protobuf;

using Newtonsoft.Json;
using SubGameNet;
using System;
using UnityEngine;

public class NetReactor : INetReactor {
    private Message sendMsg;
    public Message SendMsg {
        get {
            if (null == sendMsg)
                sendMsg = new Message(MsgType.NET_CONNECT, this);
            return sendMsg;
        }
    }



    /// <summary>
    /// 连接遇到错误 
    /// </summary>
    public void onNetConnectError() {
        SendMsg.Content = EnumNetConnectState.Error;
        SendMsg.Send();
    }

    /// <summary>
    /// 连接成功
    /// </summary>
    public void onNetConnectEstablished() {
        SendMsg.Content = EnumNetConnectState.Established;
        SendMsg.Send();
    }

    /// <summary>
    /// 连接被断开
    /// </summary>
    public void onNetDisconnect() {
        SendMsg.Content = EnumNetConnectState.Disconnect;
        SendMsg.Send();
    }

    #region 修改 protobuffer 协议添加的方法
    #endregion 

    public void onSendMessage(IMessage message) {
        //var msg = string.Format("protobuffer {0} 发送 {1}:{2}",
        //    DateTime.Now.ToString("HH:mm:ss:fff"), message.Descriptor.FullName, message.ToString());
        //Debug.Log(msg);
    }

    public void onRecvMessage(IMessage message) {
        //var msg = string.Format("protobuffer {0} 接收 {1}:{2}", DateTime.Now.ToString("HH:mm:ss:fff"),
        //message.Descriptor.FullName, message.ToString());
        //Debug.Log(msg);
    }

    public void onSendMessage(INetProtocol proto) {
        //throw new NotImplementedException();
    }

    public void onRecvMessage(INetProtocol proto) {
        //throw new NotImplementedException();
    }
}
