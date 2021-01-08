using OSAHelper;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Threading.Tasks;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace SP
{
    public class ChatPanel : MonoBehaviour
    {
        static readonly DateTime EPOCH_START_TIME = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
        // 
        public RectTransform layoutRoot;
        public ChatView chatView;   // 消息列表
        // 文字
        public TMP_InputField inputField;
        BadWordsReplace badwordsReplace;    // 敏感词替换.

        // 表情
        public Toggle btnEmoji;
        public Animator emojiPanelAnimator;
        private ScrollRect emojiPanelScrollRect;

        // 音频
        public Toggle btnVoiceInput;
        public VoicePanel voicePanel;

        public Button btnSend;

        //
        float keyboardHeight = 0f;
        Vector2 panelPos;
        RectTransform panelRectTrans;
        bool bOpen = false;

        //AssetLoader assetLoader;
        // Start is called before the first frame update
        void Start()
        {

            panelRectTrans = gameObject.GetComponent<RectTransform>();
            panelPos = panelRectTrans.anchoredPosition;
            var bundlePath = Application.dataPath + "/../StreamingAssets/"+ GetPlatformPath()+"/"; //win
            //var bundlePath = Application.streamingAssetsPath + "/Android/"; // android
            //assetLoader = new AssetLoader(bundlePath);

            //
            //var badwordTextAsset = assetLoader.LoadTextAsset("Assets/RareVoiceChat/BadWord.txt");
            //badwordsReplace = new BadWordsReplace(badwordTextAsset.text);
            //
            var objs = EditorAssetLoader.LoadEditorAssetAll(@"Assets/RareVoiceChat/Texture/Emoji/Emoji.png", true);
            //var bundle = assetLoader.GetAssetBundle("Assets/RareVoiceChat/Texture/Emoji/Emoji.png");
            //var objs = bundle.LoadAssetWithSubAssets<Sprite>("Assets/RareVoiceChat/Texture/Emoji/Emoji.png");
            var emojiPanel = emojiPanelAnimator.gameObject.GetComponent<EmojiPanel>();
            //emojiPanel.Init(inputField, objs);
            emojiPanelScrollRect = emojiPanelAnimator.gameObject.GetComponentInChildren<ScrollRect>();
            btnEmoji.onValueChanged.AddListener((isOn) => {
                if (isOn)
                {
                    if (emojiPanelAnimator.gameObject.activeSelf == false)
                        emojiPanelAnimator.gameObject.SetActive(true);
                    emojiPanelAnimator.Play("popup");

                    // 如果在语音消息界面，则返回到文本消息界面
                    if (btnVoiceInput.isOn) btnVoiceInput.isOn = false;
                }
                else
                {
                    emojiPanelAnimator.Play("popup reverse");
                    StartCoroutine(IWaitDisableEmojiPanel());
                }
                StartCoroutine(UpdateScrollBarVal());
            });

            //
            btnVoiceInput.onValueChanged.AddListener((isOn) => {
                if (btnEmoji.isOn)
                    btnEmoji.isOn = false;
                if (btnSend.gameObject.activeSelf)
                    btnSend.gameObject.SetActive(false);
                voicePanel.OnShow(isOn);
            });
            voicePanel.onSendCallback = OnSendVoice;

            //
            inputField.shouldHideMobileInput = true;    // 隐藏输入法的InputField，避免出现两个InputField，而且富文本会被输入法的InpuFiled直接显示出来
            inputField.onSubmit.AddListener((str)=> { 
                print("---------::敲回车 : " + str);
                if (!string.IsNullOrEmpty(inputField.text))
                    OnSendText(inputField);
                if (btnSend.gameObject.activeSelf)
                    btnSend.gameObject.SetActive(false);
            });
            inputField.onEndEdit.AddListener((str) => {
                print("---------::onEndEdit : " + str);
                if (!string.IsNullOrEmpty(str))
                {
                    btnSend.gameObject.SetActive(true);
                }
            });

            inputField.onValueChanged.AddListener((str)=> { 
                if(!string.IsNullOrEmpty(str))
                {
                    btnSend.gameObject.SetActive(true);
                }
            });

            //inputField.onTouchScreenKeyboardStatusChanged.AddListener((s)=> {
            //    print("onTouchScreenKeyboardStatusChanged = "+s);
            //});

            btnSend.onClick.AddListener(()=> {
                if (!string.IsNullOrEmpty(inputField.text))
                    OnSendText(inputField);
                if (btnSend.gameObject.activeSelf)
                    btnSend.gameObject.SetActive(false);
            });

        }

        IEnumerator IWaitDisableEmojiPanel()
        {
            while (true)
            {
                yield return new WaitForEndOfFrame();
                if (emojiPanelAnimator.transform.localScale.y <= 0)
                {
                    emojiPanelAnimator.gameObject.SetActive(false);
                    yield break;
                }
            }
        }

        private void KeyControl()
        {
            if (Input.GetKeyDown(KeyCode.KeypadEnter) || Input.GetKeyDown(KeyCode.Return))
            {
                //Debug.Log("press 回车");
                if(!string.IsNullOrEmpty(inputField.text))
                    OnSendText(inputField);
            }

        }


        // Update is called once per frame
        void Update()
        {
            KeyControl();
#if UNITY_ANDROID && !UNITY_EDITOR
            //if (TouchScreenKeyboard.visible)
            //{

            //}
            var h = GetKeyboardHeight();
            if (keyboardHeight != h)
            {
                keyboardHeight = h;
                panelRectTrans.anchoredPosition = new Vector2(panelPos.x, panelPos.y + keyboardHeight);
            }
#endif
        }

        //IEnumerator AjustSoftKeyboard()
        //{
        //    if (keyboardHeight > 0)
        //    {
        //        print("*******************keyboardHeight = " + keyboardHeight);
        //        bOpen = true;
        //        SetPanelPos(keyboardHeight, bOpen);
        //        yield break;
        //    }
        //    else
        //    {
        //        while (keyboardHeight <= 0) // 经测试大概要等3帧才能获取到值
        //        {
        //            keyboardHeight = GetKeyboardHeight();
        //            // keyboardHeight = TouchScreenKeyboard.area.height; // 永远为0
        //            yield return new WaitForEndOfFrame();
        //        }
        //        bOpen = true;
        //        print("==================keyboardHeight = "+ keyboardHeight);
        //        SetPanelPos(keyboardHeight, bOpen);
        //        yield break;
        //    }
        //}

        //private void SetPanelPos(float h, bool bKeyboardOpen)
        //{
        //    var panelPos = panelRectTrans.anchoredPosition;
        //    //print("panelPos = "+ panelPos+"  h = "+ panelPos+ "  bKeyboardOpen = "+ bKeyboardOpen);
        //    if (bKeyboardOpen)
        //    {
        //        panelRectTrans.anchoredPosition = new Vector2(panelPos.x, panelPos.y + h);
        //    }
        //    else
        //    {
        //        panelRectTrans.anchoredPosition = new Vector2(panelPos.x, panelPos.y - h);
        //    }
        //}

        #region 消息接收与发送

        public void OnSendVoice(byte[] clipData)
        {
            if (clipData == null)
            {
                Debug.LogError("OnSendVoice clipData is null");
                return;
            }

            if (btnEmoji.isOn)
                btnEmoji.isOn = false;

            OnSendMsg(null, clipData);
        }

        public void OnSendText(TMP_InputField input)
        {
            var text = input.text;
            if (!string.IsNullOrEmpty(text))
            {
                var str = badwordsReplace.Replace(text, "*");

                OnSendMsg(str, null);
                input.text = "";
                return;
            }
            // Debug.LogError("发送失败 text = "+inputText+ "  clipData = "+ clipData);
        }

        private void OnSendMsg(string text, byte[] data)
        {
            if (btnEmoji.isOn)
                btnEmoji.isOn = false;
            // 自己显示发送的信息
            OnReceiveMsg(0, text, data);

            // 模拟他人自动回复(测试)
            OnReceiveMsg(1, text, data);
        }

        public void OnReceiveMsg(int userID, string text, byte[] audioData)
        {
            var isMine = false;
            if(userID == 0)
            {
                isMine = true;
            }

            AudioClip clip = null;
            if(audioData != null)
            {
                clip = voicePanel.ByteToAudioClip(audioData);
            }
            
            var msgData = new ChatMsgData();
            msgData.isMine = isMine;
            msgData.text = text;
            msgData.timestampSec = (Int32)(DateTime.UtcNow.Subtract(EPOCH_START_TIME)).TotalSeconds;
            msgData.clip = clip;
            msgData.userID = userID;
            msgData.iconSpr = GetSprite(msgData.userID, msgData.isMine);
            chatView.Data.InsertOneAtEnd(msgData, false);
            chatView.ScrollToBottom();
        }
#endregion
        // 获取用户头像
        private Sprite GetSprite(int userID, bool isMine)
        {
            var path = string.Empty;
            if (isMine)
                path = "r0.png";
            else
            {
                // 根据userID读取头像
                path = "r1.png";
            }
            //return EditorAssetLoader.LoadEditorAsset(@"Assets\RareVoiceChat\Texture\"+path, typeof(Sprite), true) as Sprite;
            //return assetLoader.LoadAsset<Sprite>("Assets/RareVoiceChat/Texture/"+path);
            return null;
        }


        // 设置滚动区域显示在最开始
        IEnumerator UpdateScrollBarVal()
        {
            yield return new WaitForSeconds(0.1f);
            emojiPanelScrollRect.verticalScrollbar.value = 1;
        }

        // 测试
        void OnGUI()
        {
            if (GUI.Button(new Rect(10f, 10f, 100f, 50f), "Back"))
            {
                inputField.shouldHideSoftKeyboard = !inputField.shouldHideSoftKeyboard;
            }
        }

        static string GetPlatformPath()
        {
            RuntimePlatform targetPlatform = Application.platform;
            if (targetPlatform == RuntimePlatform.Android)
                return "Android";

            if (targetPlatform == RuntimePlatform.OSXPlayer || targetPlatform == RuntimePlatform.IPhonePlayer)
                return "iOS";
            
            return "Win";
        }


        // 获取手机键盘高度 (调用安卓原生代码)
        public int GetKeyboardHeight()
        {
            using (AndroidJavaClass UnityClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            {
                AndroidJavaObject View = UnityClass.GetStatic<AndroidJavaObject>("currentActivity").Get<AndroidJavaObject>("mUnityPlayer").Call<AndroidJavaObject>("getView");

                using (AndroidJavaObject Rct = new AndroidJavaObject("android.graphics.Rect"))
                {
                    View.Call("getWindowVisibleDisplayFrame", Rct);
                    return Screen.height - Rct.Call<int>("height");
                }
            }
        }

        // 获取手机键盘高度（IOS，不一定准确，未测试）
        public int GetKeyboardHeight_IOS()
        {
            return (int)TouchScreenKeyboard.area.height * Display.main.systemHeight / Screen.height;
        }
    }
}