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
        public int ID;

        public CheBiaoData()
        {
            gameObject = null;
            ID = 0;
        }
        public CheBiaoData(CheBiaoData data)
        {
            if (data != null)
            {
                gameObject = data.gameObject;
                ID = data.ID;
            }
        }

        public CheBiaoData(GameObject go, int id)
        {
            gameObject = go;
            ID = id;
        }

        // error code 就是为了解决下面这一大串的if的
        public void UpdateData(int id)
        {
            ID = id;
         
        }
    }


    public class CheBiaoHelper : MonoBehaviour
    {
        [SerializeField]
        public GameObject chebiaoRoot;
        [SerializeField]
        public GameObject[] chebiaoGameObjects;
        [SerializeField]
        public GameObject[] animalPrefabs;

        [SerializeField]
        public List<CheBiaoData> chebiaoList;

        public LuaInitHelper winStageInitHelper;

        //
        string[]AnimalNames = { "狮子", "熊猫", "猴子", "兔子"};

    public string[] GetColorMaterialNames()
        {
            return new string[] { "红色", "黄色", "绿色" };
        }

        public string[] GetCheBiaoNames()
        {
            return AnimalNames;
        }

        public int GetAnimalPrefabIndex(GameObject prefab)
        {
            for(var i = 0; i < AnimalNames.Length; i ++)
            {
                if (prefab.tag.Contains(AnimalNames[i]))
                    return i;
            }
            Debug.LogError("prefab 不存在: "+prefab.name);
            return -1;
            //return GetIndex(animalPrefabs, prefab);
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
                Debug.LogError("target 不存在");
            }
            return -1;

        }
    }


}