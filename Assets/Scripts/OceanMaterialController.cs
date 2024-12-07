using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent (typeof(Renderer))]
public class OceanMaterialController : MonoBehaviour
{
    [Header("Fields")]
    public OceanMaterialData MaterialData;
    

    [Header("General Settings")]
    public bool EnableWave;

    [Header("Render Settings")]
    public Camera SceneCamera;
    public Light LightSource;

    

    private void OnValidate()
    {
        UpdateMaterialData();
    }
    private void Awake()
    {
        if (MaterialData != null) { MaterialData.OnMaterialChange = UpdateMaterialData; }
        UpdateMaterialData();
    }
    
    private void UpdateMaterialData()
    {
        var renderer = GetComponent<Renderer>();
        var material_ = renderer.sharedMaterial;
        if (material_ == null) { Debug.LogError("No material attached to Renderer!"); return; } 

        Debug.Log("Updating Material Data....");
        if (EnableWave) { material_.EnableKeyword("_ENABLE"); }
        else { material_.DisableKeyword("_ENABLE"); };

        if(MaterialData != null)
        {
            material_.SetFloat("_Amplitude", MaterialData.Amplitude);
            material_.SetFloat("_Wavelength", MaterialData.Wavelength);
            material_.SetFloat("_Speed", MaterialData.Speed);
            material_.SetVector("_Origin", MaterialData.Origin);

            material_.SetColor("_Base_Color",MaterialData.BaseColor);
            material_.SetColor("_Specular_Color", MaterialData.BaseColor);

            if(LightSource != null) material_.SetFloat("_Light_Intensity", LightSource.intensity);


            material_.SetFloat("_Specular_Power", MaterialData.SpecularPower);

        }


    }

}

