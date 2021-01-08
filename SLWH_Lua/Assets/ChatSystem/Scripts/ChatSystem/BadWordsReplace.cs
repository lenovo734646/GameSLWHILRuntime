using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;

namespace SP
{
    public class BadWordsReplace
    {
        private readonly System.Random rnd = new System.Random();

        List<string> pattenStrList = new List<string>();
        //string textAll;
        public BadWordsReplace(List<string> badwordsList)
        {
            pattenStrList = badwordsList;
        }
        //public BadWordsReplace(string badwordsFilePath)
        //{
        //    if(!File.Exists(badwordsFilePath))
        //    {
        //        Debug.LogError("文件不存在："+badwordsFilePath);
        //    }
        //    //textAll = File.ReadAllText(badwordsFilePath);
        //    //foreach (string str in text)
        //    //{
        //    //    var tempStr = str.Split('\n');
        //    //}
        //    FileStream fs = new FileStream(badwordsFilePath, FileMode.Open, FileAccess.Read);
        //    StreamReader sr = new StreamReader(fs);
        //    while (!sr.EndOfStream)
        //    {
        //        var arr = sr.ReadLine();
        //        var words = arr.Split('\n');
        //        foreach (var str in words)
        //        {
        //            if (!string.IsNullOrEmpty(str))
        //            {
        //                pattenStrList.Add(str);
        //            }
        //        }
        //    }
        //}

        // 参数为从bundle中加载的textAset.text
        public BadWordsReplace(string text)
        {
            var words = text.Split('\n');
            foreach (var str in words)
            {
                if (!string.IsNullOrEmpty(str))
                {
                    pattenStrList.Add(str);
                }
            }
        }

        public string Replace(string targetStr, string replaceStr)
        {
            List<string> result = new List<string>();
            foreach(string badStr in pattenStrList)
            {
                if(CTContains(targetStr, badStr))
                {
                    if (!result.Contains(badStr))
                    {
                        result.Add(badStr);
                        targetStr = Regex.Replace(targetStr, badStr, CreateReplaceString(replaceStr, badStr.Length), RegexOptions.IgnoreCase);
                    }
                }
            }
            return targetStr;
        }


        bool CTContains(string str, string toCheck, System.StringComparison comp = System.StringComparison.OrdinalIgnoreCase)
        {
            if (str == null)
                throw new System.ArgumentNullException("str");

            //if (toCheck == null)
            //    throw new System.ArgumentNullException("toCheck");

            return str.IndexOf(toCheck, comp) >= 0;
        }

        string CreateReplaceString(string replaceChars, int stringLength)
        {
            if (replaceChars.Length > 1)
            {
                char[] chars = new char[stringLength];

                for (int ii = 0; ii < stringLength; ii++)
                {
                    chars[ii] = replaceChars[rnd.Next(0, replaceChars.Length)];
                }

                return new string(chars);
            }
            else if (replaceChars.Length == 1)
            {
                return new string(replaceChars[0], stringLength);
            }

            return string.Empty;
        }

    }
}