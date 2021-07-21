using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace QL.Core
{
    /// <summary>
    /// 常量类
    /// </summary>
    public sealed class QLConstants
    {
        /// <summary>
        /// 时间格式
        /// </summary>
        public static string DATE_TIME_FORMAT = "yyyy-MM-dd HH:mm:ss";
        /// <summary>
        /// 签名方式
        /// </summary>
        public static string SIGN_METHOD_MD5 = "md5";
        /// <summary>
        /// Http请求头参数
        /// </summary>
        public static string ACCEPT_ENCODING = "Accept-Encoding";
        /// <summary>
        /// 压缩方式
        /// </summary>
        public static string CONTENT_ENCODING_GZIP = "gzip";
        /// <summary>
        /// 错误回应根节点名称
        /// </summary>
        public static string ERROR_RESPONSE = "error_response";
        /// <summary>
        /// 错误码字段名
        /// </summary>
        public static string ERROR_CODE = "code";
        /// <summary>
        /// 错误描述字段名称
        /// </summary>
        public static string ERROR_MSG = "msg";
    }
}
