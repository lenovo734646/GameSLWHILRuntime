using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using System.Linq;
using XLua;

namespace ForReBuild.UIHelper
{
    [Serializable]
    public class AnimatorStateInfoEvent
    {
        public AnimatorStateInfoEvent()
        {
            AnimatorStateInfoName = "";
            startAction = new UnityEvent();
            completeAction = new UnityEvent();
        }
        public AnimatorStateInfoEvent(string name, Action startAct, Action completeAct)
        {
            AnimatorStateInfoName = name;
            startAction = new UnityEvent();
            if (startAct != null)
                startAction.AddListener(() => { startAct.Invoke(); });
            
            completeAction = new UnityEvent();
            if (completeAct != null)
                completeAction.AddListener(()=> { completeAct.Invoke(); });
        }

        [Label("动画名字")]
        public string AnimatorStateInfoName;
        public UnityEvent startAction;
        public UnityEvent completeAction;
    }

    [LuaCallCSharp]
    [RequireComponent(typeof(Animator))]
    public class AnimatorHelper : MonoBehaviour
    {
        [SerializeField]
        public bool AutoPlayOnAwake = false;
        [SerializeField]
        public string autoPlayAnimName = "";
        [SerializeField]
        public AnimatorStateInfoEvent[] animatorStateInfoEventList;


        Animator animator;
        AnimatorStateInfoEvent curAnimatorStateInfoEvent;
        AnimatorStateInfo curanimState;
        private void Awake()
        {
            animator = GetComponent<Animator>();
            curAnimatorStateInfoEvent = null;
        }

        private void OnEnable()
        {
            if (AutoPlayOnAwake && !string.IsNullOrEmpty(autoPlayAnimName))
            {
                Play(autoPlayAnimName);
            }
        }

        private void OnDisable()
        {
            Stop();
        }

        public float GetDuration(string animName)
        {
            AnimationClip[] clips = animator.runtimeAnimatorController.animationClips;
            foreach (AnimationClip clip in clips)
            {
                if (clip.name.Equals(animName))
                {
                    return clip.length;
                }
            }
            return 0;
        }

        public Animator GetAnimator()
        {
            return animator;
        }

        public void SetSpeed( float speed)
        {
            animator.speed = speed;
        }

        public void SetBool(string name, bool v)
        {
            animator.SetBool(name, v);
        }

        public void SetInteger(string name, int v)
        {
            animator.SetInteger(name, v);
        }

        public void SetFloat(string name, float v)
        {
            animator.SetFloat(name, v);
        }

        public void SetTrigger(string name)
        {
            animator.SetTrigger(name);
        }

        public void SetCurve(string name)
        {
            var clip = GetAnimationClip(name);
            //clip.SetCurve("11", typeof(DoTweenCompleteHelper), "11", );
        }

        public void Play(string animName)
        {
            if (gameObject.activeSelf == false)
                gameObject.SetActive(true);
            if (animator.enabled == false)
                animator.enabled = true;

            if (animatorStateInfoEventList.Length > 0)
                curAnimatorStateInfoEvent = GetAnimatorStateEvent(animName);
            animator.Play(animName, 0, 0);


            //curanimState = animator.GetCurrentAnimatorStateInfo(0); // 这里获取到的数据并不准确，因为AnimationClip并没有真正播放
        }

        public void Play(string animName, Action startAct, Action completeAct)
        {
            if (gameObject.activeSelf == false)
                gameObject.SetActive(true);
            if(animator.enabled == false)
                animator.enabled = true;

            curAnimatorStateInfoEvent = new AnimatorStateInfoEvent(animName, startAct, completeAct);

            animator.Play(animName, 0, 0);
        }

        public void Stop()
        {
            animator.enabled = false;
        }


        public void OnStart()
        {
            if(curAnimatorStateInfoEvent != null)
            {
                curanimState = animator.GetCurrentAnimatorStateInfo(0); // 这里获取到的才是正确的
                                                                        //print(curanimState.IsName("Base.PopupWindow_in") + "   speed =" + curanimState.speed);
                if (curanimState.speed > 0) // 正放
                {
                    curAnimatorStateInfoEvent.startAction.Invoke();
                }
                else //倒放 start 变 finish
                {
                    curAnimatorStateInfoEvent.completeAction.Invoke();
                }
            }
        }

        public void OnFinish()
        {
            if(curAnimatorStateInfoEvent != null)
            {
                curanimState = animator.GetCurrentAnimatorStateInfo(0);
                if (curanimState.speed > 0) // 正放
                {
                    curAnimatorStateInfoEvent.completeAction.Invoke();
                }
                else //倒放 start 变 finish
                {
                    curAnimatorStateInfoEvent.startAction.Invoke();
                }
            }
        }

        private AnimatorStateInfoEvent GetAnimatorStateEvent(string name)
        {
            foreach(var t in animatorStateInfoEventList)
            {
                if (t.AnimatorStateInfoName == name)
                    return t;
            }
            Debug.LogError($"没有找到名字为{name}的动画！");
            return null;
        }

        private AnimationClip GetAnimationClip(string animName)
        {
            AnimationClip[] clips = animator.runtimeAnimatorController.animationClips;
            foreach (AnimationClip clip in clips)
            {
                if (clip.name.Equals(animName))
                {
                    return clip;
                }
            }
            return null;
        }

        private void OnDestroy() {
            curAnimatorStateInfoEvent = null;
        }
    }
}