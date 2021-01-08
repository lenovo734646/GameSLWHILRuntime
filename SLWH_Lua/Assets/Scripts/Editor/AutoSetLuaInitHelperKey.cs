using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using SLWH;

public class AutoSetLuaInitHelperKey : EditorWindow
{
    [MenuItem("Tools/自动根据carIndex设置WinArea")]
    public static void Set()
    {
        var betAreaWinFXInitHelper = GetCom<LuaInitHelper>("winStage");
        var dataList = betAreaWinFXInitHelper.initList;
        foreach (var data in dataList)  // 重置
            data.name = "";

        var chebiaoHelper = GetCom<CheBiaoHelper>("carIndexs");
        var indexList = chebiaoHelper.chebiaoList;

        for (var i = 0; i < indexList.Count; i ++)
        {
            var carID = indexList[i].carID;
            foreach(var data in dataList)
            {
                var target = data.anyType.name;
                if(target == carID.ToString())
                {
                    if(data.name.Length > 0)
                    {
                        data.name += ",";
                        data.name += indexList[i].gameObject.name;
                    }
                    else
                    {
                        data.name = indexList[i].gameObject.name;
                    }
                }
            }
        }
    }

    static T GetCom<T>(string goName)
    {
        var go = GameObject.Find(goName);
        if (go == null)
        {
            Debug.LogError("betAreaWinFX Not Found");
        }
        var com = go.GetComponent<T>();
        if (com == null)
        {
            Debug.LogError($"GetComponent Failed from :" + go.name);
        }
        return com;
    }

}
