using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

// 创建bmfont  
// 继承自编辑器的扩展，用来扩展我们的编辑器的，应该放到Editor这个目录下;

public class CreateBMPFontEditor : Editor
{
    // 制定我们入口的菜单
    [MenuItem("Assets/Create/CreateBMFont")]
    static void CreateFont()
    {
        // 当前选择的物体
        Object obj = Selection.activeObject;
        // Unity API 返回当前你选择的资源的路径
        string fntPath = AssetDatabase.GetAssetPath(obj);
        Debug.Log("#####" + fntPath);

        // 程序需要从fnt文件里面导入我们字模信息;
        if (fntPath.IndexOf(".fnt") == -1)
        {
            // 不是字体文件  
            return;
        }
        //
        string fontTexturePath = fntPath.Replace(".fnt", ".png");
        Texture2D fontTex = AssetDatabase.LoadAssetAtPath<Texture2D>(fontTexturePath);
        if(fontTex == null)
        {
            Debug.LogError("获取字体图片失败：" + fontTexturePath);
            return;
        }
        // 创建字体和材质
        string customFontPath = fntPath.Replace(".fnt", ".fontsettings");
        Font font = AssetDatabase.LoadAssetAtPath<Font>(customFontPath);
        if (font == null)
        {
            font = new Font();
            Material material = new Material(Shader.Find("GUI/Text Shader"));
            material.mainTexture = fontTex;
            string matPath = fntPath.Replace(".fnt", ".mat");
            AssetDatabase.CreateAsset(material, matPath);
            font.material = material;
            AssetDatabase.CreateAsset(font, customFontPath);
        }

        // your_name.fnt --> your_name.fontsetting;名字一致
        // new path --> .fnt --> .fontsettings;
        
        if (!File.Exists(customFontPath))
        {
            return;
        }

        Debug.Log(fntPath);
        StreamReader reader = new StreamReader(new FileStream(fntPath, FileMode.Open));

        List<CharacterInfo> charList = new List<CharacterInfo>();

        Regex reg = new Regex(@"char id=(?<id>\d+)\s+x=(?<x>\d+)\s+y=(?<y>\d+)\s+width=(?<width>\d+)\s+height=(?<height>\d+)\s+xoffset=(?<xoffset>\d+)\s+yoffset=(?<yoffset>\d+)\s+xadvance=(?<xadvance>\d+)\s+");
        string line = reader.ReadLine();
        int lineHeight = 0;
        int texWidth = 1;
        int texHeight = 1;

        while (line != null)
        {
            if (line.IndexOf("char id=") != -1)
            {
                Match match = reg.Match(line);
                if (match != Match.Empty)
                {
                    var id = System.Convert.ToInt32(match.Groups["id"].Value);
                    var x = System.Convert.ToInt32(match.Groups["x"].Value);
                    var y = System.Convert.ToInt32(match.Groups["y"].Value);
                    var width = System.Convert.ToInt32(match.Groups["width"].Value);
                    var height = System.Convert.ToInt32(match.Groups["height"].Value);
                    var xoffset = System.Convert.ToInt32(match.Groups["xoffset"].Value);
                    var yoffset = System.Convert.ToInt32(match.Groups["yoffset"].Value);
                    var xadvance = System.Convert.ToInt32(match.Groups["xadvance"].Value);

                    CharacterInfo info = new CharacterInfo();
                    info.index = id;
                    float uvx = 1f * x / texWidth;
                    float uvy = 1 - (1f * y / texHeight);
                    float uvw = 1f * width / texWidth;
                    float uvh = -1f * height / texHeight;

                    info.uvBottomLeft = new Vector2(uvx, uvy);
                    info.uvBottomRight = new Vector2(uvx + uvw, uvy);
                    info.uvTopLeft = new Vector2(uvx, uvy + uvh);
                    info.uvTopRight = new Vector2(uvx + uvw, uvy + uvh);

                    info.minX = xoffset;
                    info.minY = yoffset + height / 2;   // 这样调出来的效果是ok的，原理未知  
                    info.glyphWidth = width;
                    info.glyphHeight = -height; // 同上，不知道为什么要用负的，可能跟unity纹理uv有关  
                    info.advance = xadvance;

                    charList.Add(info);
                }
            }
            else if (line.IndexOf("scaleW=") != -1)
            {
                Regex reg2 = new Regex(@"common lineHeight=(?<lineHeight>\d+)\s+.*scaleW=(?<scaleW>\d+)\s+scaleH=(?<scaleH>\d+)");
                Match match = reg2.Match(line);
                if (match != Match.Empty)
                {
                    lineHeight = System.Convert.ToInt32(match.Groups["lineHeight"].Value);
                    texWidth = System.Convert.ToInt32(match.Groups["scaleW"].Value);
                    texHeight = System.Convert.ToInt32(match.Groups["scaleH"].Value);
                }
            }
            line = reader.ReadLine();
        }

        font.characterInfo = charList.ToArray();
        AssetDatabase.Refresh();
        AssetDatabase.SaveAssets();
        EditorUtility.SetDirty(font);
        Debug.Log("创建完成...");
    }
}