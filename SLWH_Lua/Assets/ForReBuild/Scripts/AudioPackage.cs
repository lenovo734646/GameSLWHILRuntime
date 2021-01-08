using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace ForReBuild {
    public class AudioPackage : MonoBehaviour {
        [Serializable]
        public class AudioClipData {
            public string name;
            public AudioClip clip;
            public string pathOrName;
        }

        public AudioClipData[] audioClipDatas;

        public AudioClip[] audioClips;

        public string basePath = "";
        [CustomEditorName("实例化自动装载到AudioManager")]
        public bool autoAddToAudioManager = true;

        public Dictionary<string, AudioClip> AudioDic { get; private set; }
            = new Dictionary<string, AudioClip>(); //音效文件缓存 

        void Awake() {
            //print("AudioPackage Awake");
            foreach (var data in audioClipDatas) {
                AudioDic.Add(data.pathOrName, data.clip);
            }
            if (autoAddToAudioManager)
                AudioManager.Instance.AddAudioPackage(this);
        }

        public bool TryGetClip(string pathOrName, out AudioClip audioClip) {
            var path = basePath + pathOrName;
            if(AudioDic.TryGetValue(path,out audioClip)) {
                return true;
            }
            if (AudioDic.TryGetValue(pathOrName, out audioClip)) {
                return true;
            }
            Array.Find(audioClips, clip=> {
                return clip.name == pathOrName;
            });
            audioClip = null;
            return false;
        }

        void OnDestroy() {
            AudioManager.Instance.RemoveAudioPackage(this);
        }
    }
}
