using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG;
using DG.Tweening;

public class ChouMaFly : MonoBehaviour
{
    [Tooltip("使用localPosition作为结束点,使用localEularAngle作为随机偏移量,使用srcPos作为起始点，做X轴和Z轴Move动画,Y轴使用重力控制")]
    public List<Transform> srcPosList;
    public List<Transform> dstPosList;
    public GameObject chouMaPrefab;
    //
    public float fallFactor = 0.5f;
    public float mulity = 2.0f;
    public float duration = 1.0f;

    private Vector3 srcPos;
    private Vector3 dstPos;
    private Vector3 dstOffset;

    public List<GameObject> chouMaList;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    Vector3 GetSrcPos()
    {
        var index = Random.Range(0, srcPosList.Count);
        var tPos = srcPosList[index].localPosition;
        var tOffset = srcPosList[index].localEulerAngles;
        Vector3 offset = new Vector3(Random.Range(-tOffset.x, tOffset.x), 0, Random.Range(-tOffset.z, tOffset.z));
        return tPos + offset;
    }

    Vector3 GetDstPos(int targetPosIndex)
    {
        var tPos = dstPosList[targetPosIndex].localPosition;
        var tOffset = dstPosList[targetPosIndex].localEulerAngles;
        Vector3 offset = new Vector3(Random.Range(-tOffset.x, tOffset.x), 0, Random.Range(-tOffset.z, tOffset.z));
        return tPos + offset;
    }

    //private void OnGUI()
    //{
    //    if (GUI.Button(new Rect(10, 10, 100, 50),"Test"))
    //    {
    //        for (var i = 0; i < 10; i++)
    //        {
    //            srcPos = GetSrcPos();
    //            dstPos = GetDstPos(Random.Range(0, dstPosList.Count));
    //            var dur = duration + Random.Range(-0.2f, 0.2f);
    //            //
    //            var go = Instantiate(chouMaPrefab, gameObject.transform);
    //            go.SetActive(false);
    //            go.transform.localPosition = srcPos;
    //            go.transform.GetComponent<Rigidbody>().drag = 50;
    //            go.SetActive(true);
    //            go.transform.DOLocalMoveX(dstPos.x, dur).SetEase(Ease.OutCirc);
    //            go.transform.DOLocalMoveZ(dstPos.z, dur).SetEase(Ease.OutCirc);
    //            StartCoroutine(CalDrag(go.transform, srcPos, dstPos));
    //        }
    //    }
    //}

    IEnumerator CalDrag(Transform t, Vector3 srcPos, Vector3 dstPos)
    {
        while(true)
        {
            
            var disPer = Vector3.Distance(t.localPosition, dstPos) / Vector3.Distance(srcPos, dstPos);
            var rigid = t.GetComponent<Rigidbody>();
            if(disPer < fallFactor)
            {
                rigid.drag = rigid.drag * disPer* mulity;
                //print("disPer = " + disPer + "  rigid.drag = " + rigid.drag);
                if (rigid.drag <= 0.1)
                    break;
            }
            print("drag  = " + t.GetComponent<Rigidbody>().drag);
            yield return new WaitForEndOfFrame();
        }
        yield break;
    }
}


