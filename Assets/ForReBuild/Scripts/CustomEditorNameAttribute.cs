using UnityEngine;

public class CustomEditorNameAttribute : PropertyAttribute {
    public string NewName { get; private set; }
    public CustomEditorNameAttribute(string name) {
        NewName = name;
    }
}