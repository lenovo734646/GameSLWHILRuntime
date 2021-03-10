using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;


namespace SP
{
    public class FixTMPInputFieldCaret : MonoBehaviour
    {
        TMP_InputField input;
        RectTransform caretRectTransform;
        // Start is called before the first frame update
        void Start()
        {
            input = GetComponent<TMP_InputField>();
            input.onValueChanged.AddListener(OnValueChanged);
            print("FixTMPInputFieldCaret Start...");
            var caret = GetComponentInChildren<TMP_SelectionCaret>();
            if (caret)
            {
                caretRectTransform = (RectTransform)caret.gameObject.transform;
            }
            else
            {
                Debug.LogError("caret is null...");
            }
            
        }

        public void OnValueChanged(string _)
        {
            caretRectTransform.anchorMin = caretRectTransform.anchorMax = Vector2.zero;

            caretRectTransform.sizeDelta = Vector2.zero;
            caretRectTransform.anchoredPosition = Vector2.zero;
        }
    }
}