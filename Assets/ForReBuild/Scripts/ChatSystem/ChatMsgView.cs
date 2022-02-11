using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

namespace SP
{

    public class ChatMsgData
    {
        public int timestampSec;    // 时间戳（秒数）
        public int userID;          // 玩家ID(用来获取发送消息的用户信息)
        public string text;         // 消息文本
        public bool isMine;
        public AudioClip clip;      // 消息音频
        public Sprite iconSpr;         // 头像
    }

    public class ChatMsgView : MonoBehaviour
    {
        // 计时原点
        public readonly DateTime EPOCH_START_TIME = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
        //
        public Image leftIcon, rightIcon;   // 左右两边头像（可替换成按钮打开用户信息页）
        public TMP_Text timeText;       // 时间戳
        public TMP_Text text;           // 消息文本
        public AudioSource audioSource; // 消息音频
        public WaveFormDraw wfDraw;     // 音频波形绘制
        public Action onClick;          // 点击事件

        public ContentSizeFitter sizeFitter;
        public VerticalLayoutGroup rootLayoutGroup;
        public VerticalLayoutGroup msgContentLayoutGroup;
        public Image contentBackImage;

        int paddingAtIconSide, paddingAtOtherSide;
        Color colorAtInit;
        int userID;
        bool isMine;  // 是否为自己发的消息
        // 音频消息是否在播放
        bool isPlaying = false;

        private void Awake()
        {
            paddingAtIconSide = rootLayoutGroup.padding.right;
            paddingAtOtherSide = rootLayoutGroup.padding.left;
            //sizeFitter.enabled = false;
            colorAtInit = contentBackImage.color;
        }

        private void OnDestroy() {
            onClick = null;
        }

        public void UpdateFromData(ChatMsgData data)
        {
            if (data == null)
            {
                Debug.LogError("data is null ");
                return;
            }
            // 时间戳
            DateTime dtDataTime = EPOCH_START_TIME.AddSeconds(data.timestampSec).ToLocalTime();
            timeText.text = dtDataTime.ToString("HH:mm:ss");
            // 头像和布局 
            userID = data.userID;
            isMine = data.isMine;
            if(isMine)
            {
                rightIcon.gameObject.SetActive(true);
                rightIcon.sprite = data.iconSpr;
                leftIcon.gameObject.SetActive(false);
                //
                contentBackImage.color = new Color(0.75f, 1f, 1f, colorAtInit.a);
                rootLayoutGroup.childAlignment = msgContentLayoutGroup.childAlignment = TextAnchor.MiddleRight;
                rootLayoutGroup.padding.right = paddingAtIconSide;
                rootLayoutGroup.padding.left = paddingAtOtherSide;
            }
            else
            {
                leftIcon.gameObject.SetActive(true);
                leftIcon.sprite = data.iconSpr;
                rightIcon.gameObject.SetActive(false);
                //
                contentBackImage.color = colorAtInit;
                rootLayoutGroup.childAlignment = msgContentLayoutGroup.childAlignment = TextAnchor.MiddleLeft;
                rootLayoutGroup.padding.right = paddingAtOtherSide;
                rootLayoutGroup.padding.left = paddingAtIconSide;
            }

            // 消息内容
            if(data.clip != null)   // 音频消息
            {
                wfDraw.gameObject.SetActive(true);
                text.gameObject.SetActive(false);

                audioSource.clip = data.clip;
                wfDraw.StartWaveFormGeneration(data.clip);
                onClick = () => {
                    // play audioclip
                    if (isPlaying)
                        StopPlayback();
                    else
                        StartPlayback();

                };
                text.text = "";
            }
            else
            {   
                wfDraw.gameObject.SetActive(false);
                text.gameObject.SetActive(true);

                text.text = data.text;
                onClick = null;
                audioSource = null;
            }
        }


        private void Update()
        {
            if (isPlaying) // 回放
            {
                if (audioSource == null || audioSource.clip == null)
                    return;
                wfDraw.playbackSli.value = audioSource.timeSamples * audioSource.clip.channels;
                if (audioSource.isPlaying == false)
                {
                    StopPlayback();
                }
            }
        }

        public void StartPlayback()
        {
            if (isPlaying)
                return;

            isPlaying = true;
            audioSource.Play();
            print("回放开始....");
        }

        public void StopPlayback()
        {
            if (isPlaying == false)
                return;
            isPlaying = false;
            audioSource.Stop();
            wfDraw.playbackSli.value = 0;
            print("回放结束....");
        }

    }
}

