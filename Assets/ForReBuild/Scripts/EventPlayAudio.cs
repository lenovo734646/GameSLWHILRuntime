using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

//0.83以后启用
public class EventPlayAudio : MonoBehaviour
{
    public void PlayMusic(string name)
    {
        if (AudioManager.Instance) {
            AudioManager.Instance.PlayMusic(name);
        }
    }
    public void PlayMusic(AudioClip audioClip) {
        if (AudioManager.Instance) {
            AudioManager.Instance.PlayMusic(audioClip);
        }
    }

    public void PlaySoundEff2D(string name) {
        if (AudioManager.Instance) {
            AudioManager.Instance.PlaySoundEff2D(name);
        }
    }

    public void PlaySoundEff2D(AudioClip audioClip) {
        if (AudioManager.Instance) {
            AudioManager.Instance.PlaySoundEff2D(audioClip);
        }
    }

    public void StopMusic() {
        if (AudioManager.Instance) {
            AudioManager.Instance.StopMusic();
        }
    }

    public void StopSoundEff(string name) {
        if (AudioManager.Instance) {
            AudioManager.Instance.StopSoundEff(name);
        }
    }

    public void StopEffect() {
        if (AudioManager.Instance) {
            AudioManager.Instance.StopEffect();
        }
    }

    public static void AddToAllChildButtonClick(GameObject gameObject,string name,bool isMusic=false) {
        var allbtn = gameObject.GetComponentsInChildren<Button>();
        foreach(var btn in allbtn) {
            var player = btn.gameObject.AddComponent<EventPlayAudio>();
            if (isMusic) {
                btn.onClick.AddListener(()=> {
                    player.PlayMusic(name);
                }); 
            } else {
                btn.onClick.AddListener(() => {
                    player.PlaySoundEff2D(name);
                });
            }
        }
    }
}
