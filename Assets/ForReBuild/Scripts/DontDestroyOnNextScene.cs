using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DontDestroyOnNextScene : MonoBehaviour
{
    bool removed = false;
    // Start is called before the first frame update
    void Awake()
    {
        DontDestroyOnLoad(gameObject);
        SceneManager.sceneLoaded += SceneManager_sceneLoaded;
    }

    private void SceneManager_sceneLoaded(Scene arg0, LoadSceneMode arg1) {
        SceneManager.MoveGameObjectToScene(gameObject, arg0);
        SceneManager.sceneLoaded -= SceneManager_sceneLoaded;
        removed = true;
    }

    private void OnDestroy() {
        if(!removed)
            SceneManager.sceneLoaded -= SceneManager_sceneLoaded;
    }
}
