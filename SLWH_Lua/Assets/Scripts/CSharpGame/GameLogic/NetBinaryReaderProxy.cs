using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

public class NetBinaryReaderProxy
{
    public ushort ModuleId { get; }
    public ushort ProtocolId { get; }
    private BinaryReader br_;

    public NetBinaryReaderProxy(BinaryReader br)
    {
        br_ = br;
        br_.BaseStream.Position = 0;
        //ModuleId = br_.ReadUInt16();
        //ProtocolId = br_.ReadUInt16();
    }

    public sbyte ReadInt8()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadSByte();
    }

    public byte ReadUInt8()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;
       
        return br_.ReadByte();
    }

    public short ReadInt16()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadInt16();
    }

    public ushort ReadUInt16()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadUInt16();
    }

    public int ReadInt32()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadInt32();
    }

    public uint ReadUInt32()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadUInt32();
    }

    public long ReadInt64()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadInt64();
    }
    
    public ulong ReadUInt64()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return 0;

        return br_.ReadUInt64();
    }

    public string ReadString()
    {
        if (br_.BaseStream.Position == br_.BaseStream.Length)
            return string.Empty;

        return System.Text.Encoding.UTF8.GetString(br_.ReadBytes(br_.ReadUInt16()));
    }

    private byte[] protobufNameBuffer_ = new byte[256];
    public string ReadPBName()
    {
        var r = string.Empty;
        try
        {
            int pos = 0;
            while (true)
            {
                byte a = br_.ReadByte();
                if (a == 0)
                    break;
                protobufNameBuffer_[pos++] = a;
            }
            r = Encoding.UTF8.GetString(protobufNameBuffer_, 0, pos);
        }
        catch
        {
            UnityEngine.Debug.LogError("无法正常读取PB协议名称");
        }
        return r;
    }

    public byte[] ReadPBContent()
    {
        int count = (int)(br_.BaseStream.Length - br_.BaseStream.Position);
        return  br_.ReadBytes(count);
    }
}
