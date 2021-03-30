
/******************************************************************************
 * 
 *  Title:  捕鱼项目
 *
 *  Version:  1.0版
 *
 *  Description:
 *         1：管理UI界面的管理类
 *
 *  Author:  WangXingXing
 *       
 *  Date:  2018
 * 
 ******************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class UIManager : Singleton<UIManager>
{
    /// <summary>
    /// UI窗体信息
    /// </summary>
    struct UIInfoData
    {
        public EnumUIType UIType { get; private set; }
        public string Path { get; private set; }
        public Type ScriptType { get; private set; }
        public object[] UIparams { get; private set; }
        public UIInfoData GetUIInfoData(EnumUIType uiType, string componentType, params object[] uiParams)
        {
            UIType = uiType;
            Path = UIPathDefines.GetPrefabPathByType(uiType, componentType);
            UIparams = uiParams;
            ScriptType = UIPathDefines.GetUIScriptByType(uiType, componentType);
            return this;
        }
    }

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

    private Dictionary<EnumUIType, GameObject> dicOpenUIs = new Dictionary<EnumUIType, GameObject>();



    public T GetUI<T>(EnumUIType uiType) where T : BaseUI
    {
        GameObject retObj = GetUIObject(uiType);
        if (null != retObj)
            return retObj.GetComponent<T>();
        return null;
    }

    public GameObject GetUIObject(EnumUIType uiType) {
        GameObject retObj = null;
        if (dicOpenUIs.TryGetValue(uiType, out retObj)) {
            return retObj;
        }
        return null;
    }


    public void PreloadUI(EnumUIType[] uITypes)
    {
        var len = uITypes.Length;
        for (int i = 0; i < len; i++)
        {
            PreloadUI(uITypes[i]);
        }
    }


    /// <summary>
    /// 预加载
    /// </summary>
    /// <param name="uiType">UI类型</param>
    public void PreloadUI(EnumUIType uiType)
    {
        string path = UIPathDefines.GetPrefabPathByType(uiType, string.Empty);
        ResManager.Instance.LoadPrefab(path);
    }

    public void OpenMessageBoxUI(string content, int countTime = 10, EnumMessageBoxType type = EnumMessageBoxType.OK_CANCEL,
                                 MethodAction btnOK = null, object btnOKParam = null,
                                 MethodAction btnRelease = null, object btnReleaseParam = null,
                                 params object[] uiParams)
    {
        OpenMessageBoxUI(null, content, countTime, type, btnOK, btnOKParam, btnRelease, btnReleaseParam, uiParams);
    }

    //打开两个按钮的弹窗
    public void OpenMessageBoxUI(string title, string content, int countTime = 10, EnumMessageBoxType type = EnumMessageBoxType.OK_CANCEL,
                                 MethodAction btnOK = null, object btnOKParam = null,
                                 MethodAction btnRelease = null,object btnReleaseParam = null,
                                 params object[] uiParams)
    {
        var module = ModuleManager.Instance.Get<MessageBoxModule>();
        module.Title = string.IsNullOrEmpty(title) ? "温馨提示" : title;
        module.Content = content;
        module.CountTime = countTime;
        module.btnOK = btnOK;
        module.btnRelease = btnRelease;
        module.btnOKParam = btnOKParam;
        module.btnReleaseParam = btnReleaseParam;
        module.MessageType = type;
        OpenUI(EnumUIType.MessageBoxUI, uiParams);
    }


    /// <summary>
    /// 打开UI面板不关闭已打开的UI面板
    /// </summary>
    /// <param name="uiType">UI类型</param>
    /// <param name="uiParams">可变参数</param>
    public void OpenUI(EnumUIType uiType, params object[] uiParams)
    {
        OpenUI(false, uiType, string.Empty, uiParams);
    }

    /// <summary>
    /// 打开UI面板不关闭已打开的UI面板
    /// </summary>
    /// <param name="uiType">UI类型</param>
    /// <param name="componentType">组件类型</param>
    /// <param name="uiParams">可变参数</param>
    public void OpenUI(EnumUIType uiType, string componentType, params object[] uiParams)
    {
        OpenUI(false, uiType, componentType, uiParams);
    }


    /// <summary>
    /// 打开多个UI面板兵关闭其他面板
    /// </summary>
    /// <param name="uiType">UI类型</param>
    /// <param name="uiParams">可变参数</param>
    public void OpenUICloseOthers(EnumUIType uiType, params object[] uiParams)
    {
        OpenUI(true, uiType, string.Empty, uiParams);
    }

    /// <summary>
    /// 打开多个UI面板兵关闭其他面板
    /// </summary>
    /// <param name="uiType">UI类型</param>
    /// <param name="componentType">组件类型</param>
    /// <param name="uiParams">可变参数</param>
    public void OpenUICloseOthers(EnumUIType uiType, string componentType, params object[] uiParams)
    {
        OpenUI(true, uiType, componentType, uiParams);
    }

    /// <summary>
    /// 打开UI面板
    /// </summary>
    /// <param name="isCloseOthers">是否关闭已打开的UI的面板</param>
    /// <param name="uiTypes">UI类型数组</param>
    /// <param name="componentType">组件类型</param>
    /// <param name="uiParams">可变参数</param>
    public void OpenUI(bool isCloseOthers, EnumUIType uiType, string componentType, params object[] uiParams) {

        var uiname = uiType.ToString();
        if (redirectToLua.Contains(uiname)) {//让Lua可以做到事件拦截处理
            var objs = GLuaSharedHelper.CallLua("OpenUI", uiname, componentType, isCloseOthers, uiParams);
            if (objs == null) return;
            if (objs.Length < 0 || (bool)objs[0] == false) {
                return;
            }
        }

        if (isCloseOthers)
            CloseUIAll();

        var uiInfoData = new UIInfoData().GetUIInfoData(uiType, componentType, uiParams);
        var prefabObj = ResManager.Instance.LoadPrefab(uiInfoData.Path);
        if (prefabObj != null) {
            var uiObj = UnityEngine.Object.Instantiate(prefabObj) as GameObject;
            BaseUI baseUI = uiObj.GetComponent<BaseUI>();
            if (baseUI == null)
                baseUI = uiObj.AddComponent(uiInfoData.ScriptType) as BaseUI;
            baseUI.SetUIWhenOpening(uiInfoData.UIparams);
            dicOpenUIs.Add(uiInfoData.UIType, uiObj);
        }
    }

    public void CloseUIAll(EnumUIType exclude = EnumUIType.None)
    {
        List<EnumUIType> listKey = new List<EnumUIType>(dicOpenUIs.Keys);
        for (int i = 0; i < listKey.Count; i++)
        {
            if (listKey[i] == exclude) continue;
            CloseUI(listKey[i]);
        }
        GLuaSharedHelper.CallLua("CloseUIAll", "Lua" + exclude.ToString());
    }

    public void CloseUI(EnumUIType[] uiTypes, EnumUIType exclude = EnumUIType.None)
    {
        for (int i = 0; i < uiTypes.Length; i++)
        {
            if (uiTypes[i] == exclude) continue;
            CloseUI(uiTypes[i]);
        }
    }

    public void CloseUI(EnumUIType uiType)
    {
        GameObject uiObj = GetUIObject(uiType);
        if (null != uiObj)
        {
            string path = UIPathDefines.GetPrefabPathByType(uiType, string.Empty);
            ResManager.Instance.UnloadTrueAB(path);
            BaseUI baseUI = uiObj.GetComponent<BaseUI>();
            if (null == baseUI)
            {
                UnityEngine.Object.Destroy(uiObj);
                dicOpenUIs.Remove(uiType);
            }
            else
            {
                baseUI.StateChanged += CloseUIHandle;
                baseUI.Release();
            }
        } else {
            GLuaSharedHelper.CallLua("CloseUI", "Lua" + uiType.ToString());
        }
    }

    public void CloseUIHandle(object sender, EnumObjectState newState, EnumObjectState oldState)
    {
        if (newState == EnumObjectState.Closing)
        {
            BaseUI baseUI = sender as BaseUI;
            dicOpenUIs.Remove(baseUI.GetUIType());
            baseUI.StateChanged -= CloseUIHandle;
        }
    }

    //获得所有的打开的面板
    public Dictionary<EnumUIType, GameObject> GetDicOpenUIs()
    {
        return dicOpenUIs;
    }

    //获取最上层的UI面板
    public EnumUIType GetCurrentUI()
    {
        EnumUIType curUIType = EnumUIType.None;
        if (dicOpenUIs.Count >0 )
            curUIType = dicOpenUIs.Last().Key;
        return curUIType;
    }

    //打开的UI面板中可有此类型的UI
    public bool FindUIByUIType(EnumUIType uiType)
    {
        return dicOpenUIs.ContainsKey(uiType);
    }

    //#region HotUpdate
    private Dictionary<string, GameObject> dicOpenUIsLua = new Dictionary<string, GameObject>();
    public void BindLuaUIObject(GameObject uiObj, string name, RectTransform UIParent)
    {
        var script = uiObj.GetOrAddComponent<LuaBaseUI>();
        script.UIName = name;
        if (UIParent) {
            uiObj.transform.SetParent(UIParent, false);
        }
        dicOpenUIsLua.Add(name, uiObj);
    }

    public void CloseLuaUIObject(string name)
    {
        var script = dicOpenUIsLua[name].GetComponent<LuaBaseUI>();
        script.Release();
        dicOpenUIsLua.Remove(name);
    }

    public void ClearLuaUIObject()
    {
        foreach (var ui in dicOpenUIsLua.Values)
        {
            UnityEngine.Object.Destroy(ui);
        }
        dicOpenUIsLua.Clear();
    }
    //#endregion
}