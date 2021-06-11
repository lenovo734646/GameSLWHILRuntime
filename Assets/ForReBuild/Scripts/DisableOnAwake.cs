using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisableOnAwake : MonoBehaviour
{

    public bool doOnStart = true;
    public bool doOnTheEndOfFrame = false;
    private void Awake() {
        if(!doOnStart)
            gameObject.SetActive(false);    
    }

    // Start is called before the first frame update
    IEnumerator Start()
    {
        if (doOnStart) {
            if (doOnTheEndOfFrame) {
                yield return new WaitForEndOfFrame();
                gameObject.SetActive(false);
            } else {
                gameObject.SetActive(false);
            }
        }
    }
}
