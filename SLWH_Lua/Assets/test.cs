using DG.Tweening;
using ForReBuild.UIHelper;
using OSAHelper;
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
        public float rotate;
        public float duration;
        public ParticleSystem par;
        public Button button;
        public Text btnText;

        public List<AudioClip> audioClips;
        public AudioSource audioSource;
        public AudioClip clip;

        public Toggle toggle;

        public ScrollRect scrollRect;

        public UGUISpineHelper spineHelper;

        public DOTweenAnimation tweenAnimation;

        public Sprite spr;
        public Image img;

        public EventBroadcaster eventBroadcaster;

        public int padCount = 2;
        public int aa = 01;

        public GameObject baoshi;
        public Material[] materials;

        public Animator animator;

        int [,]array = new int[3, 5];

        public AnimatorHelper animatorHelper;
        public OSAScrollView oSAScrollView;

        public enum ColorType
        {
            Zero = 0,
            Yellow,
            Green,
            Red,
            Max,    // Invalid
        }
        public struct ColorCount
        {
            public ColorType colorType; // 颜色
            public int count;           // 数量
            public ColorCount(ColorType colorType_, int count_) { colorType = colorType_; count = count_; }
        }


        public enum ExWinType
        {
            Zero = 0, // Invalid
            CaiJin,
            SongDeng,
            LiangBei,
            SanBei,
            Max, //Invalid
        }
        // 额外中奖概率
        public readonly static Dictionary<ExWinType, double> ExWinRateMap = new Dictionary<ExWinType, double>() {
            { ExWinType.CaiJin, 0.001},
            { ExWinType.SongDeng, 0.002},
            { ExWinType.LiangBei, 0.001},
            { ExWinType.SanBei, 0.0005},
            { ExWinType.Zero, 0.9955},
        };

        public void LogOut(string s)
        {
            print("LogOut: "+s);
        }

        private void Awake()
        {
            print("Test Awake....");
        }

        private void OnEnable()
        {
            print("Test OnEnable....");
        }

        private void OnDisable()
        {
            print("Test OnDisable....");
        }

        // Start is called before the first frame update
        void Start()
        {
            print("Test Start....");
            //var exWinTyp = default(ColorType);
            //print("default exWinTyp = " + exWinTyp);
            //var rate = ExWinRateMap[ExWinType.CaiJin];
            //print(rate);


            //for (int i = 0; i < 10; i++)
            //{
            //    print(UnityEngine.Random.Range(1, 2+1));
            //}
            //var r = UnityEngine.Random.Range(1, 2);
            //string[] strArray = { "而送灯","sdf", "123" };
            //print($"strArray = {strArray}");
            //scrollRect.content.DetachChildren();
            // 二维数组
            //for (int i = 0; i < array.GetLength(0); i++)
            //{
            //    for (int j = 0; j < array.GetLength(1); j++)
            //    {
            //        array[i, j] = (i * 5) + j;
            //    }
            //}

            //foreach(var val in array)
            //{
            //    print("Array = " + val);

            //}



            transform.eulerAngles = new Vector3(1, 1, 1);
            transform.DORotate(new Vector3(0, 720, 0), 1).SetEase(Ease.InBounce);

            //// 二进制
            //print(Convert.ToString(1, 2));
            //print(Convert.ToString(2, 2));
            //print(Convert.ToString(4, 2));
            //print(Convert.ToString(8, 2));
            //print(Convert.ToString(16, 2));
            //print(Convert.ToString(32, 2));

            //print(Convert.ToString(0x1, 2));
            //print(Convert.ToString(0x2, 2));
            //print(Convert.ToString(0x4, 2));
            //print(Convert.ToString(0x8, 2));
            //print(Convert.ToString(0x10, 2));
            //print(Convert.ToString(0x20, 2));

            //print(Convert.ToString(0x20|0x2, 2));
            //transform.DOPlayBackwards();

            //gameObject.transform.localScale.x




            //audioSource.PlayOneShot
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

            //var colorCountGroup = new ColorCount[] { new ColorCount(ColorType.Red, 12), new ColorCount(ColorType.Green, 7), new ColorCount(ColorType.Yellow, 11) };
            //Array.Sort(colorCountGroup, (a, b) => a.count.CompareTo(b.count));
            //Array.Reverse(colorCountGroup);
            //for (var i = 0; i < colorCountGroup.Length; i++)
            //{
            //    print($"color = {colorCountGroup[i].colorType}, count = {colorCountGroup[i].count}");
            //}
            
            //gameObject.AddComponent<AudioListener>();
        }

        // Update is called once per frame
        void Update()
        {
            //if (Input.GetMouseButtonDown(0))
            //{
            //    bleft = true;
            //    Debug.Log("你按下了鼠标左键");
            //}
            //if (Input.GetMouseButtonUp(0))
            //{
            //    bleft = false;
            //    Debug.Log("你抬起了鼠标左键");
            //}
            ////
            //if (Input.GetMouseButtonDown(1))
            //{
            //    bright = true;
            //    Debug.Log("你按下了鼠标右键");
            //}
            //if (Input.GetMouseButtonUp(1))
            //{
            //    bright = false;
            //    Debug.Log("你抬起了鼠标左键");
            //}
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

        int materialIndex = 0;
        private void OnGUI()
        {
            if (GUI.Button(new Rect(10, 300, 100, 50), "AnXIa"))
            {
                // 替换图片精灵并设置原尺寸
                //img.sprite = spr;
                //img.SetNativeSize();
                // animator 播放动画
                //animatorHelper.Play("Anxia");

                //spineHelper.Play("dengdai");
                //spineHelper.Play("kaishixiazhu");

                //eventBroadcaster.Broadcast("showState");

                //baoshi.GetComponent<MeshRenderer>().material = materials[materialIndex];
                //materialIndex++;
                //if (materialIndex >= materials.Length)
                //    materialIndex = 0;
                //tweenAnimation.DOPlayForward();

                // DOTween.DORotate 顺时针旋转
                //var rot = rotate + Root.transform.localEulerAngles.y;
                var rot = rotate;
                print("rotate = " + rotate + "  y = " + Root.transform.localEulerAngles.y);
                Root.transform.DORotate(new Vector3(0, rot, 0), duration, RotateMode.LocalAxisAdd);
                print("DORotate = " + rot + "  dur = " + duration);

                
                //// DOTween.DORotate 逆时针旋转
                //var rot2 = rotate - Root.transform.localEulerAngles.y;
                //print("rotate = " + rotate + "  y = " + Root.transform.localEulerAngles.y);
                //Root.transform.DORotate(new Vector3(0, -rot2, 0), duration, RotateMode.FastBeyond360);
                //print("DORotate = " + rot2 + "  dur = " + duration);

                // DOTween 重复播放一个DOTweenAnimation（每次都从头播放，不用reverse） 
                // OnStart回调只第一次播放调用一次 OnStart => OnPlay =》OnComplete
                // 之后再次播放会调用 OnRewind  => OnPlay =》OnComplete
                // tweenAnimation.DORestart();

                //AudioManager.Instance.PlaySoundEff2D("dasanyuan");
                //AudioManager.Instance.PlaySoundEff2D("dasixi");
            }


            if (GUI.Button(new Rect(10, 450, 100, 50), "Backwards"))
            {
                //tweenAnimation.hasOnComplete = true;
                //tweenAnimation.onComplete = new UnityEngine.Events.UnityEvent();
                //tweenAnimation.onComplete.AddListener(() => { tweenAnimation.gameObject.SetActive(false); print("播放结束！"); });
                //tweenAnimation.DOPlayBackwards();
                //if(bright)
                //    Debug.Log("右键点击按钮");
                //if(bleft)
                //    Debug.Log("左键点击按钮");

                //Debug.Log("1111111"+ CallLuaByGameObjectName);

                //AudioManager.Instance.StopSoundEff("dasanyuan");
                
                //AudioManager.Instance.StopAllSoudEff();
                //AudioManager.Instance.PlaySoundEff2D("dasixi");
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