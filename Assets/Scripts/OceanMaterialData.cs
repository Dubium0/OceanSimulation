
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
[CreateAssetMenu(fileName = "Ocean Material Data", menuName = "Ocean Simulation/Ocean Material Data")]
public class OceanMaterialData : ScriptableObject
{


    [Header("Wave Settings")]
    public List<Wave> waves = new List<Wave>();
    

    [Header("Material Settings")]
    public Color BaseColor;
    public Color SpecularColor;
    public Color AmbientColor;
    public float AmbientStrenght;
    public float SpecularPower;

 
    public delegate void OnMaterialChangeFunction();
    public OnMaterialChangeFunction OnMaterialChange;

    private void OnValidate()
    { 
        if(OnMaterialChange != null)OnMaterialChange();
    }


}
