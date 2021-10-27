using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class LanguageSwither : MonoBehaviour
{
    [System.Serializable]
    public struct LSpriteState {
        public Sprite highlightedSprite;
        public Sprite pressedSprite;
        public Sprite selectedSprite;
        public Sprite disabledSprite;
    }


    [System.Serializable]
    public class LangData {
        [CustomEditorName("语言")]
        public string name;//语言名称
        [CustomEditorName("文字(包含Toggle和button)/spine动画名")]
        public string content;
        [CustomEditorName("Image/Button/Toggle Checkmark 图片")]
        public Sprite sprite;
        [CustomEditorName("Toggle图片")]
        public Sprite sprite2;
        public GameObject gameObject;
        //[CustomEditorName("Button的Swap Sprite")]
        public LSpriteState buttonSwapSprites;
    }
    [CustomEditorName("自动应用")]
    public bool autoApply = true;
    public bool changeByEvent = false;
    public Text text;
    public TextMeshPro textMeshPro;
    public TextMeshProUGUI textMeshProUGUI;
    public SkeletonGraphic skeletonGraphic;
    public Image image;
    public Toggle toggle;
    public Button button;

    public List<LangData> supportLanguageList = new List<LangData>();

    private void Awake() {
        Apply(SysDefines.curLanguage); 
    }
    public void Apply(string langname) {
        if (supportLanguageList.Count == 0) return;
        var data = supportLanguageList.Find(a=> langname==a.name);
        Apply(data);
    }
    public void Apply(LangData langData) {
        if (changeByEvent)
        {
            if (MessageCenter.Instance)
            {
                //基本上就是交给Lua处理了，Lua里面监听此事件后进行处理
                MessageCenter.Instance.SendMessage("MSG_LanguageSwither", this, langData);
            }
            return;
        }
        if (text) {
            text.text = langData.content;
        }
        if (textMeshPro) {
            textMeshPro.text = langData.content;
        }
        if (toggle) {
            toggle.image.sprite = langData.sprite2;
        }
        if (image) {
            image.sprite = langData.sprite;
        }
        if (textMeshProUGUI) {
            textMeshProUGUI.text = langData.content;
        }
        if (skeletonGraphic) {
            skeletonGraphic.startingAnimation = langData.content;
            skeletonGraphic.Initialize(true);
        }
        if (button) {
            var spriteState = new SpriteState();
            spriteState.highlightedSprite = langData.buttonSwapSprites.highlightedSprite;
            spriteState.pressedSprite = langData.buttonSwapSprites.pressedSprite;
            spriteState.selectedSprite = langData.buttonSwapSprites.selectedSprite;
            spriteState.disabledSprite = langData.buttonSwapSprites.disabledSprite;
            button.spriteState = spriteState;
        }
        if (langData.gameObject) {
            langData.gameObject.SetActive(true);
            foreach (var data in supportLanguageList) {
                if (data != langData) {
                    data.gameObject.SetActive(false);
                }
            }
        }
    }
}
