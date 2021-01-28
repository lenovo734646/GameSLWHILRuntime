﻿
/******************************************************************************
 * 
 *  Title:  捕鱼项目
 *
 *  Version:  1.0版
 *
 *  Description:
 *
 *  Author:  WangXingXing
 *       
 *  Date:  2018
 * 
 ******************************************************************************/

using DG.Tweening;
using ICSharpCode.SharpZipLib.Zip;
using Spine.Unity;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Unity.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Networking;
using XLua;
using ZXing;

public static class UnityHelper
{
    static UnityHelper() {
        UnityEngine.Random.InitState(DateTime.Now.Millisecond);
    }

    /// <summary>
    /// CA3加密算法：高效快速，自带校验功能
    /// </summary>
    /// <param name="originContent">原始内容</param>
    /// <param name="randumKey">数字随机key</param>
    /// <returns>密文字符串</returns>
    public static string CA3Encode(string originContent, int randumKey)
    {
        byte[] content = System.Text.Encoding.UTF8.GetBytes(originContent);
        byte[] buffer = new byte[content.Length + 4];
        Array.Copy(BitConverter.GetBytes(randumKey), 0, buffer, 0, 4);
        Array.Copy(content, 0, buffer, 4, content.Length);

        int a = 12347, b = 20809, c = 65536;
        for (int i = 0; i < buffer.Length; ++i)
        {
            randumKey = (randumKey * a + b) % c;
            buffer[i] ^= (byte)(randumKey & 0xff);
        }
        return Convert.ToBase64String(buffer);
    }

    /// <summary>
    /// CA3解密算法：高效快速，自带校验功能
    /// </summary>
    /// <param name="encryptContent">密文</param>
    /// <param name="randumKey">数字随机key</param>
    /// <returns>原始内容</returns>
    public static string CA3Decode(string encryptContent, int randumKey)
    {
        byte[] buffer = Convert.FromBase64String(encryptContent);

        if (buffer.Length > 4)
        {
            int tmpKey = randumKey;
            int a = 12347, b = 20809, c = 65536;
            for (int i = 0; i < buffer.Length; ++i)
            {
                randumKey = (randumKey * a + b) % c;
                buffer[i] ^= (byte)(randumKey & 0xff);
            }

            int key = BitConverter.ToInt32(buffer, 0);
            if (key == tmpKey)
                return System.Text.Encoding.UTF8.GetString(buffer, 4, buffer.Length - 4);
        }

        return string.Empty;
    }

    //UrlEncode
    public static string GetUrlEncode(string str)
    {
        StringBuilder sb = new StringBuilder();
        byte[] byStr = System.Text.Encoding.UTF8.GetBytes(str);
        for (int i = 0; i < byStr.Length; i++)
        {
            sb.Append(@"%" + Convert.ToString(byStr[i], 16));
        }
        return (sb.ToString());
    }

    //是否点击在UI控件上，用于判断UI点穿
    public static bool IsPointerOverUIObject()
    {
        if (EventSystem.current == null)
            return false;

        // Referencing this code for GraphicRaycaster https://gist.github.com/stramit/ead7ca1f432f3c0f181f
        // the ray cast appears to require only eventData.position.
        PointerEventData eventDataCurrentPosition = new PointerEventData(EventSystem.current);
        eventDataCurrentPosition.position = new Vector2(Input.mousePosition.x, Input.mousePosition.y);

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);

        var count = results.Count - 1;
        for (int i = count; i >= 0; i--)
        {
            if (results[i].gameObject.layer != 5)
                results.RemoveAt(i);
        }

        return results.Count > 0;
    }

    /// <summary>
    /// 将服务器鱼的坐标转换成游戏坐标
    /// </summary>
    /// <param name="x">服务器点的x的值</param>
    /// <param name="y">服务器点的y的值</param>
    /// <param name="z">服务器点的z的值</param>
    /// <returns></returns>
    public static Vector3 ConvertToVector3(RectTransform rectTransform, float x,float y,float z)
    {
        //todo 根据游戏屏幕做适配 目前的标准是 1920*1080
        //x = -(9.6f - x * 19.2f);
        //y = -(5.4f - y * 10.8f);
        //z = -(49.0f - z * 98.0f);
        //return new Vector3(x, y, z);
        // var rect = GlobalLuaShareWithCSharp.GetUnityObject<RectTransform>("UIParent").rect;
        var rect = rectTransform.rect;
        var widthInSpace = rect.width * 0.01f;
        var heightInSpace = rect.height * 0.01f;
        x = -(widthInSpace * 0.5f - x * widthInSpace);
        y = -(heightInSpace * 0.5f - y * heightInSpace);
        z = -(49.0f - z * 98.0f);
        return new Vector3(x, y, z);
    }
    public static Vector3 FishConvertToVector3(float x, float y, float z)
    {
        //todo 根据游戏屏幕做适配 目前的标准是 1920*1080
        //var anchorX = SeatHelper.IsServerSeatNegative() ? -9.6f : 9.6f;
        //var anchorY = SeatHelper.IsServerSeatNegative() ? -5.4f : 5.4f;
        //x = -(anchorX - x * 19.2f);
        //y = -(anchorY - y * 10.8f);
        //z = -(49.0f - z * 98.0f);
        return (new Vector3(x, y, z)) * 100;
    }

    /// <summary>
    /// 计算两点与X轴的顺时针夹角角度
    /// </summary>
    /// <param name="x1">x1坐标</param>
    /// <param name="y1">y1坐标</param>
    /// <param name="x2">x2坐标</param>
    /// <param name="y2">y2坐标</param>
    /// <returns>向量与X轴顺时针夹角角度</returns>
    public static float CalculateClockwiseAngle(float x1, float y1, float x2, float y2)
    {
        var radian = Mathf.Atan2(y1 - y2, x2 - x1);
        return radian * (180 / Mathf.PI);
    }

    /// <summary>
    /// 计算两点与X轴的逆时针夹角角度
    /// </summary>
    /// <param name="x1">x1坐标</param>
    /// <param name="y1">y1坐标</param>
    /// <param name="x2">x2坐标</param>
    /// <param name="y2">y2坐标</param>
    /// <returns>向量与X轴逆时针夹角角度</returns>
    public static float CalculateAnticlockwiseAngle(float x1, float y1, float x2, float y2)
    {
        var radian = Mathf.Atan2(y2 - y1, x2 - x1);
        return radian * (180 / Mathf.PI);
    }

    /// <summary>
    /// 计算两点间的距离
    /// </summary>
    /// <param name="startPos">起点坐标</param>
    /// <param name="endPos">终点坐标</param>
    /// <returns>距离</returns>
    public static float CalculateDistance(Vector2 startPos, Vector2 endPos)
    {
        var deltaX = endPos.x - startPos.x;
        var deltaY = endPos.y - startPos.y;
        return (float)Math.Sqrt(deltaX * deltaX + deltaY * deltaY);
    }

    /// <summary>
    /// 将角度修正到0~360范围内
    /// </summary>
    /// <param name="angle">输入角度</param>
    /// <returns>修正后的角度</returns>
    public static float RectifyAngle(float angle)
    {
        var r = angle % 360;
        return r < 0 ? r + 360 : r;
    }

    /// <summary>
    /// 角度转弧度
    /// </summary>
    /// <param name="angle">角度</param>
    /// <returns>弧度</returns>
    public static float AngleToRadian(float angle)
    {
        return (float)(angle / 180 * Math.PI);
    }

    /// <summary>
    /// 根据起点和角度计算终点位置
    /// </summary>
    /// <param name="startX">起点x坐标</param>
    /// <param name="startY">起点y坐标</param>
    /// <param name="length">长度</param>
    /// <param name="angle">与X轴逆时针夹角角度</param>
    /// <returns>终点位置</returns>
    public static Vector2 CalculateDestPointByAngle(Vector2 startPos, float length, float angle)
    {
        var radian = angle / 180 * Math.PI;
        var x = startPos.x + length * (float)Math.Cos(radian);
        var y = startPos.y + length * (float)Math.Sin(radian);
        return new Vector2(x, y);
    }

    /// <summary>
    /// 播放spine2D动画
    /// </summary>
    /// <param name="obj">将要播放动画的物体控件</param>
    /// <param name="anim">动画名称</param>
    /// <param name="loop">是否循环播放</param>
    public static void PlaySpineAnim(GameObject obj, string anim, bool loop)
    {
        SkeletonGraphic graphic = obj.GetComponent<SkeletonGraphic>();
        if (graphic == null)
            return;

        graphic.startingAnimation = anim;
        graphic.startingLoop = loop;
        graphic.Initialize(true);
    }

    /// <summary>
    /// 清除父节点下所有子节点
    /// </summary>
    /// <param name="trans">父节点</param>
    public static void ClearChildren(Transform trans)
    {
        if (null == trans)
            return;
        for (int i = 0; i < trans.childCount; i++)
        {
            UnityEngine.Object.Destroy(trans.GetChild(i).gameObject);
        }
    }

    /// <summary>
    /// 查找子对象
    /// </summary>
    /// <param name="goParent">父对象</param>
    /// <param name="childName">子对象名称</param>
    /// <returns></returns>
    public static Transform FindTheChild(GameObject goParent, string childName)
    {
        Transform searchTrans = goParent.transform.Find(childName);
        if (ReferenceEquals(searchTrans, null))
        {
            foreach (Transform trans in goParent.transform)
            {
                searchTrans = FindTheChild(trans.gameObject, childName);
                if (!ReferenceEquals(searchTrans, null))
                {
                    return searchTrans;
                }
            }
        }
        return searchTrans;
    }

    /// <summary>
    /// 获取子物体的脚本
    /// </summary>
    /// <typeparam name="T">泛型</typeparam>
    /// <param name="goParent">父对象</param>
    /// <param name="childName">子对象名称</param>
    /// <returns></returns>
    public static T GetTheChildComponent<T>(GameObject goParent, string childName) where T : Component
    {
        Transform searchTrans = FindTheChild(goParent, childName);
        return ReferenceEquals(searchTrans, null) ? null : searchTrans.GetOrAddComponent<T>();
    }
    public static Component GetTheChildComponent(GameObject goParent, string childName, Type type){
        Transform searchTrans = FindTheChild(goParent, childName);
        return ReferenceEquals(searchTrans, null) ? null : searchTrans.GetOrAddComponent(type);
    }

    /// <summary>
    /// 给子物体添加脚本
    /// </summary>
    /// <typeparam name="T">泛型</typeparam>
    /// <param name="goParent">父对象</param>
    /// <param name="childName">子对象名称</param>
    /// <returns></returns>
    public static T AddTheChildComponent<T>(GameObject goParent, string childName) where T : Component
    {
        Transform searchTrans = FindTheChild(goParent, childName);
        return ReferenceEquals(searchTrans, null) ? null : searchTrans.GetOrAddComponent<T>();
    }
    public static Component AddTheChildComponent(GameObject goParent, string childName, Type type) {
        Transform searchTrans = FindTheChild(goParent, childName);
        return ReferenceEquals(searchTrans, null) ? null : searchTrans.GetOrAddComponent(type);
    }

    /// <summary>
    /// 给子物体添加父对象
    /// </summary>
    /// <param name="parentTrs">父对象的方位</param>
    /// <param name="childTrs">子对象的方位</param>
    public static void AddChildToParent(Transform parentTrs, Transform childTrs)
    {
        childTrs.SetParent(parentTrs, false);
        childTrs.localPosition = Vector3.zero;
        childTrs.localScale = Vector3.one;
        childTrs.localEulerAngles = Vector3.zero;
    }

    /// <summary>
    /// 复制到剪切板
    /// </summary>
    /// <param name="content">复制的内容</param>
    public static void CopyToClipboard(string content)
    {
        TextEditor te = new TextEditor();
        te.text = new GUIContent(content).text;
        te.SelectAll();
        te.Copy();
    }

    /// <summary>
    /// 用户名显示
    /// </summary>
    /// <param name="nickName">昵称</param>
    /// <param name="length">默认长度12个字符</param>
    /// <returns></returns>
    public static string GetNickNameFormat(string nickName, int length = 12)
    {
        if (string.IsNullOrEmpty(nickName))
            return "";
        int i = 0;//字节数
        int j = 0;//实际截取长度
        foreach (var ch in nickName)
        {
            if (ch > 127)//汉字
                i += 2;
            else
                i++;
            if (i <= length)
                j++;
        }
        return nickName = i <= length ? nickName : nickName.Substring(0, j) + "..";
    }

    /// <summary>
    /// 按汉字占两个字节数获取字符串的长度
    /// </summary>
    /// <param name="content">字符串</param>
    /// <returns>字符串的字节长度</returns>
    public static int GetStringlength(string content)
    {
        var len = 0;
        if (!string.IsNullOrEmpty(content))
        {
            foreach (var ch in content)
            {
                if (ch > 127)
                    len += 2;
                else
                    len++;
            }
        }
        return len;
    }

    /// <summary>
    /// 根据传进来的参数创建一个hashtable
    /// </summary>
    /// <param name="args">成对可变参数</param>
    /// <returns></returns>
    public static Hashtable CreateHashtable(params object[] args)
    {
        Hashtable hashtable = null;
        if (args.Length % 2 == 0)
        {
            hashtable = new Hashtable(args.Length / 2);
            int i = 0;
            while (i < args.Length - 1)
            {
                hashtable.Add(args[i], args[i + 1]);
                i += 2;
            }
        }
        else
            Debug.LogError("Hashtable Error: Hash requires an even number of arguments!");
        return hashtable;
    }

    /// <summary>
    /// 数字格式化
    /// </summary>
    /// <param name="number">原数字</param><param name="dec">返回的字符串小数精度</param>
    public static string NumberFormat(long number, int dec = 2)
    {
        var str = string.Empty;
        var end = string.Empty;

        if (number >= 100000000)
        {
            var num = number * 0.00000001;
            str = $"{string.Format("{0:N" + dec + "}", num)}";
            end = "亿";
        }
        else if (number >= 10000)
        {
            var num = number * 0.0001;
            str = $"{string.Format("{0:N" + dec + "}", num)}";
            end = "万";
        }
        else
        {
            str = number.ToString();
        }
        if (dec > 0 && str.IndexOf(".") != -1)
        {
            var length = str.Length;
            for (int i = length - 1; i >= 0; i--)
            {
                var subChar = str.Substring(i, 1);
                if (subChar == ".")
                {
                    str = str.Substring(0, i);
                    break;
                }
                if (subChar == "0")
                {
                    str = str.Substring(0, i);
                }
                else
                    break;
            }
        }

        return str + end;
    }

    public static string NumberFormatByThousand(long number, int dec = 2)
    {
        var str = string.Empty;
        var end = string.Empty;

        if (number >= 100000000)
        {
            var num = number * 0.00000001;
            str = $"{string.Format("{0:N" + dec + "}", num)}";
            end = "亿";
        }
        else if (number >= 10000)
        {
            var num = number * 0.0001;
            str = $"{string.Format("{0:N" + dec + "}", num)}";
            end = "万";
        }
        else if (number >= 1000)
        {
            var num = number * 0.001;
            str = $"{string.Format("{0:N" + dec + "}", num)}";
            end = "千";
        }
        else
        {
            str = number.ToString();
        }
        if (dec > 0 && str.IndexOf(".") != -1)
        {
            var length = str.Length;
            for (int i = length - 1; i >= 0; i--)
            {
                var subChar = str.Substring(i, 1);
                if (subChar == ".")
                {
                    str = str.Substring(0, i);
                    break;
                }
                if (subChar == "0")
                {
                    str = str.Substring(0, i);
                }
                else
                    break;
            }
        }

        return str + end;
    }
    
    public static Transform PhysicsHit(Vector3 pos, float maxDistance, int layerMask)
    {
        Debug.LogWarning("最好不要使用这个函数");
        var ray = GLuaSharedHelper.GetUnityObject<Camera>("MainCamera").ScreenPointToRay(pos);
        RaycastHit hit;
        return Physics.Raycast(ray, out hit, maxDistance, layerMask) ? hit.transform : null;
    }
    public static Transform PhysicsHit2(Camera cam, Vector3 pos, float maxDistance, int layerMask) {
        var ray = cam.ScreenPointToRay(pos);
        RaycastHit hit;
        return Physics.Raycast(ray, out hit, maxDistance, layerMask) ? hit.transform : null;
    }

    public static Transform PhysicsHit2(Camera cam, Vector3 pos, float maxDistance) {
        var ray = cam.ScreenPointToRay(pos);
        RaycastHit hit;
        return Physics.Raycast(ray, out hit, maxDistance) ? hit.transform : null;
    }

    public static Transform PhysicsHit2(Camera cam, Vector3 pos) {
        var ray = cam.ScreenPointToRay(pos);
        RaycastHit hit;
        return Physics.Raycast(ray, out hit) ? hit.transform : null;
    }

    public static bool Raycast(Ray ray, out RaycastHit hitInfo, float maxDistance, int layerMask)
    {
        return Physics.Raycast(ray, out hitInfo, maxDistance, layerMask);
    }

    public static int GenMask(int mask, int gentype = 1) {
        LayerMask layerMask = new LayerMask();
        switch (gentype) {
            case 1: return layerMask = 1 << mask;//只打开
            case 2: return layerMask = 0 << mask;//排除
        }
        return layerMask.value;
    }
    public static int GenMasks(params int[] mask) {
        bool first = true;
        LayerMask layerMask = new LayerMask();
        foreach (var v in mask) {
            if (first) {
                layerMask = 1 << v;
                first = false;
            } else
                layerMask = layerMask | 1 << v;
        }
        return layerMask.value;
    }

    //生成二维码
    public static Texture2D GetQRCode(string str, int width, int height)
    {
        var t = new Texture2D(width, height);
        var color = GenerateQRCode(str, width, height);
        t.SetPixels32(color);
        t.Apply();
        return t;
    }

    private static Color32[] GenerateQRCode(string formatStr, int width, int height)
    {
        var options = new ZXing.QrCode.QrCodeEncodingOptions();
        options.CharacterSet = "UTF-8";
        options.Width = width;
        options.Height = height;
        options.Margin = 1;
        var barcodeWriter = new BarcodeWriter { Format = BarcodeFormat.QR_CODE, Options = options };
        return barcodeWriter.Write(formatStr);
    }

    /// <summary>
    /// 小数点保留两位数
    /// </summary>
    public static string GetPreciseDecimal(float num, int dec = 2)
    {
        var str = num.ToString();

        if (dec > 0 && str.IndexOf(".") != -1)
        {
            if (str.Length > (str.IndexOf(".") + dec + 1))
            {
                str = str.Substring(0, str.IndexOf(".") + dec + 1);
            }
        }
        return str;
    }

    //小游戏读取大厅配置表
    public static string LoadConfigByTableName(string fileName) {
        
        return GLuaSharedHelper.g_Env.Get<LuaTable>("dicConfig").Get<string>(fileName);

    }

    public static void ShakeCamera(DOTweenAnimation CameraAnim, int power) {
        switch (power) {
            case 1:
                CameraAnim.duration = 0.6f;
                CameraAnim.endValueV3 = Vector3.one * 20;
                CameraAnim.optionalInt0 = 15;
                CameraAnim.DORewind();
                CameraAnim.DOPlay();
                break;
            case 2:
                CameraAnim.duration = 0.8f;
                CameraAnim.endValueV3 = Vector3.one * 30;
                CameraAnim.optionalInt0 = 15;
                CameraAnim.DORewind();
                CameraAnim.DOPlay();
                break;
            case 3:
                CameraAnim.duration = 1f;
                CameraAnim.endValueV3 = Vector3.one * 50;
                CameraAnim.optionalInt0 = 20;
                CameraAnim.DORewind();
                CameraAnim.DOPlay();
                break;
            default:
                break;
        }
    }

    public static void World2UI(Vector3 wpos, RectTransform uiParent, RectTransform uiTarget, Camera uicamera, Camera wordCamera) {
        Vector3 spos = wordCamera.WorldToScreenPoint(wpos);
        Vector2 retPos;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(uiParent, new Vector2(spos.x, spos.y),
            uicamera, out retPos);
        uiTarget.localPosition = retPos;
    }

    public static string CalMd5(byte[] content) {
        MD5 md5 = MD5.Create();
        byte[] bytes = md5.ComputeHash(content);

        StringBuilder result = new StringBuilder();
        foreach (byte v in bytes)
            result.Append(v.ToString("X2"));

        return result.ToString();
    }
    public static string CalFileMd5(string filename) {
        return CalMd5(File.ReadAllBytes(filename));
    }
    public static string CalStringMd5(string str) {
        return CalMd5(Encoding.UTF8.GetBytes(str));
    }


    public static byte[] ProcessGZipDecode(byte[] content) {
        
        try {
            var wms = new MemoryStream();
            var ms = new MemoryStream(content, 0, content.Length);
            ms.Seek(0, SeekOrigin.Begin);
            var zip = new GZipStream(ms, CompressionMode.Decompress, true);
            var buf = new byte[4096];
            int n;
            while ((n = zip.Read(buf, 0, buf.Length)) != 0) {
                wms.Write(buf, 0, n);
            }
            zip.Close();
            ms.Close();
            var r = new byte[wms.Length];
            Array.Copy(wms.GetBuffer(), r, wms.Length);

            return r;
        } catch(Exception e) {
            Debug.LogError("ProcessGZipDecode "+e.Message);
        }
        
        return null;
    }
    public static string ReadUtf8String(BinaryReader br) {
        MemoryStream ms = new MemoryStream();
        while (true) {
            byte a = br.ReadByte();
            if (a == 0)
                break;
            ms.WriteByte(a);
        }
        return Encoding.UTF8.GetString(ms.GetBuffer(), 0, (int)ms.Length);
    }

    public class WaitWriteFile: CustomYieldInstruction {
        bool ok = false;
        public string errmsg = "";
        public override bool keepWaiting {
            get {
                return !ok;
            }
        }

        public WaitWriteFile(string filename, byte[] data, bool logerror = true) {
            writeFileAsync(filename, data, obj=> {
                errmsg = (string)obj;
                ok = true;
                if(!string.IsNullOrEmpty(errmsg)&& logerror) {
                    Debug.LogError(errmsg);
                }
            });
        }
    }

    public static void WriteFileAsync(string fn, byte[] data, Action<object> callback=null) {
        writeFileAsync(fn,data,callback);
    }

    private static async void writeFileAsync(string fn, byte[] data, Action<object> callback) {
        var errmsg = "";
        await Task.Run(() => {
            try {
                File.WriteAllBytes(fn, data);
            } catch (System.Exception ex) {
                errmsg = ex.Message;
            }
        });
        callback?.Invoke(errmsg);
    }
    public class WaitReadFile : CustomYieldInstruction {
        bool ok = false;
        public string errmsg = "";
        public byte[] data = null;
        public override bool keepWaiting {
            get {
                return !ok;
            }
        }

        public WaitReadFile(string filename, bool logerror = true) {
            readFileAsync(filename, (data, errmsg) => {
                ok = true;
                this.data = data;
                if (!string.IsNullOrEmpty(errmsg) && logerror) {
                    Debug.LogError(errmsg);
                }
            });
        }
    }
    private static async void readFileAsync(string fn, Action<byte[], string> callback) {
        var errmsg = "";
        byte[] data = null;
        await Task.Run(() => {
            try {
                data = File.ReadAllBytes(fn);
            } catch (System.Exception ex) {
                errmsg = ex.Message;
            }
        });
        callback?.Invoke(data, errmsg);
    }

    public static void UnZipFileAsync(string zipFileName, string targetDirectory, Action<object> callback, string fileFilter="") {
        unZipFileAsync(zipFileName, targetDirectory, fileFilter, callback);
    }
    private static async void unZipFileAsync(string zipFileName, string targetDirectory, string fileFilter, Action<object> callback) {
        var errmsg = "";
        await Task.Run(() => {
            try {
                var zip = new FastZip();
                zip.ExtractZip(zipFileName, targetDirectory, fileFilter);
            } catch (System.Exception ex) {
                errmsg = ex.Message;
            }
        });
        callback?.Invoke(errmsg);
    }

    public class WaitCreatePlayer : CustomYieldInstruction {
        bool ok = false;
        public GamePlayer data = null;
        public override bool keepWaiting {
            get {
                return !ok;
            }
        }

        public WaitCreatePlayer(CLGT.LoginAck ack) {
            newGamePlayerAsync(ack, (data) => {
                this.data = data;
                ok = true;
            });
        }
    }

    static async void newGamePlayerAsync(CLGT.LoginAck ack, Action<GamePlayer> callback) {
        GamePlayer player = null;
        await Task.Run(() => {
            player = new GamePlayer(ack);
        });
        callback(player);
    }
    public static string CalSha256(byte[] bytes) {
        byte[] hash = SHA256.Create().ComputeHash(bytes);

        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < hash.Length; i++) {
            builder.Append(hash[i].ToString("X2"));
        }

        return builder.ToString();
    }
    public static string CalSha256(string data) {
        byte[] bytes = Encoding.UTF8.GetBytes(data);
        return CalSha256(bytes);
    }

    public static byte[] ReadAllBytes(string path) {
        if (path.StartsWith("jar:")) {
            var filepath = path;
            var www = UnityWebRequest.Get(path);
            www.SendWebRequest();

            while (!www.isDone) { System.Threading.Thread.Sleep(1); }
            if (!string.IsNullOrEmpty(www.error)) {
             //   Debug.LogError(www.error + "\npath:"+ path);
                return null;
            }
            if (www.isNetworkError) {
              //  Debug.LogError("NetworkError \npath: "+ path);
                return null;
            }
            if(path.ToLower().EndsWith(".lua"))
                return Encoding.UTF8.GetBytes(www.downloadHandler.text);
            else
                return www.downloadHandler.data;
        }

        if (File.Exists(path))
            return File.ReadAllBytes(path);
        return null;
    }

    public static string ReadFile(string path) {
        if (path.StartsWith("jar:")) {
            var filepath = path;
            var www = UnityWebRequest.Get(path);
            www.SendWebRequest();

            while (!www.isDone) { System.Threading.Thread.Sleep(1); }
            if (!string.IsNullOrEmpty(www.error)) {
                //   Debug.LogError(www.error + "\npath:"+ path);
                return null;
            }
            if (www.isNetworkError) {
                //  Debug.LogError("NetworkError \npath: "+ path);
                return null;
            }
            return www.downloadHandler.text;

        }

        if (File.Exists(path))
            return File.ReadAllText(path);
        return null;
    }


    public static void WechatLoginReq(string appid) {
#if UNITY_ANDROID
        AndroidJavaClass jc = new AndroidJavaClass("com.qq1798.buyu.MainActivity");
        AndroidJavaClass jc_default = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject jo = jc_default.GetStatic<AndroidJavaObject>("currentActivity");
        jc.CallStatic("WechatLogin", jo, appid);
#elif UNITY_IOS
        ToiOS.LoginWeChat(appid);
#endif
    }

    public static string GetPlatform() {
#if UNITY_ANDROID
        return "Android";
#elif UNITY_IOS
        return "iOS";
#else
        return "Win";
#endif
    }
    public static int GetPlatformInt() {
#if UNITY_ANDROID
        return 2;
#elif UNITY_IOS
        return 1;
#else
        return 3;
#endif
    }

    //默认密钥向量   
    private static byte[] _offsetkey1 = { 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF };

    /// <summary>  
    /// AES加密算法   加密码长度1024 
    /// </summary>  
    /// <param name="plainText">明文字符串</param>  
    /// <param name="strKey">密钥</param>  
    /// <returns>返回加密后的密文字节数组</returns>  
    public static byte[] AESEncrypt(byte[] inputByteArray, byte[] keyBytes) {
        //分组加密算法  
        SymmetricAlgorithm des = Rijndael.Create();
        //byte[] inputByteArray = Encoding.UTF8.GetBytes(plainText);//得到需要加密的字节数组      
        //设置密钥及密钥向量  
        des.Key = keyBytes;
        des.IV = _offsetkey1;
        //des.ModeValue = CipherMode.CBC;
        des.Padding = PaddingMode.PKCS7;
        MemoryStream ms = new MemoryStream();
        CryptoStream cs = new CryptoStream(ms, des.CreateEncryptor(), CryptoStreamMode.Write);
        cs.Write(inputByteArray, 0, inputByteArray.Length);
        cs.FlushFinalBlock();
        byte[] cipherBytes = ms.ToArray();//得到加密后的字节数组  
        cs.Close();
        ms.Close();
        return cipherBytes;
    }

    /// <summary>  
    /// AES解密  加密码长度读取1040 +16  长度
    /// </summary>  
    /// <param name="cipherText">密文字节数组</param>  
    /// <param name="strKey">密钥</param>  
    /// <returns>返回解密后的字符串</returns>  
    public static byte[] fck(byte[] cipherText, byte[] keyBytes) {
        SymmetricAlgorithm des = Rijndael.Create();
        des.Key = keyBytes;
        des.IV = _offsetkey1;
        des.Padding = PaddingMode.PKCS7;
        byte[] decryptBytes = new byte[cipherText.Length];
        MemoryStream ms = new MemoryStream(cipherText);
        CryptoStream cs = new CryptoStream(ms, des.CreateDecryptor(), CryptoStreamMode.Read);
        cs.Read(decryptBytes, 0, decryptBytes.Length);
        cs.Close();
        ms.Close();
        return decryptBytes;
    }

    // 此函数小游戏单独用不到，注释掉了，避免报错
    // 不要同步到大厅
    //public class WaitLuaRequest : CustomYieldInstruction {
    //    bool ok = false;
    //    public string body;
    //    public override bool keepWaiting => !ok;

    //    public WaitLuaRequest(QLUploadRequest request) {
    //        NetController.Instance.PostLuaRequest(request, obj=> {
    //            body = (string)obj;
    //            ok = true;
    //        });
    //    }
    //    public WaitLuaRequest(QWebRequset request) {
    //        NetController.Instance.PostLuaRequest(request, obj => {
    //            body = (string)obj;
    //            ok = true;
    //        });
    //    }
    //}

    public class WaitUnZip : CustomYieldInstruction {
        public override bool keepWaiting => !ok;
        bool ok = false;

        public WaitUnZip(string srcpath, string dstpath, byte[] bytes = null) {
            UnZip(srcpath, dstpath, bytes);
        }
        async void UnZip(string srcpath, string dstpath, byte[] bytes) {
            await Task.Run(()=> {
                if (bytes != null) {
                    File.WriteAllBytes(srcpath, bytes);
                }
                new FastZip().ExtractZip(srcpath, dstpath, "");
            });
        }
    }

    public static bool IsUnityObjectValid(UnityEngine.Object @object) {
        return @object;
    }

    public static bool IsDir(string path) {
        // get the file attributes for file or directory
        FileAttributes attr = File.GetAttributes(path);
        return attr.HasFlag(FileAttributes.Directory);
    }

    public static void ForeachFile(string dir, Action<string> filehandler) {
        try {
            string[] files = Directory.GetFiles(dir);
            foreach (string file in files) {
                filehandler(file);
            }

            string[] dirs = Directory.GetDirectories(dir);
            foreach (string dir_ in dirs) {
                ForeachFile(dir_, filehandler);
            }
        } catch (Exception ex) {
            Debug.LogError(ex);
        }
    }

    public static void CopyDirectory(string sourceDirPath, string saveDirPath, 
        Action<string> filehandler = null) {
        try {
            if (!Directory.Exists(saveDirPath)) {
                Directory.CreateDirectory(saveDirPath);
            }
            string[] files = Directory.GetFiles(sourceDirPath);
            foreach (string file in files) {
                string pFilePath = saveDirPath + "/" + Path.GetFileName(file);
                if (File.Exists(pFilePath))
                    continue;
                File.Copy(file, pFilePath, true);
                filehandler?.Invoke(pFilePath);
            }

            string[] dirs = Directory.GetDirectories(sourceDirPath);
            foreach (string dir in dirs) {
                CopyDirectory(dir, saveDirPath + "/" + Path.GetFileName(dir), filehandler);
            }
        } catch (Exception ex) {
            Debug.LogError(ex);
        }
    }


    // 添加EventTrigger类型事件
    public static void AddTriggersListener(GameObject obj, EventTriggerType eventTriggerType, Action callback) {
        EventTrigger trigger = obj.GetComponent<EventTrigger>();
        if (trigger == null) {
            trigger = obj.AddComponent<EventTrigger>();
        }
        if (trigger.triggers.Count == 0) {
            trigger.triggers = new List<EventTrigger.Entry>();
        }


        EventTrigger.Entry entry = new EventTrigger.Entry();
        entry.eventID = eventTriggerType;
        entry.callback.AddListener((baseEventData) => { callback?.Invoke(); });

        trigger.triggers.Add(entry);
    }

    public static float RandomFloat(float min, float max) {
        return UnityEngine.Random.Range(min,max);
    }
    public static int RandomInt(int min, int max) {
        return UnityEngine.Random.Range(min, max);
    }

    public static string CalHash128(byte[] bytes) {
        var has128 = new Hash128();
        HashUtilities.ComputeHash128(bytes, ref has128);
        return has128.ToString();
    }
    public static string CalHash128UTF8(string str) {
        return CalHash128(Encoding.UTF8.GetBytes(str));
    }
    public static string CalHash128ASCII(string str) {
        return CalHash128(Encoding.ASCII.GetBytes(str));
    }
}