using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using static ForReBuild.BundleInfo;

namespace ForReBuild {
    public class BundleRecycler : MonoBehaviour {

        public static BundleRecycler Instance { get; private set; }

        public static byte[] key = Encoding.UTF8.GetBytes("ABCDEFGHIJKLMN0123456789");

        public static bool showLog = true;

        class ABRefCounter {
            public string FullPath { get; private set; }
            public AssetBundle AssetBundle { get; private set; }

            public int refCount = 1;
            public ABRefCounter(AssetBundle ab, string fullpath) {
                AssetBundle = ab;
            }
        }

        static Dictionary<string, ABRefCounter> AbCacheMap { get; } = 
            new Dictionary<string, ABRefCounter>();

        public bool HasAsset(string fullpath) {
            return AbCacheMap.ContainsKey(fullpath);
        }
        public AssetBundle GetAB(string fullpath) {
            ABRefCounter aBRefCounter;
            if (!AbCacheMap.TryGetValue(fullpath, out aBRefCounter)) {
                var assetBundle = LoadFromFile(fullpath);
                aBRefCounter = new ABRefCounter(assetBundle,fullpath);
                AbCacheMap.Add(fullpath, aBRefCounter);
            }
            aBRefCounter.refCount++;
            if (showLog) {
                Debug.Log($"GetAB refCount:{aBRefCounter.refCount} fullpath:{fullpath}");
            }
            return aBRefCounter.AssetBundle;
        }

        public void GetABAsync(string fullpath, Action<AssetBundle> action) {
            ABRefCounter aBRefCounter;
            if (!AbCacheMap.TryGetValue(fullpath, out aBRefCounter)) {
                StartCoroutine(cLoad(fullpath, action));
            } else {
                aBRefCounter.refCount++;
                if (showLog) {
                    Debug.Log($"GetABAsync refCount:{aBRefCounter.refCount} fullpath:{fullpath}");
                }
                action(aBRefCounter.AssetBundle);
            }
        }

        public static byte[] fck(string fullpath) {
            byte[] filedata = File.ReadAllBytes(fullpath);
            int DecLen = 1024 + 16;
            if (filedata.Length < 1024) {
                DecLen = filedata.Length;
            }
            byte[] needDecData = new byte[DecLen];
            Array.Copy(filedata, needDecData, DecLen);

            byte[] decryptBytes = UnityHelper.fck(needDecData, key); //解密  
            Array.Copy(decryptBytes, filedata, DecLen);

            byte[] aDecData = new byte[filedata.Length - 16];
            Array.Copy(decryptBytes, 0, aDecData, 0, DecLen - 16);
            Array.Copy(filedata, DecLen, aDecData, DecLen - 16, filedata.Length - DecLen);
            return aDecData;
        }

        AssetBundle LoadFromFile(string fullpath) {
#if DEV_VER
            if (fullpath.EndsWith(".bundleEnc")) {
                return AssetBundle.LoadFromMemory(fck(fullpath));
            }
            return AssetBundle.LoadFromFile(fullpath);
#else
            return AssetBundle.LoadFromMemory(fck(fullpath));
#endif

        }


        class LoadFromFileAsyncReq : CustomYieldInstruction {
            public override bool keepWaiting { get {
                    if (ab != null) return false;
                    if (req == null) return true;
                    if (failed) return false;
                    return !req.isDone;
                } }

            public AssetBundle assetBundle { get => ab==null? (req==null?null:req.assetBundle) : ab; }

            bool failed = false;
            AssetBundle ab = null;
            AssetBundleCreateRequest req = null;
            public LoadFromFileAsyncReq(string fullpath) {
                if (fullpath.EndsWith(".bundleEnc")) {
                    loadFromFile(fullpath);
                } else {
                    req = AssetBundle.LoadFromFileAsync(fullpath);
                }
            }

            async void loadFromFile(string fullpath) {
                var bytes = await Task.Run(()=> {
                    try {
                       return fck(fullpath);
                    } catch (Exception ex) {
                        Debug.LogError("DecryptFile error:" + ex);
                    }
                    return null;
                });
                if (bytes != null)
                    ab = AssetBundle.LoadFromMemory(bytes);
                else
                    failed = true;
            }
        }

        IEnumerator cLoad(string fullpath, Action<AssetBundle> action) {
            var req = new LoadFromFileAsyncReq(fullpath);
            yield return req;
            var aBRefCounter = new ABRefCounter(req.assetBundle, fullpath);
            AbCacheMap.Add(fullpath, aBRefCounter);
            action(req.assetBundle);
            if (showLog) {
                Debug.Log($"cLoad refCount:{aBRefCounter.refCount} fullpath:{fullpath}");
            }
        }



        void doRecycle(AssetInfo assetInfo) {
            if (AbCacheMap.TryGetValue(assetInfo.fullpath, out ABRefCounter aBRefCounter)) {
                aBRefCounter.refCount--;
                if (aBRefCounter.refCount == 0 || assetInfo.recycleForce) {
                    AbCacheMap.Remove(assetInfo.fullpath);
                    aBRefCounter.AssetBundle.Unload(true);
                    assetInfo.isUnload = true;
                    if (showLog) {
                        Debug.Log($"资源释放 Force:{assetInfo.recycleForce}\nfullpath:{assetInfo.fullpath}");
                    }
                }
            } else {
                Debug.LogError($"重复释放! Force:{assetInfo.recycleForce}\nfullpath:{assetInfo.fullpath}");
            }
        }

        IEnumerator cDoRecycle(AssetInfo assetInfo) {
            yield return new WaitForSeconds(assetInfo.recycleDelay);
            doRecycle(assetInfo);
        }

        private void Awake() {
            Instance = this;
            MessageCenter.Instance.AddListener("BundleInfoGC",msg=> {
                var assetInfo = msg.Sender as AssetInfo;
                if (assetInfo.recycleDelay <= 0) {
                    doRecycle(assetInfo);
                } else {
                    StartCoroutine(cDoRecycle(assetInfo));
                }
            });
        }
    }
}
