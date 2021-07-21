
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

using System;
using System.Collections;
using UnityEngine;
//using JBPROTO;
using System.Collections.Generic;
using QL.Core;
//using QL.Protocol;
using System.Linq;
using System.Threading.Tasks;
using XLua;
using System.Threading;
using System.Text;
using SubGameNet;

public class QWebRequset : IQLRequest {


    Dictionary<string, string> headerParameters = new Dictionary<string, string>();
    Dictionary<string, string> parameters = new Dictionary<string, string>();
    string apiname = "";

    public QWebRequset(string apiname, 
        string[] headerparam, string[] param) {
        this.apiname = apiname;
        for(int i=0;i< headerparam.Length; i += 2) {
            headerParameters.Add(headerparam[i], headerparam[i+1]);
        }
        for (int i = 0; i < param.Length; i += 2) {
            parameters.Add(param[i], param[i + 1]);
        }
    }

    public string GetApiName() {
        return apiname;
    }

    public IDictionary<string, string> GetHeaderParameters() {
        return headerParameters;
    }

    public IDictionary<string, string> GetParameters() {
        return parameters;
    }

    public void Validate() {
        
    }
}

public class QLUploadRequest : IQLUploadRequest {


    Dictionary<string, string> headerParameters = new Dictionary<string, string>();
    Dictionary<string, string> parameters = new Dictionary<string, string>();
    Dictionary<string, QLFileItem> fileParameters = new Dictionary<string, QLFileItem>();
    string apiname = "";

    public QLUploadRequest(string apiname,
        string[] headerparam, string[] param, object[] fileparam) {
        this.apiname = apiname;
        for (int i = 0; i < headerparam.Length; i += 2) {
            headerParameters.Add(headerparam[i], headerparam[i + 1]);
        }
        for (int i = 0; i < param.Length; i += 2) {
            parameters.Add(param[i], param[i + 1]);
        }
        for (int i = 0; i < fileparam.Length; i += 2) {
            fileParameters.Add((string)fileparam[i], (QLFileItem)fileparam[i + 1]);
        }
    }

    public string GetApiName() {
        return apiname;
    }

    public IDictionary<string, QLFileItem> GetFileParameters() {
        return fileParameters;
    }

    public IDictionary<string, string> GetHeaderParameters() {
        return headerParameters;
    }

    public IDictionary<string, string> GetParameters() {
        return parameters;
    }

    public void Validate() {

    }
}



public class NetController: MonoBehaviour
{
    public static NetController Instance { get; private set; }
    public static bool IsNetConnected
    {
        get
        {
            if (!Instance) return false;
            return Instance.IsConnected;
        }
    }
    public bool IsConnected { get => netComponent.IsConnected; }
    public string serverUrl = "";
    private DefaultQLClient webClient;
    public DefaultQLClient WebClient
    {
        get
        {
            //这里会在非主线程调用！！
            if (null == webClient)
            {
                webClient = new DefaultQLClient("client", "mbXr8nNL3Gnust17");
                webClient.ServerUrl = serverUrl;
            }
            return webClient;
        }
    }

    public class WaitForConnect : CustomYieldInstruction {
        public override bool keepWaiting => state=="";
        public string state="";

        public WaitForConnect(string ip, int port, 
            int timeoutInSeconds=5) {
            Instance.netComponent.ConnectWithTimeout(ip,port,timeoutInSeconds*1000,str=> {
                state = str;
            });
        }
    }

    public NetComponent netComponent = new NetComponent();
    public HashSet<string> luaWillHandleMsgName = new HashSet<string>();

    public void AddLuaWillHandleMsg(string name) {
        luaWillHandleMsgName.Add(name);
    }
    public void RemoveLuaWillHandleMsg(string name) {
        luaWillHandleMsgName.Remove(name);
    }
    public void ClearLuaWillHandleMsg() {
        luaWillHandleMsgName.Clear();
    }

    private void Awake()
    {
        Instance = this;
        netComponent.RecvDataFunc = (data) => {
            MessageCenter.Instance.SendMessage(MsgType.NET_RECEIVE_DATA, data, data);
        };
        netComponent.LostConnectionCallBack = (error, key) => {
            Debug.LogWarning(error+" haskey:"+(key!=null));//注意此处在非主线程
        };
    }

    private void Update()
    {
        netComponent.Update();
    }

    private void OnDestroy() {
        Instance = null;
        netComponent.Dispose();
    }

    public void PostLuaRequest(QLUploadRequest request, Action<object> action) {
        asyncExecuteWebRequestLua(request, webRsp => {
            action(webRsp);
        });
    }
    public void PostLuaRequest(QWebRequset request, Action<object> action) {
        asyncExecuteWebRequestLua(request, webRsp => {
            action(webRsp);
        });
    }


    private async void asyncExecuteWebRequestLua(IQLRequest request, Action<object> callback) {
        string body = "";
        var webRsp = await Task.Run(() => WebClient.Execute<QLResponse>(request, null, DateTime.Now, ref body));
        if (webRsp == null) {
            callback?.Invoke(body);
        } else {
            callback?.Invoke(webRsp.Body);
        }
        
    }


    public void SetKey(int[] key) {
        if (key.Length == 0) {
            throw new Exception("key len == 0");
        }
        var bytes = new byte[key.Length];
        for(int i = 0; i < key.Length; i++) {
            bytes[i] = (byte)key[i];
        }
        netComponent.SetRandomKey(bytes);
    }


   
    //protected override void onApplicationQuit() {
    //    netComponent.Dispose();
    //}

    //protected override void onDestroy() {
    //    netComponent.Dispose();
    //}
}