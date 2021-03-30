
using ForReBuild;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : DDOLSingleton<AudioManager> {

    public bool showLog = true;

    public Func<object, object> LuaSoundHandler = null;//为以后出bug考虑可以在Lua里面执行

    public int audioSourceResetNum = 20;

    public float MusicVolum {
        get {
            return MusicAudio.volume;
        }
        set {
            MusicAudio.volume = value;
            PlayerPrefs.SetFloat("MusicVolum", value);
        }
    }
    float effectVolm = 1;
    public float EffectVolm {
        get {
            return effectVolm;
        }
        set {
            effectVolm = value;
            PlayerPrefs.SetFloat("EffectVolm", value);
        }
    }
    //兼容就方法
    public float GetBGMVolumScale() {
        return MusicVolum;
    }
    //兼容就方法
    public float GetEFFVolumScale() {
        return EffectVolm;
    }
    //兼容就方法
    public void SetBGMVolumScale(float v) {
        MusicVolum = v;
    }
    public void SetEFFVolumScale(float v) {
        EffectVolm = v;
    }


    public bool autoAddAudioSource = true;

    public Dictionary<string, AudioClip> AudioDic { get; private set; }
            = new Dictionary<string, AudioClip>(); //音效文件缓存 
    public AudioSource MusicAudio { get; private set; }
    public AudioSource EffectAudio { get; private set; }

    List<AudioPackage> audioPackages = new List<AudioPackage>();

    public void AddAudioPackage(AudioPackage audioPackage) {
        audioPackages.Add(audioPackage);
        Debug.Log("AddAudioPackage " + audioPackage);
    }

    public AudioPackage GetAudioPackage(string name) {
        return audioPackages.Find(pkg => {
            return pkg.name.Contains(name);
        });
    }

    public void RemoveAudioPackage(AudioPackage audioPackage) {
        audioPackages.Remove(audioPackage);
        Debug.Log("RemoveAudioPackage " + audioPackage);
    }

    public override void Init() {

    }

    private void Awake() {
        gameObject.AddComponent<AudioListener>();

        MusicAudio = gameObject.AddComponent<AudioSource>();
        MusicAudio.playOnAwake = false;
        MusicAudio.loop = true;
        if (PlayerPrefs.HasKey("MusicVolum"))
            MusicVolum = PlayerPrefs.GetFloat("MusicVolum");
        effectVolm = PlayerPrefs.GetFloat("EffectVolm", 1);
        initAudioSources();
    }

    private void initAudioSources() {
        EffectAudio = createAudioSource("EffectAudioSource");
    }

    AudioSource createAudioSource(string name) {
        var obj = new GameObject(name);
        obj.transform.SetParent(transform);
        var audio = obj.AddComponent<AudioSource>();
        audio.playOnAwake = false;
        audio.loop = false;
        return audio;
    }

    //解暂停
    public void UnPause() {
        MusicAudio.UnPause();
    }

    //暂停所有声音
    public void Pause() {
        MusicAudio.Pause();
    }

    //停止所有声音
    public void StopMusic() {
        MusicAudio.Stop();
    }
    public void StopEffect() {
        EffectAudio.Stop();
    }

    //设置静音
    public void SetMusicMute(bool isMute) {
        MusicAudio.mute = isMute;
    }
    //设置音效静音
    public void SetEffectMute(bool isMute) {
        EffectAudio.mute = isMute;
    }

    //播放背景音乐
    public void PlayMusic(string music) {
        StopPlayList();
        if (LuaSoundHandler != null) {
            LuaSoundHandler(new object[] { "PlayMusic", music });
            return;
        }
        if (IsPlayingMusic(music))
            return;
        var clip = GetClipByName(music);
        if (!clip) return;
        PlayMusic(clip);
    }
    Coroutine PlayMusicListCo = null;
    public void PlayMusicListByPackName(string packName, string loopMode = "randomloop") {
        if (LuaSoundHandler != null) {
            LuaSoundHandler(new object[] { "PlayMusicListByPackName", packName, loopMode });
            return;
        }
        var pkg = GetAudioPackage(packName);
        if (!pkg) {
            Debug.LogWarning("packName:" + packName + " not found!");
            return;
        }
        PlayMusicListCo = StartCoroutine(cPlayMusicList(pkg, loopMode));
    }

    public void StopPlayList() {
        if (PlayMusicListCo != null) {
            StopMusic();
            StopCoroutine(PlayMusicListCo);
            PlayMusicListCo = null;
        }
    }

    IEnumerator cPlayMusicList(AudioPackage audioPackage, string loopMode) {
        if (audioPackage.audioClips == null || audioPackage.audioClips.Length == 0) {
            Debug.LogWarning($"{audioPackage.name} audioClips is empty!");
            yield break;
        }
        switch (loopMode) {
            case "randomloop":
                while (true) {
                    if (!audioPackage) break;
                    AudioClip audioClip = audioPackage.audioClips[UnityEngine.Random.Range(0, audioPackage.audioClips.Length)];
                    PlayMusic(audioClip);
                    yield return new WaitForSeconds(audioClip.length);
                }
                break;
            case "loop":
                while (true) {
                    if (!audioPackage) break;
                    foreach (var audioClip in audioPackage.audioClips) {
                        PlayMusic(audioClip);
                        yield return new WaitForSeconds(audioClip.length);
                    }
                }
                break;
            case "looponce":
                foreach (var audioClip in audioPackage.audioClips) {
                    PlayMusic(audioClip);
                    yield return new WaitForSeconds(audioClip.length);
                }
                break;
            case "randomlooponce":
                List<AudioClip> list = new List<AudioClip>(audioPackage.audioClips);
                Shuffle(list);
                foreach (var audioClip in list) {
                    PlayMusic(audioClip);
                    yield return new WaitForSeconds(audioClip.length);
                }
                break;
        }
    }

    public void Shuffle<T>(IList<T> list) {
        int n = list.Count;
        while (n > 1) {
            n--;
            int k = UnityEngine.Random.Range(0, list.Count);
            T value = list[k];
            list[k] = list[n];
            list[n] = value;
        }
    }

    //是否正在播放music
    public bool IsPlayingMusic(string music) {
        if (LuaSoundHandler != null) {
            return (bool)LuaSoundHandler(new object[] { "IsPlayingMusic", music });
        }
        if (MusicAudio.isPlaying)
            return MusicAudio.clip.name == music;
        return false;
    }

    //兼容旧版本
    public bool IsPlaySoundEff(string _) {
        return false;
    }

    //是否正在播放背景音乐
    public bool IsPlayMusic() {
        return MusicAudio.isPlaying;
    }

    //停止所有音效
    public void StopAllSoudEff() {
        if (LuaSoundHandler != null) {
            LuaSoundHandler(new object[] { "StopAllSoudEff" });
            return;
        }
        EffectAudio.Stop();
    }

    /// <summary>
    /// 停止某音效
    /// </summary>
    /// <param name="eff">音效名称</param>
    public void StopSoundEff(string eff) {
        if (LuaSoundHandler != null) {
            LuaSoundHandler(new object[] { "StopSoundEff", eff });
            return;
        }
        var r = audioSources.Find(aud => {
            return aud.clip.name == eff;
        });
        if (r) {
            audioSources.Remove(r);
            Destroy(r.gameObject);
        }
    }

    /// <summary>
    /// 停止某音效
    /// </summary>
    /// <param name="clip">音效</param>
    public void StopSoundEff(AudioClip clip) {
        var r = audioSources.Find(aud => {
            return aud.clip == clip;
        });
        if (r) {
            audioSources.Remove(r);
            Destroy(r.gameObject);
        } else
            StopSoundEff(clip.name);
    }

    /// <summary>
    /// 播放背景音乐
    /// </summary>
    /// <param name="clip">音频</param>
    public void PlayMusic(AudioClip clip) {
        MusicAudio.clip = clip;
        MusicAudio.Play();
    }

    /// <summary>
    /// 播放2d音效
    /// </summary>
    /// <param name="eff">音效名称</param>
    /// <param name="loop">是否循环</param>
    public void PlaySoundEff2D(string eff, float volume = 1) {
        if (LuaSoundHandler != null) {
            LuaSoundHandler(new object[] { "PlaySoundEff2D", eff, volume });
            return;
        }
        var clip = GetClipByName(eff);
        if (!clip) return;
        PlaySoundEff2D(clip);
    }

    /// <summary>
    /// 播放2d音效
    /// </summary>
    /// <param name="clip">音频</param>
    public void PlaySoundEff2D(AudioClip clip) {
        if (clip == null)
            return;
        EffectAudio.PlayOneShot(clip);
    }

    List<AudioSource> audioSources = new List<AudioSource>();

    //用于兼容旧游戏的方法
    public void PlaySoundEff2D(AudioClip clip, bool loop) {
        playSoundEff2D(clip, loop);
    }
    //用于兼容旧游戏的方法
    public void PlaySoundEff2D(AudioClip clip, bool loop, float vol) {
        playSoundEff2D(clip, loop, vol);
    }

    void playSoundEff2D(AudioClip clip, bool loop, float? vol = null) {
        if (clip == null)
            return;
        EffectAudio.PlayOneShot(clip);
        if (loop) {
            //Debug.LogWarning("目前音效不支持循环，考虑自己做循环控制");
            var audioSource = createAudioSource("LoopingAudioSource");
            audioSources.Add(audioSource);//
            audioSource.clip = clip;
            audioSource.loop = true;
            if (vol != null) { 
                //audioSource.volume = vol.Value;//暂时不允许小游戏自定义音量
            } else {
                audioSource.volume = EffectVolm;
            }
            audioSource.Play();
        }
    }

    /// <summary>
    /// 根据字符串找到clip
    /// </summary>
    /// <param name="path">音效地址</param>
    /// <param name="cache">是否缓存</param>
    /// <returns></returns>
    public AudioClip GetClipByName(string path) {

        AudioClip audioClip;
        for (int i = audioPackages.Count - 1; i >= 0; i--) {
            var audioPackage = audioPackages[i];
            if (audioPackage.TryGetClip(path, out audioClip)) {
                return audioClip;
            }
        }

        if (AudioDic.TryGetValue(path, out audioClip))
            return audioClip;
        if (showLog)
            Debug.LogWarning($"未设置音频资源{path}\n使用旧的加载方式");
        var obj = ResManager.Instance.LoadPrefab(path);
        if (obj) {
            var data = ResManager.Instance.LoadPrefab(path).GetComponent<AudioData>();
            var clip = data.Clip;
            AudioDic.Add(path, clip);
            return clip;
        }
        return null;
    }

    public void AddClip(string name, AudioClip audioClip) {
        AudioDic.Add(name, audioClip);
    }

    public void Clear() {
        AudioDic.Clear();
    }
}
