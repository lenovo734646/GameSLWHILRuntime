using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// 辅助设置车标
namespace SLWH
{
    [Serializable]
    public class CheBiaoData
    {
        public GameObject gameObject;
        public Material material;
        public Sprite sprite;

        public int carID;

        public CheBiaoData()
        {
            material = null;
            sprite = null;
        }
        public CheBiaoData(CheBiaoData data)
        {
            if (data != null)
            {
                gameObject = data.gameObject;
                material = data.material;
                sprite = data.sprite;
            }
        }

        public CheBiaoData(GameObject go, Material mat, Sprite spr)
        {
            gameObject = go;
            material = mat;
            sprite = spr;
        }

        // error code 就是为了解决下面这一大串的if的
        public void UpdateData()
        {
            var colorObj = gameObject.transform.Find("Color");
            if (colorObj == null)
            {
                Debug.LogError($"在{gameObject.name}中未找到子对象 Color");
                return;
            }
            var sprObj = colorObj.transform.Find("biao");
            if (sprObj == null)
            {
                Debug.LogError($"在{gameObject.name}中未找到子对象 biao");
                return;
            }
            var mat = colorObj.GetComponent<MeshRenderer>();
            if (mat == null)
            {
                Debug.LogError($"在{colorObj.name}中未找到组件 MeshRenderer");
                return;
            }
            var spr = sprObj.GetComponent<SpriteRenderer>();
            if (spr == null)
            {
                Debug.LogError($"在{sprObj.name}中未找到组件 SpriteRenderer");
                return;
            }
            colorObj.GetComponent<MeshRenderer>().material = material;
            sprObj.GetComponent<SpriteRenderer>().sprite = sprite;
            carID = int.Parse(sprite.name);
        }

    }


    public class CheBiaoHelper : MonoBehaviour
    {
        [SerializeField]
        public GameObject chebiaoRoot;
        [SerializeField]
        public GameObject[] chebiaoGameObjects;
        [SerializeField]
        public Material[] colorMaterials;
        [SerializeField]
        public Sprite[] chebiaoSprites;

        [SerializeField]
        public List<CheBiaoData> chebiaoList;

        public string[] GetColorMaterialNames()
        {
            return new string[] { "银色", "金色" };
        }

        public string[] GetCheBiaoNames()
        {
            return new string[] { "保时捷", "法拉利", "玛莎拉蒂", "兰博基尼", "奔驰", "宝马", "路虎", "捷豹" };
        }

        public int GetColorMaterialIndex(Material mat)
        {
            return GetIndex(colorMaterials, mat);
            //if(colorMaterials != null && colorMaterials.Length > 0)
            //{
            //    for(var i = 0; i < colorMaterials.Length; i ++)
            //    {
            //        if (colorMaterials[i] = mat)
            //            return i;
            //    }
            //    Debug.LogError("colorMaterials 中不存在所选mat");
            //}
            //return -1;
        }

        public int GetChebiaoSpriteIndex(Sprite spr)
        {
            return GetIndex(chebiaoSprites, spr);
        }

        private int GetIndex<T>(T[] array, T target)
        {
            if (array != null && array.Length > 0)
            {
                for (var i = 0; i < array.Length; i++)
                {
                    if (System.Object.Equals(array[i], target))
                        return i;
                }
                Debug.LogError("colorMaterials 中不存在所选mat");
            }
            return -1;

        }
    }


}