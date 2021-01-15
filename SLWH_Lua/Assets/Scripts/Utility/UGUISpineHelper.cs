using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine.Unity;
using static Spine.AnimationState;
using System;

namespace SLWH
{
    [XLua.LuaCallCSharp]
    public class UGUISpineHelper : MonoBehaviour
    {
        [HideInInspector]
        public SkeletonGraphic spine;
        [HideInInspector]
        public Spine.AnimationState state;
        [HideInInspector]
        public Spine.TrackEntry entryAnim = null;
        [HideInInspector]
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
        private void Awake()
        {
            spine = GetComponent<SkeletonGraphic>();
            state = spine.AnimationState;
            entryAnim = null;
            complete = null;

        }

        private void OnEnable()
        {
            if(playOnActive)
                Play(null, spine.startingLoop);
        }

        private void OnDisable()
        {
            Stop();
        }

        public float GetTime()
        {
            return GetTimeByName(defaultName);
        }
        // 获取当前动画时长
        public float GetTimeByName(string name)
        {
            if (gameObject.activeSelf == false)
                gameObject.SetActive(true);
            if (string.IsNullOrEmpty(name))
            {
                Debug.LogError("name is null or empty");
                return 0;
            }
            var anim = state.Data.SkeletonData.FindAnimation(name);
            if (anim != null)
                return anim.Duration;
            else
                Debug.LogError("animation not found :"+name);
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
            var playingAnimName = entryAnim.ToString();
            return playingAnimName == name;
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
        public float Play(bool bLoop = false)
        {
            return Play(null, bLoop);
        }

        // 播放默认动画无返回值（适合添加到编辑器）
        public void PlayVoidReturn(bool bLoop = false)
        {
            Play(null, bLoop);
        }

        public float Play(Action completeAct, bool bloop = false)
        {
            return PlayByName(defaultName, completeAct, bloop);
        }
        // 播放动画
        public float PlayByName(string name, Action completeAct, bool bloop = false)
        {
            var duration = GetTimeByName(name);
            if(duration > 0)
            {
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
                        Stop();
                    };
                    state.Complete += complete;
                }
                //
                entryAnim = state.SetAnimation(0, name, bloop);
            }
            return duration;
        }


        public void Stop()
        {
            StopByName(defaultName);
        }
        // 停止动画
        public void StopByName(string name, bool bUnActive = true)
        {
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
