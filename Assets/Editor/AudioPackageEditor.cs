/*
 * 自动化处理音频资源更新问题
 *  
 *  - 更新：
 *    - 1.更新对应路径下的音频文件
 *    - 2.点击菜单栏 Tools/Audio/Update
 *    
 *  - 注意：
 *    - 1.音频格式统一化, 如全部只用一种后缀
 *    - 2.Assets/游戏名/Sound/ ---> 游戏名要规范大小写, 所有音频固定存放路径, 其他路径音频搬到此路径。
 *       - 通用路径：  Assets/游戏名/Sound/
 *       - 多语言路径：Assets/游戏名/Sound/语言/   ---> 多语言中以中文为基础
 *    
 *  - Lua调用例子：
 <<!--
    -- Main.lua & LoadingUI.lua
    -- 通过LoadingUI:Load()来加载, 取消之前直接 SEnv.loader:LoadScene('MainScene') 打开场景
    
    -- Sound.lua 全局调用
    Sound:PlaySound("jxlw-start", false) -- 播放通用音效
    Sound:PlayBgMusic("jslwbg")          -- 播放通用背景
    Sound:PlayConvertSound("stopbet")    -- 播放转换音效
    Sound:PlayConvertBgMusic("jslwbg")   -- 播放转换背景
 >>
 */
using ForReBuild;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class AudioConfig
{
    public static string[] ExtList = { ".wav", ".mp3", ".ogg" };
    public static string[] LanguageList = { "CN", "EN" };
    public const string FinalPath = "Assets/AssetsFinal/";
    public const string resName = "";     // 默认不填就根据resPath选取, 填写就指定名称, 格式：jx
    public const string resPath = "Assets/Dance/Sound/";     // 默认不填就自动搜索, 填写就指定目录, 格式：Assets/JiuXian/Sound/
}

[CustomEditor(typeof(AudioPackage))]
public class AudioPackageEditor : Editor
{
    [MenuItem("Tools/Audio/Update")]
    static void UpdateAudio()
    {
        ToAudio.Tools.Generate_AudioInfo();
    }

    #region 处理音频加载逻辑

    public override void OnInspectorGUI()
    {
        var targetcom = (AudioPackage)target;
        DrawDefaultInspector();
        if (GUILayout.Button("一键导入音频")) { AutoImportAudio(targetcom); }
        if (GUILayout.Button("自动读取BasePath")) { LoadBasePath(targetcom); }
        if (GUILayout.Button("从audioClips生成audioClipDatas")) { LoadAudioClipDatas(targetcom); }
    }

    private void LoadBasePath(AudioPackage targetcom) { ToAudio.Tools.LoadBasePath(targetcom); }

    private void LoadAudioClipDatas(AudioPackage targetcom) { ToAudio.Tools.LoadAudioClipDatas(targetcom); }

    /// <summary>
    /// 自动导入音频
    /// </summary>
    private void AutoImportAudio(AudioPackage targetcom)
    {
        if (targetcom.basePath == string.Empty)
        {
            Debug.Log("请输入需要读取的音频路径, 格式(*代表游戏名): Assets/*/Sound/");
            return;
        }
        string path = (Application.dataPath + "/" + targetcom.basePath).Replace("/Assets/Assets", "/Assets");
        Debug.Log("读取path=" + path);

        if (Directory.Exists(path) == false)
        {
            Debug.Log(string.Format("{0}不存在目录, 请重新输入目录, 格式(*代表游戏名): Assets/*/Sound/", path));
            return;
        }

        targetcom.audioClips = ToAudio.Tools.LoadAudioList(path).ToArray();
        LoadAudioClipDatas(targetcom);
    }
    #endregion
}

namespace ToAudio
{
    public abstract class Node
    {
        public enum NodeType { Dir, File }
        public abstract NodeType type { get; }
        public List<Node> subNode = new List<Node>();
        public string path;
        public void AddSubNode(Node node) { subNode.Add(node); }
    }

    public class FileNode : Node
    {
        public override NodeType type => NodeType.File;
        public FileNode(string str) { path = str; }
    }

    public class DirNode : Node
    {
        public override NodeType type => NodeType.Dir;
        public DirNode(string str) { path = str; }
    }

    public class Tools
    {
        private static string resName = AudioConfig.resName; // 不填就根据resPath选取, 填写就指定名称
        private static string resPath = AudioConfig.resPath; // 不填就自动搜索, 填写就指定目录
        private static string szFileCount = "";              // 记录文件数量

        #region 常用逻辑

        public static void LoadAudioClipDatas(AudioPackage targetcom)
        {
            targetcom.audioClipDatas = new AudioPackage.AudioClipData[targetcom.audioClips.Length];
            for (int i = 0; i < targetcom.audioClips.Length; i++)
            {
                var clip = targetcom.audioClips[i];
                var p = targetcom.basePath;

                var data = new AudioPackage.AudioClipData();
                data.clip = clip;
                data.pathOrName = p + clip.name;
                data.name = clip.name;
                targetcom.audioClipDatas[i] = data;
            }
            EditorUtility.SetDirty(targetcom);
        }

        public static void LoadBasePath(AudioPackage targetcom)
        {
            foreach (var clip in targetcom.audioClips)
            {
                var p = AssetDatabase.GetAssetPath(clip);
                targetcom.basePath = p.Replace(Path.GetFileName(p), "");
                break;
            }
        }

        public static bool CheckPath(string path)
        {
            if (Directory.Exists(path) == false)
            {
                Debug.Log(string.Format("{0}不存在目录, 请重新输入目录, 格式(*代表游戏名): Assets/*/Sound/", path));
                return false;
            }
            return true;
        }

        public static string GetUpperCharToLoweChar(string str)
        {
            string newChar = "";
            char[] arr = str.ToCharArray();
            for (int i = 0; i < arr.Length; i++) { if (arr[i] >= 'A' && arr[i] <= 'Z') { newChar += arr[i]; } }
            return newChar.ToLower();
        }

        public static List<AudioClip> LoadAudioList(string path)
        {
            var audios = new List<AudioClip>();

            int index = 0;
            DirectoryInfo dis = new DirectoryInfo(path);
            List<FileInfo> list = new List<FileInfo>();

            foreach (FileInfo file in dis.GetFiles()) { foreach (string ext in AudioConfig.ExtList) { if (file.Extension.ToLower() == ext) { list.Add(file); } } }

            foreach (FileInfo file in list)
            {
                string aPath = file.OpenRead().Name.Replace('\\', '/');
                string bPath = Application.dataPath.Replace('\\', '/');
                string cPath = aPath.Replace(bPath, "");

                //Debug.Log(string.Format("{0}:音频={1}, dpath={2}", index++, file.OpenRead().Name, cPath));

                AudioClip tt = AssetDatabase.LoadMainAssetAtPath("Assets" + cPath) as AudioClip;
                tt.name = file.Name.Replace(file.Extension.ToLower(), "");
                audios.Add(tt);
            }

            return audios;
        }
        #endregion

        #region 处理自动生成逻辑
        public static void Generate_AudioInfo()
        {
            // 自动搜索音频目录
            if (Search_AudioPath())
            {
                Create_Prefab();   // 创建音频预设
                VerifyAudioFile(); // 以中文为准, 校验多语言是否匹配
                Write_AudioAB();   // 自动写入音频目录下音频的AB名
                Debug.Log(string.Format("更新音频文件成功, {0}", szFileCount));
            }
        }

        /// <summary>
        /// 搜索音频目录
        /// </summary>
        private static bool Search_AudioPath()
        {
            Debug.Log("dataPath=" + Application.dataPath);

            // 自动搜索音频目录
            if (resPath == string.Empty)
            {
                var node = new ToAudio.DirNode(Application.dataPath);
                GetDirectoryInfo(Application.dataPath, 3, node);
            }
            if (resPath == string.Empty)
            {
                Debug.LogError("搜索音频失败, 存放音频目录格式错误或者没有存放音效文件");
                return false;
            }
            string tmp = resPath.Replace("Assets", "").Replace("Sound", "").Replace("/", "");
            resName = tmp.ToLower();//GetUpperCharToLoweChar(tmp);

            if (resName == string.Empty)
            {
                Debug.LogError("搜索音频失败, 资源文件存放路径格式不正确, 指定resName或者更换目录");
                return false;
            }

            if (Directory.Exists(resPath) == false)
            {
                Directory.CreateDirectory(resPath);
            }

            Debug.Log(string.Format("resPath={0}, resName={1}", resPath, resName));
            return true;
        }

        /// <summary>
        /// 写入音频AB名
        /// assetBundleName 可以命名成 xxx.bundle ；assetBundleVariant = 空的形式
        /// assetBundleName 也可以命名成 xxx ；assetBundleVariant = ".bundle" 的形式，但不能同时存在两种形式，会导致打包出问题，资源无法加载到
        /// </summary>
        private static void Write_AudioAB()
        {
            // prefab 加载时可自动加载音频资源，不再单独加载音频所以不需要打bundle
            //// 音效-常用
            //var common_list = LoadAudioList(resPath);
            //common_list?.ForEach(x =>
            //{
            //    var ai = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(x));
            //    ai.assetBundleName = "audio/2d.bundle";
            //    ai.assetBundleVariant = "";
            //    //Debug.LogError("common====>" + x + ", ab=" + ai.assetBundleName + ", v=" + ai.assetBundleVariant);
            //});

            // 最终-常用
            var _ai = AssetImporter.GetAtPath(AudioConfig.FinalPath + "commonSound.prefab");
            if (_ai != null)
            {
                _ai.assetBundleName = resName + "_sounds.bundle";
                _ai.assetBundleVariant = "";
            }

            foreach (string language in AudioConfig.LanguageList)
            {
                //// 音效-多语言
                //var language_list = LoadAudioList(resPath + language);
                //language_list?.ForEach(x =>
                //{
                //    var ai = AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(x));
                //    ai.assetBundleName = ("voice_" + language).ToLower() + ".bundle";
                //    ai.assetBundleVariant = "";
                //    //Debug.LogError("language====>" + x + ", ab=" + ai.assetBundleName + ", v=" + ai.assetBundleVariant);
                //});

                // 最终-多语言
                var __ai = AssetImporter.GetAtPath(AudioConfig.FinalPath + "voice_" + language + ".prefab");
                if (__ai != null)
                {
                    __ai.assetBundleName = ("voice_" + language).ToLower() + ".bundle";
                    __ai.assetBundleVariant = "";
                }
            }

            AssetDatabase.Refresh();
        }

        /// <summary>
        /// 创建音频预设
        /// </summary>
        private static void Create_Prefab()
        {
            if (!CheckPath(resPath))
            {
                Debug.LogError("创建失败, resPath不能为空");
                return;
            }

            szFileCount = string.Format("【通用】音频数量={0}", LogicCreatePre(resPath, "commonSound.prefab"));
            foreach (string language in AudioConfig.LanguageList)
            {
                szFileCount += string.Format(", 【{0}】音频数量={1}", language, LogicCreatePre(resPath + language, "voice_" + language + ".prefab"));
            }
        }

        private static int LogicCreatePre(string respath, string saveName)
        {
            if (Directory.Exists(AudioConfig.FinalPath) == false) { Directory.CreateDirectory(AudioConfig.FinalPath); }
            if (Directory.Exists(respath) == false) { Directory.CreateDirectory(respath); }

            GameObject obj = new GameObject();
            var src = obj.AddComponent<AudioPackage>();
            src.initOnStart = true;
            src.audioClips = LoadAudioList(respath).ToArray();
            LoadBasePath(src);
            LoadAudioClipDatas(src);
            obj.AddComponent<DontDestroyOnNextScene>();
            if (src.basePath == string.Empty) { src.basePath = respath; }

            PrefabUtility.SaveAsPrefabAsset(obj, AudioConfig.FinalPath + saveName);
            Object.DestroyImmediate(obj);
            return src.audioClips.Length;
        }

        /// <summary>
        /// 校验缺少音效文件
        /// </summary>
        private static void VerifyAudioFile()
        {
            if (AudioConfig.LanguageList.Length < 2)
            {
                Debug.LogError("不存在多语言, c=" + AudioConfig.LanguageList.Length);
                return;
            }

            string standard = AudioConfig.LanguageList[0];
            var standard_list = LoadAudioList(resPath + standard);

            for (int i = 1; i < AudioConfig.LanguageList.Length; i++)
            {
                var language = AudioConfig.LanguageList[i];
                var language_list = LoadAudioList(resPath + language);
                string lack = "", extra = "";

                // 缺少文件
                standard_list?.ForEach(x =>
                {
                    bool isExist = false;
                    language_list?.ForEach(y => { if (x.name == y.name) { isExist = true; } });
                    if (!isExist) { lack += x.name + ";"; }
                });
                if (lack != string.Empty) { Debug.LogError(string.Format("【{0}】--> 不存在音效文件列表：{1}", language, lack)); }

                // 多出文件
                language_list?.ForEach(x =>
                {
                    bool isExist = false;
                    standard_list?.ForEach(y => { if (x.name == y.name) { isExist = true; } });
                    if (!isExist) { extra += x.name + ";"; }
                });
                if (extra != string.Empty) { Debug.LogError(string.Format("【{0}】--> 多出的音效文件列表：{1}", language, extra)); }
            }
        }

        /// <summary>
        /// 遍历算法--递归查找
        /// </summary>
        /// <param name="dir">文件路径</param>
        /// <param name="depth">遍历目标层级---默认递归深度</param>
        /// <param name="node">当前根文件夹</param>
        private static void GetDirectoryInfo(string dir, int depth, ToAudio.Node node)
        {
            if (depth <= 0)
                return;

            depth--;

            if (Directory.Exists(dir))
            {
                // 查找文件夹
                string[] subDirs = Directory.GetDirectories(dir);
                foreach (var item in subDirs)
                {
                    var dirNode = new ToAudio.DirNode(item);
                    node.AddSubNode(dirNode); // 添加文件夹入列表

                    if (dirNode.path.Contains(".meta")) { continue; }
                    //Debug.Log("___DirNode___===" + item);
                    GetDirectoryInfo(item, depth, dirNode);
                }

                // 查找文件
                string[] subFiles = Directory.GetFiles(dir);
                foreach (var item in subFiles)
                {
                    string path = item.Replace(Application.dataPath, "").Replace("\\", "/");
                    if (path.Contains(".meta")) { continue; }

                    bool isExist = false;
                    //foreach (var ext in AudioConfig.ExtList) { if (Path.GetExtension(path) == ext) { isExist = true; break; } }
                    if (Path.GetExtension(path) == ".prefab" && Path.GetFileName(path).Contains("_MainUI"))
                    { // 以子游戏主UI搜索, 直接搜音频可能乱放目录找出错误目录
                        resPath = "Assets" + (path.Substring(0, path.LastIndexOf("/"))).Replace("UIPrefab", "Sound") + "/";
                        Debug.Log("寻找音频文件路径===" + resPath);
                        return;
                    }

                    if (isExist)
                    {
                        Debug.Log("寻找音频文件路径===" + path);
                        resPath = "Assets" + path.Substring(0, path.LastIndexOf("/")) + "/";
                        return;
                    }
                    else
                    {
                        GetDirectoryInfo(path, depth, node); // 不存在继续递归
                    }
                }
            }
            else if (File.Exists(dir))
            {
                var fileNode = new ToAudio.FileNode(dir);
                node.AddSubNode(fileNode);
            }
        }
        #endregion
    }
}