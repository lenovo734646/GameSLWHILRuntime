using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyOnEndOfFrame : MonoBehaviour
{
    // Start is called before the first frame update
    IEnumerator Start()
    {
        yield return new WaitForEndOfFrame();
        Destroy(gameObject);
    }

    
}
