using System.Collections;
using System.Collections.Generic;
using UnityEditor;
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
#if UNITY_EDITOR
    public void OnPauseClick()
    {
        EditorApplication.isPaused = !EditorApplication.isPaused;
    }
#endif
}
