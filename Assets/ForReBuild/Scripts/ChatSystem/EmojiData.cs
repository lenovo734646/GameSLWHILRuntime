using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace SP
{
    public class EmojiData : MonoBehaviour
    {
        public int index;   // TMP图集中的index
        public Image image;
        public Action onClick;

        private void OnDestroy() {
            onClick = null;
        }
    }
}