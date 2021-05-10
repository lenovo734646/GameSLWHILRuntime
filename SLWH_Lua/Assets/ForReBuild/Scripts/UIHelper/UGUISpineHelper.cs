// update data : 2021.04.05
// 重新封装了UGUISpine的方法，方便XLua 脚本调用
//



using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine.Unity;
using static Spine.AnimationState;
using System;

namespace ForReBuild.UIHelper
{
    public class UGUISpineHelper : MonoBehaviour
    {
        public bool languageChange = false;
        [HideInInspector]
        public SkeletonGraphic spine;
        [HideInInspector]
        public Spine.AnimationState state;
        [HideInInspector]
        public Spine.TrackEntry entryAnim = null;
        //[HideInInspector]
        //public bool IsPlay { get { return state. } }

        private TrackEntryDelegate complete = null;

        // 播放完毕自动unactive
        [Tooltip("勾选此属性会覆盖PlayByName 中的 completeAct 参数, 循环播放时不生效")]
        [Label("播放完毕自动UnActive")]
        [SerializeField]
        public bool autoUnActive = false;

        [SerializeField]
        public bool playOnActive = true;

        public string defaultName = "animation";
        private string languageFix = ""; // 默认中文无后缀

        private void Awake()
        {
            spine = GetComponent<SkeletonGraphic>();
            state = spine.AnimationState;
            entryAnim = null;
            complete = null;
        }

        private string LanguageSwitch(string name)
        {
            if (!languageChange) return name;
            if (SysDefines.curLanguage != "CN")
            {
                languageFix = "_EN";
            }
            else
            {
                languageFix = "";
            }
            var fixName = name + languageFix;
            return fixName;
        }

        private void OnEnable()
        {
            if (spine == null)
            {
                spine = GetComponent<SkeletonGraphic>();
            }
            if (state == null)
            {
                spine.Initialize(false);
                state = spine.AnimationState;
            }
            if (playOnActive)
                PlayByName(defaultName);
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
            if (state == null)
            {
                return 0;
            }
            var fixName = LanguageSwitch(name);
            var anim = state.Data.SkeletonData.FindAnimation(fixName);
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
            if (entryAnim == null)
                return false;
            var fixName = LanguageSwitch(name);
            var playingAnimName = entryAnim.ToString();
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
            if(duration > 0)
            {
                return entryAnim.TrackTime/duration;
            }
            return 0;
        }

        public void Play(string name)
        {
            
            PlayByName(name, null);
        }

        // 播放默认动画并返回动画时间
        public float Play()
        {
            return PlayByName(defaultName, null);
        }

        // 播放默认动画无返回值（适合添加到编辑器）
        public void PlayVoidReturn()
        {
            PlayByName(defaultName,null);
        }

        public float Play(Action completeAct)
        {
            return PlayByName(defaultName, completeAct);
        }
        // 播放动画
        public float PlayByName(string name, Action completeAct = null)
        {
            var duration = GetTimeByName(name);
            if(duration > 0)
            {
                var bloop = spine.startingLoop;
                if(!bloop && autoUnActive)
                {
                    if(completeAct == null)
                        completeAct = () => { spine.gameObject.SetActive(false); };
                }

                //
                if(!bloop && completeAct != null)
                {
                    complete = delegate {
                        completeAct?.Invoke();
                        state.Complete -= complete;
                        complete = null;
                        Stop(autoUnActive);
                    };
                    state.Complete += complete;
                }
                //
                var fixName = LanguageSwitch(name);
                entryAnim = state.SetAnimation(0, fixName, bloop);
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
            if (gameObject.activeSelf == false || entryAnim == null)
                return;
            var duration = GetTimeByName(name);
            if (duration > 0)
            {
                state.SetEmptyAnimation(0, 0);
                entryAnim = null;
            }
            if (bUnActive)
                gameObject.SetActive(false);
        }


    }
}
