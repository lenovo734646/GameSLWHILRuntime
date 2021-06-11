using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace ForReBuild {

    class NetBufferHelper {
        //int Size = 0;

        //public object locker = new object();

        public int Size {
            get;
            private set;
            //get {
            //    return Thread.VolatileRead(ref Size);
            //}

            //set
            //{
            //    Size = value;
            //}
        }

        public int LeftSize {
            get {
                return Buffer.Length - Size;
            }
        }

        public byte[] Buffer { get; }

        public NetBufferHelper(int maxSize) {
            Buffer = new byte[maxSize];
        }

        public int Receive(Socket socket) {
            if(Size == Buffer.Length) {
                throw new Exception($"NetBuffer Size == Buffer.Length Size:{Size} Buffer.Length:{Buffer.Length}");
            }
            if (Size > Buffer.Length) {
                throw new Exception($"NetBuffer Size >= Buffer.Length Size:{Size} Buffer.Length:{Buffer.Length}");
            }
            var len = socket.Receive(Buffer, Size, LeftSize, SocketFlags.None);
            Size += len;

            return len;
        }

        public bool Push(byte[] buf, int len) {
            if (len == 0) return true;
            bool b = true;
            //lock (locker) {
            if (len > LeftSize) return false;
            try {
                Array.Copy(buf, 0, Buffer, Size, len);
                Size += len;
            } catch (Exception ex) {
                Debug.LogError("NetBuffer Write " + ex.Message);
                b = false;
            }
            //}

            return b;
        }
        public void Remove(int len) {
            //lock (locker) {
            if (len > Size) {
                Debug.LogError("NetBuffer Remove len > Size len=" + len + " Size=" + Size);
                return;
            }

            try {
                Array.Copy(Buffer, len, Buffer, 0, Size - len);
                Size -= len;
            } catch (Exception ex) {
                Debug.LogError("NetBuffer Remove " + ex.Message);
            }
        }
        //}
    }
}
