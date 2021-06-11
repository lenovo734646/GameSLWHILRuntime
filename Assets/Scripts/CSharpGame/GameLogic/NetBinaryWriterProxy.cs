using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using XLua;

public class NetBinaryWriterProxy
{
    private MemoryStream ms_;
    private BinaryWriter bw_;

    public NetBinaryWriterProxy(int mid, int pid)
    {
        ms_ = new MemoryStream();
        bw_ = new BinaryWriter(ms_);
        bw_.Write((int)0);
        bw_.Write((UInt16)mid);
        bw_.Write((UInt16)pid);
    }

    public NetBinaryWriterProxy() {
        ms_ = new MemoryStream();
        bw_ = new BinaryWriter(ms_);
        bw_.Write((int)0);
    }

    public void Send()
    {
        ms_.Seek(0, SeekOrigin.Begin);
        bw_.Write((int)ms_.Length);
        NetController.Instance.netComponent.Send(ms_);
    }

    public void WriteInt8(sbyte value)
    {
        bw_.Write(value);
    }

    public void WriteUInt8(byte value)
    {
        bw_.Write(value);
    }

    public void WriteInt16(short value)
    {
        bw_.Write(value);
    }

    public void WriteUInt16(ushort value)
    {
        bw_.Write(value);
    }

    public void WriteInt32(int value)
    {
        bw_.Write(value);
    }

    public void WriteUInt32(uint value)
    {
        bw_.Write(value);
    }

    public void WriteInt64(long value)
    {
        bw_.Write(value);
    }
    
    public void WriteUInt64(ulong value)
    {
        bw_.Write(value);
    }

    //public void WriteString(string value, int maxLength)
    //{
    //    JBPROTO.NetHelper.SafeWriteString(bw_, value, maxLength);
    //}

    public void WriteString(string str) 
    {
        //UnityEngine.Debug.LogError(" WriteString : "+str);

        bw_.Write(Encoding.UTF8.GetBytes(str));
    }

    public void WriteBytes(byte[] bytes) 
    {
        bw_.Write(bytes);
    }
    

}
