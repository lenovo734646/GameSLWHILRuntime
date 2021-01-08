using ForReBuild;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
[CustomEditor(typeof(AudioPackage))]
public class AudioPackageEditor : Editor {



    public override void OnInspectorGUI() {
        var targetcom = (AudioPackage)target;
        DrawDefaultInspector();
        //GUILayout.BeginHorizontal();
        //if (GUILayout.Button("从文件夹路径创建")) {
        //    var p= AssetDatabase.GetAssetPath(targetcom.audioClips[0]);

        //    Debug.Log(p);
        //}
        //path = GUILayout.TextField("");
        //GUILayout.EndHorizontal();
        if (GUILayout.Button("自动读取BasePath")) {
            foreach (var clip in targetcom.audioClips) {
                var p = AssetDatabase.GetAssetPath(clip);
                targetcom.basePath = p.Replace(Path.GetFileName(p), "");
                break;
            }
        }
        if (GUILayout.Button("从audioClips生成audioClipDatas")) {
            targetcom.audioClipDatas = new AudioPackage.AudioClipData[targetcom.audioClips.Length];
            for(int i=0;i< targetcom.audioClips.Length; i++) {
                var clip = targetcom.audioClips[i];
                var p = targetcom.basePath;
                
                var data = new AudioPackage.AudioClipData();
                data.clip = clip;
                data.pathOrName = p+clip.name;
                data.name = clip.name;
                targetcom.audioClipDatas[i] = data;
            }
            EditorUtility.SetDirty(targetcom);
        }
            

    }
}
