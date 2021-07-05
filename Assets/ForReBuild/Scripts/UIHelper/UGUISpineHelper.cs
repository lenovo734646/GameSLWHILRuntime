// update data : 2021.06.09
// 重新封装了UGUISpine的方法，方便XLua 脚本调用
//



using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine.Unity;
using static Spine.AnimationState;
using System;
using UnityEngine.Events;

namespace ForReBuild.UIHelper
{
    public class UGUISpineHelper : MonoBehaviour
    {
        public bool languageChange = false;
        [HideInInspector]
        public SkeletonGraphic spine;
        [HideInInspector]
        public Spine.TrackEntry trackEntry = null;
        // 播放完毕自动unactive
        [Tooltip("勾选此属性会覆盖PlayByName 中的 completeAct 参数, 循环播放时不生效")]
        [Label("播放完毕自动UnActive")]
        [SerializeField]
        public bool autoUnActive = false;

        [SerializeField]
        public bool playOnActive = true;
        [SerializeField]
        public bool StartingLoop
        {
            get { return spine.startingLoop; }
            set { spine.startingLoop = value; }
        }
        [SerializeField]
        public string StartingAnimation
        {
            get { return spine.startingAnimation; }
            set { spine.startingAnimation = value; spine.Initialize(true); }
        }

        public string defaultName = "animation";

        private TrackEntryDelegate startDelegate = null;
        private TrackEntryDelegate completeDelegate = null;
        [SerializeField]
        public UnityEvent startEvent;
        [SerializeField]
        public UnityEvent completeEvent;

        private void Awake()
        {
            spine = GetComponent<SkeletonGraphic>();
            trackEntry = null;
            completeDelegate = null;
        }

        public string LanguageSwitch(string name)
        {
            if (!languageChange) return name;
            //
            if (name.EndsWith(SysDefines.curLanguage)) return name;
            //
            if (SysDefines.curLanguage == "CN") return name;

            return name + "_" + SysDefines.curLanguage;
        }

        private void OnEnable()
        {
            if (spine == null)
            {
                spine = GetComponent<SkeletonGraphic>();
            }
            var fixName = LanguageSwitch(defaultName);
            spine.startingAnimation = fixName;
            spine.Initialize(true);
            if (playOnActive)
                PlayByName(fixName);
        }

        private void OnDisable()
        {
            Stop(autoUnActive);
        }

        public float GetTime()
        {
            return GetTimeByName(defaultName);
        }
        // 获取当前动画时长
        public float GetTimeByName(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                Debug.LogError($"animState name is null or empty on {gameObject.name}");
                return 0;
            }
            if (gameObject.activeSelf == false)
                gameObject.SetActive(true);
            var fixName = LanguageSwitch(name);
            var anim = spine.AnimationState.Data.SkeletonData.FindAnimation(fixName);
            if (anim != null)
                return anim.Duration;
            else
                Debug.LogError($"animation {fixName} not found on {gameObject.name}");
            return 0;
        }

        public bool IsPlaying()
        {
            return IsPlaying(defaultName);
        }

        public bool IsPlaying(string name)
        {
            if (trackEntry == null)
                return false;
            var fixName = LanguageSwitch(name);
            var playingAnimName = trackEntry.ToString();
            return playingAnimName == fixName;
        }


        public float GetPlayPercent()
        {
            return GetPlayPercentByName(defaultName);
        }
        // 获取当前播放动画的播放进度（0-1）
        public float GetPlayPercentByName(string name)
        {
            var duration = GetTimeByName(name);
            if (duration > 0)
            {
                return trackEntry.TrackTime / duration;
            }
            return 0;
        }

        public void Play(string name)
        {

            PlayByName(name);
        }

        // 播放默认动画并返回动画时间
        public float Play()
        {
            return PlayByName(defaultName);
        }

        // 播放默认动画无返回值（适合添加到编辑器）
        public void PlayVoidReturn()
        {
            PlayByName(defaultName);
        }

        public float Play(Action startAct = null, Action completeAct = null)
        {
            return PlayByName(defaultName, startAct, completeAct);
        }
        // 播放动画
        public float PlayByName(string name, Action startAct = null, Action completeAct = null)
        {
            var duration = GetTimeByName(name);
            if (duration > 0)
            {
                var fixName = LanguageSwitch(name);
                if (trackEntry != null)
                {
                    if (trackEntry.Animation.Name == fixName)
                    {
                        return duration;    // 同一个动画不允许重复播放
                    }
                    else
                    {
                        // 中途切换动画
                        spine.AnimationState.ClearTrack(0);
                        trackEntry = null;
                    }
                }
                //
                startDelegate = delegate {
                    startAct?.Invoke();
                    startEvent.Invoke();
                    spine.AnimationState.Start -= startDelegate;
                    startDelegate = null;
                };
                spine.AnimationState.Start += startDelegate;
                //
                if (!StartingLoop)
                {
                    completeDelegate = delegate {
                        completeAct?.Invoke();
                        completeEvent.Invoke();
                        spine.AnimationState.Complete -= completeDelegate;
                        completeDelegate = null;
                        Stop(autoUnActive);
                    };
                    spine.AnimationState.Complete += completeDelegate;
                }
                //

                spine.startingAnimation = fixName;
                trackEntry = spine.AnimationState.SetAnimation(0, fixName, StartingLoop);
            }
            return duration;
        }


        public void Stop(bool bUnActive = true)
        {
            StopByName(defaultName, bUnActive);
        }
        // 停止动画
        public void StopByName(string name, bool bUnActive = true)
        {
            if (string.IsNullOrEmpty(name))
            {
                return;
            }
            if (gameObject.activeSelf == false || trackEntry == null)
                return;
            var duration = GetTimeByName(name);
            if (duration > 0)
            {
                //spine.AnimationState.ClearTrack(0);
                trackEntry.Loop = StartingLoop;
                trackEntry.TrackTime = trackEntry.TrackEnd;// Loop 为 false 停在最后一帧，否则停留在当前帧
                trackEntry = null;
            }

            if (bUnActive)
                gameObject.SetActive(false);
        }


    }
}
