using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[XLua.LuaCallCSharp]
public class AnimationHelper : MonoBehaviour
{
    public Animation animationTarget;

    public AnimationClip[] animationClips;

    public float GetTimeByIndex(int index) {
        index -= 1;//映射到Lua index
        if (index >= 0 && index < animationClips.Length) {
            return animationClips[index].length;
        } else {
            Debug.LogWarning("index error index:" + index);
        }
        return 0;
    }

    public float PlayByIndex(int index, PlayMode mode) {
        index -= 1;//映射到Lua index
        if (index >= 0 && index < animationClips.Length) {
            animationTarget.Play(animationClips[index].name, mode);
            return animationClips[index].length;
        } else {
            Debug.LogWarning("index error index:" + index);
        }
        return 0;
    }

    public float PlayByIndex(int index)
    {
        return PlayByIndex(index, PlayMode.StopSameLayer);
    }

    public void StopByIndex(int index) {
        index -= 1;//映射到Lua index
        if (index >= 0 && index < animationClips.Length) {
            animationTarget.Stop(animationClips[index].name);
        } else {
            Debug.LogWarning("index error index:" + index);
        }
    }

    public void Stop() {
        animationTarget.Stop();
    }
    //这里的WaitForSeconds和Lua配合会有问题，不推荐使用
    public IEnumerator WaitPlayByIndex(int index, PlayMode mode = PlayMode.StopSameLayer)
    {
        index -= 1;//映射到Lua index
        if (index >= 0 && index < animationClips.Length)
        {
            if (animationTarget.Play(animationClips[index].name, mode))
            {
                yield return new WaitForSeconds(animationClips[index].length);
            }
            else
            {
                Debug.LogWarning("play failed. index:" + index);
            }
        }
        else
        {
            Debug.LogWarning("index error index:" + index);
        }
    }
}
