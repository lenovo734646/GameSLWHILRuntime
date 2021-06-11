using System;
using UnityEditor;
using UnityEngine;

using Object = UnityEngine.Object;

public static class EditorWindowUtil
{
    //This method finds the first EditorWindow that's open, and is of the given type.
    //For example, this is how we can search for the "SceneHierarchyWindow" that's currently open (hopefully it *is* actually open).
    public static EditorWindow FindFirst(Type editorWindowType)
    {
        if (editorWindowType == null)
            throw new ArgumentNullException(nameof(editorWindowType));
        if (!typeof(EditorWindow).IsAssignableFrom(editorWindowType))
            throw new ArgumentException("The given type (" + editorWindowType.Name + ") does not inherit from " + nameof(EditorWindow) + ".");

        Object[] openWindowsOfType = Resources.FindObjectsOfTypeAll(editorWindowType);
        if (openWindowsOfType.Length <= 0)
            return null;

        EditorWindow window = (EditorWindow)openWindowsOfType[0];
        return window;
    }

    //Works with prefab modifications, AND added GameObjects/Components!
    //The PrefabUtility API does not have a method that does this as of Unity 2020.1.3f1 (August 24, 2020). For shame.
    public static GameObject DuplicatePrefabInstance(GameObject prefabInstance)
    {
        Object[] previousSelection = Selection.objects;
        Selection.objects = new Object[] { prefabInstance };
        Selection.activeGameObject = prefabInstance;

        //For performance, you might want to cache this Reflection:
        Type hierarchyViewType = Type.GetType("UnityEditor.SceneHierarchyWindow, UnityEditor");
        EditorWindow hierarchyView = EditorWindowUtil.FindFirst(hierarchyViewType);

        //Using the Unity Hierarchy View window, we can duplicate our selected objects!
        hierarchyView.SendEvent(EditorGUIUtility.CommandEvent("Duplicate"));

        GameObject clone = Selection.activeGameObject;
        Selection.objects = previousSelection;
        return clone;
    }
}
