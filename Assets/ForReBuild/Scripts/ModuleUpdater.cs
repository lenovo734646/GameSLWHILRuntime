using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModuleUpdater : MonoBehaviour
{
    // Start is called before the first frame update


    List<BaseModule> moduleList = new List<BaseModule>();


    public void AddModuleToUpdate(BaseModule m) {
        if (m == null) {
            Debug.LogError("AddModuleToUpdate m==null");
            return;
        }
        moduleList.Add(m);
    }

    public void RemoveModuleByTypeName(string tname) {
        moduleList.RemoveAll(m=> {
            return m.GetType().ToString() == tname;
        });
    }

    // Update is called once per frame
    void Update()
    {
        for(int i=0;i<moduleList.Count;i++) {
            moduleList[i].Update();
        }
    }
}
