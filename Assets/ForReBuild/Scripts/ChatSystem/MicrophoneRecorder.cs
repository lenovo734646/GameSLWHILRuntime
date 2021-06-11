using System;
using System.Collections;
using System.IO;
using System.IO.Compression;
using UnityEngine;
using UnityEngine.UI;

namespace SP
{

    /// <summary>
    /// 语音识别音频可视化
    /// </summary>
    public class MicrophoneRecorder : MonoBehaviour
    {
        public GameObject voiceWavePrefab;
        public GameObject VWGridGroup;

        [SerializeField]
        public int voiceWaveStep = 5; // 每个voice wave 代表的取样点个数 //取样间隔

        public Slider slider;   // 录制时间进度条
        public Text timeText;
        private float curRecordingTime;
        //
        private Image[] waveImageGroup;
        private AudioSource micRecord;

        private int recordingMaxTime = 60;
        private int freq = 44100;
        private string device;
        private bool isRecording = false;

        // 回放
        public WaveFormDraw wfDraw;
        private bool isPlaybacking = false;

        public GameObject voiceInputPanel;
        //
        private int headerSize = 44; //default for uncompressed wav
        private float outputVol = 0.65f;
        private int clipChannels = 1;
        private bool recOutput;
        void Start()
        {
            if (Microphone.devices.Length <= 0)
            {
                Debug.LogError("未检测到麦克风输入设备");
                return;
            }

            micRecord = GetComponent<AudioSource>();
            if (micRecord == null)
            {
                Debug.LogError("micRecord Audio Source is null");
                return;
            }
            //
            device = Microphone.devices[0];
            int minFreq, maxFreq;
            Microphone.GetDeviceCaps(null, out minFreq, out maxFreq);
            if (minFreq > 0) // 等于0时表示支持任意采样率
                freq = minFreq;
            print("min = " + minFreq + "  max = " + maxFreq + "  AudioSettings.outputSampleRate = " + AudioSettings.outputSampleRate);


            //
            waveImageGroup = new Image[26];
            for (var i = 0; i < 26; i++)
            {
                var go = Instantiate(voiceWavePrefab, VWGridGroup.transform);
                go.transform.localScale = Vector3.zero;
                waveImageGroup[i] = go.GetComponent<Image>();
            }
            voiceInputPanel.SetActive(false);

            slider.gameObject.SetActive(false);
            VWGridGroup.SetActive(false);
            wfDraw.gameObject.SetActive(false);


            
        }


        IEnumerator RecordingTimeCounter()
        {
            timeText.text = "0:00";
            while(curRecordingTime < recordingMaxTime)
            {
                yield return new WaitForSeconds(1);
                curRecordingTime += 1;
                string minutes = Mathf.Floor(curRecordingTime / 60).ToString("0");
                string seconds = (curRecordingTime % 60).ToString("00");
                timeText.text = minutes + ":" + seconds;
                slider.value = curRecordingTime;
            }
            // 录制时间到 自动停止录音
            print("recording time over auto stop");
            StopRecording();
        }

        public void StartRecording(int time)
        {
            if (isPlaybacking)
                StopPlayback();
            //
            if (!isRecording)
            {
                voiceInputPanel.SetActive(true);
                wfDraw.gameObject.SetActive(false);
                VWGridGroup.SetActive(true);
                slider.gameObject.SetActive(true);
                slider.minValue = 0;
                slider.maxValue = time;
                slider.value = 0;
                curRecordingTime = 0;
                StartCoroutine(RecordingTimeCounter());
                //
                isRecording = true;
                recordingMaxTime = time;
                micRecord.clip = Microphone.Start(device, true, recordingMaxTime, freq);
            }
            else
            {
                StopRecording();
            }

        }

        public void StopRecording()
        {
            if (isRecording)
            {
                wfDraw.gameObject.SetActive(true);
                VWGridGroup.SetActive(false);
                slider.gameObject.SetActive(false);
                slider.value = 0; 
                StopAllCoroutines();
                //
                isRecording = false;
                int timeSinceStart = Microphone.GetPosition("");
                if (timeSinceStart == 0)
                {
                    Debug.Log("Recording length = 0? -> not a long enough recording to process");
                    return;
                }
                Microphone.End(device);
                float[] recordedClip = new float[micRecord.clip.samples * micRecord.clip.channels];
                micRecord.clip.GetData(recordedClip, 0);
                TrimSilenceData(recordedClip, timeSinceStart); // 此函数给micRecord.clip重新赋值，剪除了多余的静音部分
                wfDraw.StartWaveFormGeneration(micRecord.clip);
                //
            }
        }

        public void StartPlayback()
        {
            if (isPlaybacking)
                return;
            if (isRecording)
                StopRecording();

            isPlaybacking = true;
            micRecord.Play();
            print("回放开始....");
        }

        public void StopPlayback()
        {
            if (isPlaybacking == false)
                return;
            isPlaybacking = false;
            micRecord.Stop();
            wfDraw.playbackSli.value = 0;
            print("回放结束....");
        }

        public void CancelRecording()
        {
            if (isRecording)
                StopRecording();
            if (isPlaybacking)
                StopPlayback();
            // reset
            for (var i = 0; i < waveImageGroup.Length; i++)
            {
                waveImageGroup[i].transform.localScale = Vector3.zero;
            }
            micRecord.clip = null;
            voiceInputPanel.SetActive(false);
        }

        public byte[] GetSendDataBuff()
        {
            if (isPlaybacking)
                StopPlayback();
            if (isRecording)
                StopRecording();
            if (micRecord == null || micRecord.clip == null)
                return null;
            return ClipToByte(micRecord.clip);
        }


        // 返回使用GZip压缩过的byte数组
        private byte[] ClipToByte(AudioClip clip)
        {
            float[] clipArray = new float[clip.samples * clip.channels];
            clip.GetData(clipArray, 0);

            // 方案1
            byte[] bytes = new byte[clipArray.Length * 4];
            Buffer.BlockCopy(clipArray, 0, bytes, 0, bytes.Length);
            try
            {
                var wms = new MemoryStream();
                var zip = new GZipStream(wms, CompressionMode.Compress);
                zip.Write(bytes, 0, bytes.Length);
                zip.Close();

                byte[] compressBytes = wms.ToArray();

                print($"压缩前：{bytes.Length}   压缩后：{compressBytes.Length}");
                return compressBytes;
            }
            catch (Exception e)
            {
                Debug.LogError("VoiceToByte Error " + e.Message);
            }

            // 方案3
            //WavUtility.FromAudioClip(clip);

            return null;
        }

        public AudioClip ByteToAudioClip(byte[] data)
        {
            if (isPlaybacking)
                StopPlayback();
            if (isRecording)
                StopRecording();
            //
            if(data == null)
            {
                Debug.LogError("ByteToClip data is null");
                return null;
            }
            
            try
            {
                var dms = new MemoryStream();
                var wms = new MemoryStream(data);
                var zip = new GZipStream(wms, CompressionMode.Decompress);
                var count = 0;
                byte[] tempdata = new byte[4096];
                while ((count = zip.Read(tempdata, 0, tempdata.Length)) != 0)
                {
                    dms.Write(tempdata, 0, count);
                }
                byte[] decompressBytes = dms.ToArray();
                zip.Close();

                

                print($"解压前：{data.Length}   解压后：{decompressBytes.Length} ");

                float[] clipdata = new float[decompressBytes.Length / 4];
                Buffer.BlockCopy(decompressBytes, 0, clipdata, 0, decompressBytes.Length);
                //
                AudioClip newClip = AudioClip.Create(clipdata.Length.ToString(), clipdata.Length / clipChannels, clipChannels, freq, false);
                newClip.SetData(clipdata, 0);
                return newClip;
            }
            catch (Exception e)
            {
                Debug.LogError("OnReceiveVoice Decompress Error " + e.Message);
            }
            return null;
        }

        // 剪除静音部分,并生成新的clip替换掉原来的clip
        public void TrimSilenceData(float[] clipArray_, int timeSinceStart_)
        {
            float[] shortenedClip = new float[timeSinceStart_];
            float[] newClipData = new float[timeSinceStart_];
            Array.Copy(clipArray_, shortenedClip, shortenedClip.Length - 1);
            int validCount = 0;
            for (int i = 0; i < shortenedClip.Length; i++)
            {
                float temp = shortenedClip[i] * freq * outputVol;
                if (temp >= Int16.MinValue && temp <= Int16.MaxValue)
                {
                    newClipData[validCount++] = shortenedClip[i];
                }
            }
            //
            print("validCount= "+ validCount);
            var clip = micRecord.clip;
            AudioClip newClip = AudioClip.Create(clip.name, validCount / clip.channels, clip.channels, freq, false);
            newClip.SetData(newClipData, 0);
            micRecord.clip = newClip;
        }

        public void SaveToFile(float[] shortenedClip)
        {
            FileStream fileStream;
            fileStream = new FileStream(Application.persistentDataPath + "/" + "Recording" + ".wav", FileMode.Create);
            byte emptyByte = new byte();
            for (int i = 0; i < headerSize; i++) //preparing the header 
            {
                fileStream.WriteByte(emptyByte);
            }
            //
            for (int i = 0; i < shortenedClip.Length; i++)
            {
                float temp = shortenedClip[i] * freq * outputVol;
                if (temp >= Int16.MinValue && temp <= Int16.MaxValue)
                {
                    byte[] temp2 = BitConverter.GetBytes(Convert.ToInt16(temp));
                    fileStream.Write(temp2, 0, temp2.Length);
                }
            }
            FinishWritingFile(fileStream, freq, 1);
        }

        private void FinishWritingFile(FileStream fileStream, int outputRate, int channels)
        {
            fileStream.Seek(0, SeekOrigin.Begin);
            byte[] riff = System.Text.Encoding.UTF8.GetBytes("RIFF");
            fileStream.Write(riff, 0, 4);
            byte[] chunkSize = BitConverter.GetBytes(fileStream.Length - 8);
            fileStream.Write(chunkSize, 0, 4);
            byte[] wave = System.Text.Encoding.UTF8.GetBytes("WAVE");
            fileStream.Write(wave, 0, 4);
            byte[] fmt = System.Text.Encoding.UTF8.GetBytes("fmt ");
            fileStream.Write(fmt, 0, 4);
            byte[] subChunk1 = BitConverter.GetBytes(16);
            fileStream.Write(subChunk1, 0, 4);
            ushort two = 2;
            ushort one = 1;
            byte[] audioFormat = BitConverter.GetBytes(one);
            fileStream.Write(audioFormat, 0, 2);
            byte[] numChannels = BitConverter.GetBytes(two);
            if (channels == 2)
            {
                numChannels = BitConverter.GetBytes(two);
            }
            else if (channels == 1)
            {
                numChannels = BitConverter.GetBytes(one);
            }
            else
            {//should we try to support 8 channels and change this to a case switch satement? or just support two?
                numChannels = BitConverter.GetBytes(two);
            }

            fileStream.Write(numChannels, 0, 2);
            byte[] sampleRate = BitConverter.GetBytes(outputRate);
            fileStream.Write(sampleRate, 0, 4);
            byte[] byteRate = BitConverter.GetBytes(outputRate * 4);
            // sampleRate * bytesPerSample*number of channels, here 44100*2*2
            fileStream.Write(byteRate, 0, 4);
            ushort four = 4;
            byte[] blockAlign = BitConverter.GetBytes(four);
            fileStream.Write(blockAlign, 0, 2);
            ushort sixteen = 16;
            byte[] bitsPerSample = BitConverter.GetBytes(sixteen);
            fileStream.Write(bitsPerSample, 0, 2);
            byte[] dataString = System.Text.Encoding.UTF8.GetBytes("data");
            fileStream.Write(dataString, 0, 4);
            byte[] subChunk2 = BitConverter.GetBytes(fileStream.Length - headerSize);
            fileStream.Write(subChunk2, 0, 4);
            fileStream.Close();
        }


        void Update()
        {
            //print(Microphone.GetPosition(device)+"   dt = "+Time.deltaTime);
            if (isRecording)
                GetMaxVolume();

            if(isPlaybacking) // 回放
            {
                if (micRecord == null || micRecord.clip == null)
                    return;
                wfDraw.playbackSli.value = micRecord.timeSamples * micRecord.clip.channels;
                if (micRecord.isPlaying == false)
                {
                    StopPlayback();
                }
            }
        }
        /// <summary>
        /// 每一振处理那一帧接收的音频文件
        /// </summary>
        /// <returns></returns>
        float GetMaxVolume()
        {
            float maxVolume = 0f;
            //剪切音频
            float[] volumeData = new float[128];
            int offset = Microphone.GetPosition(device) - 128 + 1; // 获取128个长度的音频数据
            if (offset < 0)
            {
                return 0;
            }
            micRecord.clip.GetData(volumeData, offset);

            for (int i = 0; i < 128; i++)
            {
                //float tempMax = volumeData[i];//修改音量的敏感值
                //这个if是用来取记录的音频的一部分   和你所加的物体有关
                //这块取余除以几，场景中长方体的个数就是这个数的倍数
                if (i % voiceWaveStep == 0)
                {
                    int f = i / voiceWaveStep;
                    //将可视化的物体和音波相关联
                    //obj[f].gameObject.transform.localScale = new Vector3(0.3f, volumeData[i] * 10 + 0.2f, 0.1f);//将可视化的物体和音波相关联
                    var sy = Mathf.Clamp(volumeData[i] * 10, -1.5f, 1.5f);
                    waveImageGroup[f].rectTransform.localScale = new Vector3(1f, sy, 1f);
                }
            }
            return maxVolume;
        }
    }
}