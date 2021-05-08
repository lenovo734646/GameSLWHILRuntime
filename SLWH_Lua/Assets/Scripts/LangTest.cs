using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LangTest : MonoBehaviour
{
    public string TestLang = "EN";
    // Start is called before the first frame update
    void Start()
    {
        SysDefines.curLanguage = TestLang;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
