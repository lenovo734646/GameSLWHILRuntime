using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using XLua;

/// <summary>
/// 金币特效
/// </summary>
[LuaCallCSharp]
public class CoinEff : MonoBehaviour
{
    private Transform thisT;
    private float jumpHeight = 0.6f;
    private float height;
    private float jumpSpeed = 3;
    private float moveSpeed;
    public int jumpCount = 2;
    private int count;  //跳跃次数
    private bool upTag;
    private bool downTag;
    private float stayTime = 0.5f;  //停留时间
    private bool isStay = true;
    public float startSpeed = 2;
    public float minSpeed = 1;  //最小速度
    public float maxSpeed = 10;  //最大速度
    public float acc = 1;
    public bool HideWhenDone = true;   //动画结束后是否隐藏
    private bool isDone = false;

    private Vector3 moveToPos;

    void Awake ()
    {
        thisT = transform;
	}
	
    public void Play(Vector3 pos, float stayTime = 1)
    {
        isDone = false;
        moveToPos = pos;
        height = 0;
        count = 0;
        upTag = true;
        downTag = false;
        moveSpeed = startSpeed;
        this.stayTime = stayTime;
        StartCoroutine(CoinStay_Cor());
    }

	void Update ()
    {
        if(isDone)
            return;
        if (count < jumpCount)
        {
            Vector3 h = Vector3.up * jumpSpeed * Time.deltaTime;
            if (upTag)
            {
                thisT.position += h;
                height += h.y;
                if (height > jumpHeight / (count + 1))
                {
                    upTag = false;
                    downTag = true;
                }
            }
            if(downTag)
            {
                thisT.position -= h;
                height -= h.y;
                if (height < 0)
                {
                    height = 0;
                    count++;
                    upTag = true;
                    downTag = false;
                }
            }
        }
        else if(isStay == false)
        {
            moveSpeed += acc;   //这里搞个加速效果
            moveSpeed = Mathf.Clamp(moveSpeed, minSpeed, maxSpeed);  //速度至少为1，不能降为0或者负数
            Vector3 pos = (moveToPos - thisT.position).normalized * moveSpeed * Time.deltaTime;
            thisT.position += pos;
            float dis = Vector2.Distance(thisT.position, moveToPos);

            if (dis < 0.001)
            {
                isDone = true;
                if (HideWhenDone)
                    ObjectPoolManager.Instance.Unspawn(thisT.gameObject);
            }
            if (dis < moveSpeed * Time.deltaTime)
                thisT.position = moveToPos;
        }
	}

    IEnumerator CoinStay_Cor()
    {
        isStay = true;
        yield return new WaitForSeconds(stayTime);
        isStay = false;
    }
}
