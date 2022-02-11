using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class MaterialValueControl : MonoBehaviour
{
    public Material material;
    public string controlValueStr = "";
    public float controlValue = 0;
    public bool useInt = false;
    public bool onEnableReset = true;
    public int controlValueInt = 0;

   

    float controlValueLast = -1;
    int controlValueIntLast = -1;

    public Image image;

    string matName;

    //float controlValueO = -1;
    //int controlValueIntO = -1;
    // Start is called before the first frame update
    void Start()
    {
        //controlValueO = controlValue;
        //controlValueIntO = controlValueInt;
        if (image)
            material = image.material;
        if (material)
            matName = material.name;
    }

    // Update is called once per frame
    void Update()
    {
        if (material) {
            if (useInt && controlValueInt!= controlValueIntLast) {
                controlValueIntLast = controlValueInt;
                if (image) 
                    material = Instantiate(material);
                material.SetInt(controlValueStr,controlValueInt);
                material.name = matName;
                if (image)
                    image.material = material;
            } else {
                if (controlValue!= controlValueLast) {
                    controlValueLast = controlValue;
                    if (image)
                        material = Instantiate(material);
                    material.SetFloat(controlValueStr, controlValue);
                    material.name = matName;
                    if (image)
                        image.material = material;
                }
            }
        }
    }

    //private void OnEnable() {
    //    if (!onEnableReset) return;
    //    controlValue = controlValueO;
    //    controlValueInt = controlValueIntO;
    //    Update();
    //}
}
