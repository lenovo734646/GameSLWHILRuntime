using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MouseClickParticle : MonoBehaviour
{
    [SerializeField]
    public Vector3 scale = new Vector3(0.1f, 0.1f, 0.1f);
    public GameObject particlePrefab;
    GameObject go;
    ParticleSystem goParticle;
    // Start is called before the first frame update
    void Start()
    {
        go = Instantiate(particlePrefab);
        go.SetActive(false);
        goParticle = go.GetComponent<ParticleSystem>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            var mp = Input.mousePosition;
            mp.z = 10f;
            var _pos = Camera.main.ScreenToWorldPoint(mp);
            go.transform.localScale = scale;
            go.transform.position = _pos;
            go.SetActive(true);
            goParticle.Stop();
            goParticle.Play();
        }

        
    }
}
