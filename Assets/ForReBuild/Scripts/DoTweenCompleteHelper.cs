using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoTweenCompleteHelper : MonoBehaviour
{
    public void DoDestroy(Object gameObject) {
        if (gameObject == null) gameObject = this.gameObject;
        Destroy(gameObject);
    }
}
