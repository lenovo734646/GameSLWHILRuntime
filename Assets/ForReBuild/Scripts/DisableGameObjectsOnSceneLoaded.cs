using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class DisableGameObjectsOnSceneLoaded : MonoBehaviour
{
    public List<GameObject> gameObjects;
    [CustomEditorName("WaitForEndFrame(开启时,Delay Second不生效)")]
    public bool waitForEndFrame = true;
    public float delaySecond = 0.1f;
    public UnityEvent @event;
    private void Awake() {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    private void OnDestroy() {
        SceneManager.sceneLoaded -= OnSceneLoaded;
        @event.RemoveAllListeners();
    }

    private void OnSceneLoaded(Scene arg0, LoadSceneMode arg1) {
        StartCoroutine(cDoDisable());
    }

    IEnumerator cDoDisable() {
        if (waitForEndFrame) {
            yield return new WaitForEndOfFrame();
        } else {
            yield return new WaitForSeconds(delaySecond);
        }
        foreach(var go in gameObjects) {
            go.SetActive(false);
        }
        @event?.Invoke();
    }
}
