using UnityEngine;

public class OceanSimulationController : MonoBehaviour
{
    public Material OceanMaterial;

    [Header("Fields")]
    public OceanMaterialData MaterialData;

    [Header("General Settings")]
    public bool EnableWave;

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
        
        
        if (OceanMaterial == null) { Debug.LogError("No material attached to Renderer!"); return; }

        Debug.Log("Updating Material Data....");
        if (EnableWave) { OceanMaterial.EnableKeyword("_ENABLE_WAVE_SIMULATION"); }
        else { OceanMaterial.DisableKeyword("_ENABLE_WAVE_SIMULATION"); };

        if (MaterialData != null)
        {
        
           


          

  



            OceanMaterial.SetColor("_DiffuseColor", MaterialData.BaseColor);
            OceanMaterial.SetColor("_AmbientColor", MaterialData.AmbientColor);
            OceanMaterial.SetColor("_SpecularColor", MaterialData.SpecularColor);


            OceanMaterial.SetFloat("_AmbientStrength", MaterialData.AmbientStrenght);
            OceanMaterial.SetFloat("_Shininess", MaterialData.SpecularPower);
            OceanMaterial.SetFloat("_WaveBufferSize", MaterialData.AmbientStrenght);

           


        }


    }



}
