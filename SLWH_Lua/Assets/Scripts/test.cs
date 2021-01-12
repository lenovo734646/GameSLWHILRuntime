using DG.Tweening;
using Spine.Unity;
using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using static Spine.AnimationState;
using Object = UnityEngine.Object;

namespace SLWH
{

    public class test : MonoBehaviour
    {
        public GameObject Root;
        public ParticleSystem par;
        public Button button;
        public Text btnText;

        public List<AudioClip> audioClips;
        public AudioSource audio11;
        public AudioClip clip;

        public Toggle toggle;

        public ScrollRect scrollRect;

        public UGUISpineHelper spineHelper;

        public DOTweenAnimation tweenAnimation;

        public Image img;

        public int padCount = 2;

        // Start is called before the first frame update
        void Start()
        {
            //print(par.main.startLifetime);
            //print(par.main.startLifetimeMultiplier);
            //print(par.main.duration);

            //button.onClick.AddListener(()=> { });
            //button.onClick.RemoveAllListeners
            //audio.Play(); // 背景音乐，循环

            //scrollRect.content.transform
            //img.sprite = null;
            //toggle.isOn = false;


            //int[] aa = new int[5];
            //print(aa.Length);
            //for(var i = 0; i < 5; i ++)
            //{
            //    aa[i] = i;
            //}

            //for (var i = 0; i < aa.Length; i++)
            //{
            //    print("aa = "+aa[i]);
            //}

            // 清空数组
            //aa.Initialize(); // 只用来初始化，如果已经有值了，那么不会改变值
            //Array.Clear(aa, 0, aa.Length); // 清空数组并设置系统默认值：默认值 bool->false; int or float -> 0; 引用类型 or string -> null
            //print(aa.Length);
            //for (var i = 0; i < aa.Length; i++)
            //{
            //    print(aa[i]);
            //}


            //int a = 1;
            //print(a.ToString().PadLeft(padCount));
        }

        // Update is called once per frame
        void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                bleft = true;
                Debug.Log("你按下了鼠标左键");
            }
            if (Input.GetMouseButtonUp(0))
            {
                bleft = false;
                Debug.Log("你抬起了鼠标左键");
            }
            //
            if (Input.GetMouseButtonDown(1))
            {
                bright = true;
                Debug.Log("你按下了鼠标右键");
            }
            if (Input.GetMouseButtonUp(1))
            {
                bright = false;
                Debug.Log("你抬起了鼠标左键");
            }
        }

        public void OnTest()
        {
            //var b = spineHelper.IsPlaying();
            //print("OnTest = "+b);
        }

        public void OnLongPress(string str)
        {
            Debug.Log("OnLongPress  "+ str);
            //btnText.text = "LongPress";
        }

        public void OnClick(string str)
        {
            Debug.Log("OnClick  " + str);
            //btnText.text = "Click";
        }

        public int AAint()
        {
            return 0;
        }

        bool bleft = false;
        bool bright = false;


        void CallLuaByGameObjectName(GameObject obj)
        {

        }

        private void OnGUI()
        {



            if (GUI.Button(new Rect(10, 500, 100, 50), "Test Delete AllChild"))
            {
                if(bright)
                    Debug.Log("右键点击按钮");
                if(bleft)
                    Debug.Log("左键点击按钮");

                //Debug.Log("1111111"+ CallLuaByGameObjectName);
            }
            //if (Input.GetMouseButtonDown(2))
            //{
            //    Debug.Log("你按下了鼠标中键");
            //}

            //if (GUI.Button(new Rect(10, 500, 100, 50), "Test Delete AllChild"))
            //{


            //    Invoke("OnLongPress", 1f);
            //    CancelInvoke();

            //    //if (par.gameObject.activeSelf == false)
            //    //    par.gameObject.SetActive(true);
            //    //par.Play();
            //    // 销毁所有子对象
            //    //Root.SetActive(false);
            //    //for (int i = 0; i < Root.transform.childCount; i++)
            //    //{
            //    //    Destroy(Root.transform.GetChild(i).gameObject);
            //    //}
            //    // 随机播放音效
            //    //AudioSource.PlayClipAtPoint();            
            //    //var random = Random.Range(0, audioClips.Count-1);
            //    //audio.PlayOneShot(audioClips[random]);
            //    //print("播放音效："+ audio.isPlaying);
            //    //AudioSource.PlayClipAtPoint(clip, Vector3.zero);

            //    // Spine动画
            //    spineHelper.Play(null, spineHelper.spine.startingLoop);

            //    toggle.isOn = true;

            //    tweenAnimation.DOPlayBackwards();
            //    tweenAnimation.DOPlayForward();
            //    //spineHelper.PlayByName("animation", () => { spineHelper.spine.gameObject.SetActive(false); }, false);
            //    //tr.End += (tr) => { skeletonGraphic.gameObject.SetActive(false); };
            //}
        }


    }
}