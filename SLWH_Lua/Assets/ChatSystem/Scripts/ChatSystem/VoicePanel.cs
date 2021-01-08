using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SP
{
    public class VoicePanel : MonoBehaviour
    {
        public GameObject panelBG;
        public UITouch btnPressRecording;

        public MicrophoneRecorder recorder;
        [SerializeField]
        public int recordMaxTime = 6;  // 音频最大录制时间（不循环）

        public Action<byte[]> onSendCallback;

        GraphicRaycaster gr;
        // Start is called before the first frame update
        void Start()
        {
            var canvas = GameObject.Find("Canvas");
            gr = canvas.GetComponent<GraphicRaycaster>();

            btnPressRecording.OnTouchDown.AddListener(OnTouchDown);
            btnPressRecording.OnTouchUp.AddListener(OnTouchUp);
            btnPressRecording.OnTouchExit.AddListener(OnTouchExit);
            btnPressRecording.OnBeginSlider.AddListener(OnBeginSlider);
            btnPressRecording.OnSlider.AddListener(OnSlider);
            btnPressRecording.OnEndSlider.AddListener(OnEndSlider);

            panelBG.SetActive(false);

        }

        public void OnShow(bool bshow)
        {
            gameObject.SetActive(bshow);
            panelBG.SetActive(!bshow);

        }



        public void OnTouchDown()
        {
            panelBG.SetActive(true);
            // 开始录音
            recorder.StartRecording(recordMaxTime);
            print("OnTouchDown....开始录音1");
        }
        public void OnTouchUp()
        {
            panelBG.SetActive(false);
            if (IsMouseCorveredTarget(btnPressRecording.gameObject))
            {
                // send msg
                var clipData = recorder.GetSendDataBuff();
                if (clipData != null)
                {
                    print("OnTouchUp....发送消息3");
                    onSendCallback?.Invoke(clipData);
                    //OnSendMsg(null, clipData);
                }
                // 不管发送成功与否，都重置
                recorder.CancelRecording();
                return;
            }
            else
            {   // 松手时不在录音按钮上就取消
                recorder.CancelRecording();
            }
            //if (MouseCorveredTarget(btnCancel.gameObject))
            //{
            //    recorder.CancelRecording();
            //    print("OnTouchUp....取消发送2");
            //}
        }

        public void OnTouchExit()
        {
            print("OnTouchExit....");
        }

        public void OnBeginSlider()
        {
            print("OnBeginSlide....");
        }

        public void OnSlider()
        {
            print("OnSlide....");
        }

        public void OnEndSlider()
        {
            print("OnEndSlide....");
        }


        // Update is called once per frame
        void Update()
        {

        }

        public AudioClip ByteToAudioClip(byte[] data)
        {
            if (data == null)
            {
                Debug.LogError("ByteToClip data is null");
                return null;
            }
            return recorder.ByteToAudioClip(data);
        }

        // 判断鼠标是否在target上
        public bool IsMouseCorveredTarget(GameObject target)
        {
            var corverList = GetOverGameObject(gr);
            if (corverList == null || corverList.Count <= 0)
                return false;
            foreach(var ret in corverList)
            {
                if(ret.gameObject.name == target.name)
                {
                    return true;
                }
            }
            return false;
        }

        // 获取鼠标悬停位置的GameObject返回go层级为由下到上
        public List<RaycastResult> GetOverGameObject(GraphicRaycaster raycaster)
        {
            PointerEventData pointerEventData = new PointerEventData(EventSystem.current);
            pointerEventData.position = Input.mousePosition;
            List<RaycastResult> results = new List<RaycastResult>();
            raycaster.Raycast(pointerEventData, results);
            return results;
        }
    }
}
