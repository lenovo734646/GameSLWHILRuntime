﻿
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

using UnityEngine;

public class CoroutineController : DDOLSingleton<CoroutineController> {

    private Coroutine aliveCor = null;

    private Coroutine reconnetCor = null;
    private bool isReconnecting = false;

    public void StartAliveCor() {
        aliveCor = StartCoroutine(NetController.Instance.SendTKeepAlive());
    }

    public void StopAliveCor() {
        if (aliveCor != null) {
            StopCoroutine(aliveCor);
            aliveCor = null;
        }
    }

    public void StartReconnetCor() {
        Debug.Log("StartReconnetCor");
        isReconnecting = true;
        GLuaSharedHelper.CallLua("OnWaitLockCount", 1);
        
        reconnetCor = StartCoroutine(NetController.Instance.TryReconnet());
    }

    public void StopReconnetCor() {
        Debug.Log("StopReconnetCor");
        if (reconnetCor != null) {
            StopCoroutine(reconnetCor);
            reconnetCor = null;
        }
        if (isReconnecting) {
            isReconnecting = false;
            GLuaSharedHelper.CallLua("OnWaitLockCount", -1);
        }
    }

}