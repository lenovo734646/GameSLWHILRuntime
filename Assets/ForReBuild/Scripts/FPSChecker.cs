using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class FPSChecker : MonoBehaviour
{
    // Start is called before the first frame update

    private float m_LastUpdateShowTime = 0f;  //上一次更新帧率的时间;  
    public float UpdateShowDeltaTime = 10.0f;//更新帧率的时间间隔;  
    private int m_FrameUpdate = 0;//帧数;

    public Rect rect = new Rect(Screen.width / 2, 30, 300, 30);

    public float FPS { get;private set; } = 0;
    public UnityEvent Event { get; } = new UnityEvent();

    public float delayCheck = 10.0f;

    public float minFps = 25;

    public bool autoDestroy = true;

    private void Start() {
        StartCoroutine(cCheck());
    }

    IEnumerator cCheck() {
        yield return new WaitForSeconds(delayCheck);
        m_LastUpdateShowTime = Time.realtimeSinceStartup;
        while (true) {
            yield return null;
            m_FrameUpdate++;
            if (Time.realtimeSinceStartup - m_LastUpdateShowTime >= UpdateShowDeltaTime) {
                FPS = m_FrameUpdate / (Time.realtimeSinceStartup - m_LastUpdateShowTime);
                m_FrameUpdate = 0;
                m_LastUpdateShowTime = Time.realtimeSinceStartup;
                if (FPS < minFps) {
                    Event?.Invoke();
                    if (autoDestroy)
                        Destroy(this);
                }
            }
        }
    }

    public void Pause(bool pause) {
        if (pause) {
            StopAllCoroutines();
        } else {
            StartCoroutine(cCheck());
        }
    }

    private void OnApplicationPause(bool pause) {
        Pause(pause);
    }

    private void OnDestroy() {
        Event.RemoveAllListeners();
    }

}
