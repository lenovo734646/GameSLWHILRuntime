using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSShower : MonoBehaviour
{
    // Start is called before the first frame update

    private float m_LastUpdateShowTime = 0f;  //上一次更新帧率的时间;  
    private float m_UpdateShowDeltaTime = 0.1f;//更新帧率的时间间隔;  
    private int m_FrameUpdate = 0;//帧数;
    private float m_FPS = 0;

    public Rect rect = new Rect(Screen.width / 2, 30, 300, 60);

    private void Update()
    {
        m_FrameUpdate++;
        if (Time.realtimeSinceStartup - m_LastUpdateShowTime >= m_UpdateShowDeltaTime)
        {
            m_FPS = m_FrameUpdate / (Time.realtimeSinceStartup - m_LastUpdateShowTime);
            m_FrameUpdate = 0;
            m_LastUpdateShowTime = Time.realtimeSinceStartup;
        }
    }

    private void OnGUI()
    {
        GUI.Label(rect, $"<color=red><size=30>FPS:  {m_FPS.ToString("f2")}</size></color>");
    }
}
