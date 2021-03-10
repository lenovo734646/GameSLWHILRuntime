using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SP
{
    [RequireComponent(typeof(Button))]
    public class SwitchButton : MonoBehaviour
    {
        // Start is called before the first frame update
        [SerializeField]
        public Sprite onSprite;
        [SerializeField]
        public bool isOn;

        private Sprite offSprite;   // button上的原始图片
        private Button button;
        private void Start()
        {
            button = GetComponent<Button>();
            offSprite = button.image.sprite;

            //button.onClick.AddListener(OnClick); // 因为执行顺序的问题
            SwitchSprite(isOn);

        }
        public void OnClick()
        {
            isOn = !isOn;
            SwitchSprite(isOn);
        }

        private void SwitchSprite(bool isOn_)
        {
            if (isOn_)
            {
                button.image.sprite = onSprite;
            }
            else
            {
                button.image.sprite = offSprite;
            }
        }
    }
}