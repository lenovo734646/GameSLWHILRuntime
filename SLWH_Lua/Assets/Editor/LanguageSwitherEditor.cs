using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

[CustomEditor(typeof(LanguageSwither))]
public class LanguageSwitherEditor : Editor {


    [MenuItem("CONTEXT/Text/添加LanguageSwither")]
    public static void AutoTextAdd(MenuCommand command) {
        var com = command.context as Text;
        AddCom(com);
    }
    [MenuItem("CONTEXT/Image/添加LanguageSwither")]
    public static void AutoImageAdd(MenuCommand command) {
        var com = command.context as Image;
        AddCom(com);
    }
    [MenuItem("CONTEXT/Button/添加LanguageSwither")]
    public static void AutoButtonAdd(MenuCommand command) {
        var com = command.context as Button;
        AddCom(com);
    }
    [MenuItem("CONTEXT/Toggle/添加LanguageSwither")]
    public static void AutoToggleAdd(MenuCommand command) {
        var com = command.context as Toggle;
        AddCom(com);
    }
    [MenuItem("CONTEXT/SkeletonGraphic/添加LanguageSwither")]
    public static void AutoSkeletonGraphicAdd(MenuCommand command) {
        var com = command.context as SkeletonGraphic;
        AddCom(com);
    }
    [MenuItem("CONTEXT/TextMeshProUGUI/添加LanguageSwither")]
    public static void AutoTextMeshProUGUIAdd(MenuCommand command) {
        var com = command.context as TextMeshProUGUI;
        AddCom(com);
    }
    public static void AddCom(Component com) {
        var targetcom = com.gameObject.GetOrAddComponent<LanguageSwither>();
        InitCom(targetcom);
        AddNewLang(targetcom);
    }

    public override void OnInspectorGUI() {
        DrawDefaultInspector();
        var targetcom = (LanguageSwither)target;
        InitCom(targetcom);

        if (GUILayout.Button("添加新的语言")) {
            AddNewLang(targetcom);
        }
    }

    public static void AddNewLang(LanguageSwither targetcom) {
        var data = new LanguageSwither.LangData();
        if (targetcom.supportLanguageList.Count == 1) {
            data.name = "EN";
        }
        if (targetcom.skeletonGraphic && targetcom.supportLanguageList.Count > 0) {
            data.content = targetcom.supportLanguageList[0].content + "_" + data.name;
        }
        targetcom.supportLanguageList.Add(data);
        EditorUtility.SetDirty(targetcom);
    }

    

    public static void InitCom(LanguageSwither targetcom) {
        if (!targetcom.text) {
            targetcom.text = targetcom.GetComponent<Text>();
            if(targetcom.text)
                EditorUtility.SetDirty(targetcom);
        }
        if (!targetcom.textMeshPro) {
            targetcom.textMeshPro = targetcom.GetComponent<TextMeshPro>();
            if (targetcom.textMeshPro)
                EditorUtility.SetDirty(targetcom);
        }
        if (!targetcom.textMeshProUGUI) {
            targetcom.textMeshProUGUI = targetcom.GetComponent<TextMeshProUGUI>();
            if (targetcom.textMeshProUGUI)
                EditorUtility.SetDirty(targetcom);
        }
        if (!targetcom.skeletonGraphic) {
            targetcom.skeletonGraphic = targetcom.GetComponent<SkeletonGraphic>();
            if (targetcom.skeletonGraphic)
                EditorUtility.SetDirty(targetcom);
        }
        if (!targetcom.image) {
            targetcom.image = targetcom.GetComponent<Image>();
            if (targetcom.image)
                EditorUtility.SetDirty(targetcom);
        }
        if (!targetcom.toggle) {
            targetcom.toggle = targetcom.GetComponent<Toggle>();
            if (targetcom.toggle) {
                EditorUtility.SetDirty(targetcom);
            }
        }

        if (targetcom.supportLanguageList.Count == 0) {
            var data = new LanguageSwither.LangData() { name = "CN" };

            var button = targetcom.button = targetcom.GetComponent<Button>();
            if (button) {
                targetcom.image = button.image;
                targetcom.text = button.GetComponentInChildren<Text>();
                if (!targetcom.text) {
                    targetcom.textMeshProUGUI = button.GetComponentInChildren<TextMeshProUGUI>();
                    if (!targetcom.textMeshProUGUI) {
                        targetcom.textMeshPro = button.GetComponentInChildren<TextMeshPro>();
                    }
                }
                var spriteState = button.spriteState;
                data.buttonSwapSprites.highlightedSprite = spriteState.highlightedSprite;
                data.buttonSwapSprites.pressedSprite = spriteState.pressedSprite;
                data.buttonSwapSprites.selectedSprite = spriteState.selectedSprite;
                data.buttonSwapSprites.disabledSprite = spriteState.disabledSprite;
            }

            if (targetcom.toggle) {
                data.sprite2 = targetcom.toggle.image.sprite;
                targetcom.image = (Image)targetcom.toggle.graphic;
                targetcom.text = targetcom.toggle.GetComponentInChildren<Text>();
            }
            
            if (targetcom.text) {
                data.content = targetcom.text.text;
            }
            if (targetcom.textMeshPro) {
                data.content = targetcom.textMeshPro.text;
            }
            if (targetcom.skeletonGraphic) {
                var state = targetcom.skeletonGraphic.AnimationState;
                var anims = state.Data.SkeletonData.Animations;
                foreach (var anim in anims) {
                    data.content = anim.Name;
                    //data.spineLoop = targetcom.skeletonGraphic.startingLoop;
                    break;
                }
                //data.content = targetcom.skeletonGraphic.AnimationState.GetCurrent(0).Animation.Name;

            }
            if (targetcom.textMeshProUGUI) {
                data.content = targetcom.textMeshProUGUI.text;
            }
            
            if (targetcom.image) {
                data.sprite = targetcom.image.sprite;
            }

            targetcom.supportLanguageList.Add(data);
            EditorUtility.SetDirty(targetcom);
        }
    }
}
