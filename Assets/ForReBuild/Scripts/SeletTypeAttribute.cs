using UnityEngine;

public class SeletTypeAttribute : PropertyAttribute {
    public string NewName { get; private set; }
    public SeletTypeAttribute(string name) {
        NewName = name;
    }
    public SeletTypeAttribute() {
    }
}