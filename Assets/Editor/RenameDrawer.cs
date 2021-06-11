using UnityEngine;
using UnityEditor;

[CustomPropertyDrawer(typeof(CustomEditorNameAttribute))]
public class RenameEditor : PropertyDrawer {

    //int index = 0;

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label) {
        EditorGUI.PropertyField(position, property,
            new GUIContent((attribute as CustomEditorNameAttribute).NewName));
        //index = EditorGUI.Popup(position, index, new string[] { "1","2","3"});
    }
}