using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;
using Object = UnityEngine.Object;

namespace ForReBuild {
    public class BundleInfo {

        public bool IsUnloaded{ get => Info.isUnload; }
        public AssetInfo Info { get;} = new AssetInfo();

        public float RecycleDelay { get {
                return Info.recycleDelay;
            }
            set {
                Info.recycleDelay = value;
            }
        }

        public class AssetInfo {
            public AssetBundle assetBundle;
            public string fullpath;
            public float recycleDelay = 0;
            public bool recycleForce = false;
            public bool isUnload = false;
        }

        private BundleInfo() { }

        ~BundleInfo() {
            if(!Info.isUnload)
                MessageCenter.Instance.PostMessage(new Message("BundleInfoGC", Info));
        }

        public static BundleInfo LoadFromFile(string fullpath, bool rawPath = true) {
            if (!rawPath) {
                fullpath = SysDefines.AB_BASE_PATH + fullpath;
            }
            var assetBundle = BundleRecycler.Instance.GetAB(fullpath);
            var bundleInfo = new BundleInfo();
            bundleInfo.Info.assetBundle = assetBundle;
            bundleInfo.Info.fullpath = fullpath;
            if (assetBundle == null) {
                Debug.LogError("can not load  "+ fullpath);
            }
            return bundleInfo;
        }

        public class WaitLoadFromFile : CustomYieldInstruction {
            public override bool keepWaiting => !ok;

            bool ok = false;
            public BundleInfo bundleInfo;

            public WaitLoadFromFile(string fullpath, bool rawPath = true) {
                if (!rawPath) {
                    fullpath = SysDefines.AB_BASE_PATH + fullpath;
                }
                BundleRecycler.Instance.GetABAsync(fullpath, ab => {
                    bundleInfo = new BundleInfo();
                    bundleInfo.Info.fullpath = fullpath;
                    bundleInfo.Info.assetBundle = ab;
                    ok = true;
                });
            }
        }

        public T LoadAsset<T>(string name) where T : Object {
            return Info.assetBundle.LoadAsset<T>(name);
        }

        public Object LoadAsset(string name, bool rawPath = false) {
            if (!rawPath) {
                name = SysDefines.AB_BASE_PATH + name;
            }
            if (Info == null) {
                Debug.LogError("Info == null");
                return null;
            }
            if (Info.assetBundle == null) {
                Debug.LogError("Info.assetBundle == null");
                return null;
            }
            return Info.assetBundle.LoadAsset(name);
        }

        public Object LoadAsset(string name, Type type, bool rawPath = false) {
            if (!rawPath) {
                name = SysDefines.AB_BASE_PATH + name;
            }
            return Info.assetBundle.LoadAsset(name, type);
        }

        public Object[] LoadAssetWithSubAssets(string name, Type type, bool rawPath = false) {
            if (!rawPath) {
                name = SysDefines.AB_BASE_PATH + name;
            }
            return Info.assetBundle.LoadAssetWithSubAssets(name, type);
        }

        public void Unload() {
            if (Info.isUnload) return;
            Info.recycleForce = true;
            MessageCenter.Instance.SendMessage(new Message("BundleInfoGC", Info));
        }

        public AssetBundleRequest LoadAssetAsync(string name, Type type=null, bool rawPath = false) {
            if (!rawPath) {
                name = SysDefines.AB_BASE_PATH + name;
            }
            if (type == null)
                return Info.assetBundle.LoadAssetAsync(name);
            else
                return Info.assetBundle.LoadAssetAsync(name, type);
        }

        public string[] GetAllAssetNames() {
            return Info.assetBundle.GetAllAssetNames();
        }
    }
}
