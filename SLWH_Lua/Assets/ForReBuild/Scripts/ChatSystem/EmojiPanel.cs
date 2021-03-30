using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace SP
{
    public class EmojiPanel : MonoBehaviour
    {
        // 文字
        private TMP_InputField input;
        // 表情
        public GameObject prefab;
        public Transform contentRoot;
        private int emojiCount = 0;
        private void Start()
        {

        }

        public void Init(TMP_InputField tmpInput, Sprite[] objs)
        {
            input = tmpInput;
            emojiCount = objs.Length - 1;
            if (objs != null && objs.Length > 0)
            {
                for (var i = 1; i < objs.Length; i++)   // 第0个为图集，后面的才是单个精灵
                {
                    var go = Instantiate(prefab, contentRoot);
                    var emoji = go.GetComponent<EmojiData>();
                    emoji.image.sprite = objs[i] as Sprite;
                    emoji.name = objs[i].name;
                    emoji.index = i - 1;

                    var btn = go.GetComponent<Button>();
                    btn.onClick.AddListener(() => { OnEmojiClick(emoji.index); });
                    //print($"emoji: index = {emoji.index}  name ={emoji.name}");
                }
            }
            else
            {
                Debug.LogError("Sprite Assets Emoji.png Load failed!");
            }
        }

        // 点击Emoji表情
        public void OnEmojiClick(int index)
        {
            print("OnEmojiClick index = "+index);
            var str = "";
            if (index < 0 || index > emojiCount)
                return;
            str = $"<sprite={index}>";
            input.text += str;
#if UNITY_STANDALONE_WIN
            input.ActivateInputField();
#endif
            input.MoveTextEnd(false);
        }
    }
}