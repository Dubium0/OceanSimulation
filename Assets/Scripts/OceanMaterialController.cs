using UnityEngine;
using UnityEngine.Rendering;
using static OceanMaterialData;

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
            material_.DisableKeyword("_WAVE_MODE_DEFAULT");
            material_.DisableKeyword("_WAVE_MODE_SINUSODIAL");
            material_.DisableKeyword("_WAVE_MODE_STEEP_SINUSODIAL");
            material_.DisableKeyword("_WAVE_MODE_NICE_PEEK"); 
            switch (MaterialData.waves[0].WaveType)
            {
                
                case WaveTypes.Default:
                    material_.EnableKeyword("_WAVE_MODE_DEFAULT");
                   
                    break;
                case WaveTypes.Sinusodial:
                    material_.EnableKeyword("_WAVE_MODE_SINUSODIAL");

                    break;
                case WaveTypes.SteepSinusodial:
                    material_.EnableKeyword("_WAVE_MODE_STEEP_SINUSODIAL");
                    break;
                case WaveTypes.NicePeek:
                    material_.EnableKeyword("_WAVE_MODE_NICE_PEEK");
                    break;
            }


            material_.SetFloat("_Wave_Count", MaterialData.waves[0].WaveCount);
            material_.SetFloat("_Amplitude", MaterialData.waves[0].Amplitude);
            
            material_.SetFloat("_Amplitude_Multiplier", MaterialData.waves[0].AmplitudeMultiplier);
            material_.SetFloat("_Wavelength", MaterialData.waves[0].Wavelength);
            
            material_.SetFloat("_Wavelength_Multiplier", MaterialData.waves[0].WavelengthMultiplier);
            material_.SetFloat("_Speed", MaterialData.waves[0].Speed);

       
            material_.SetVector("_Direction", MaterialData.waves[0].Direction.normalized);
            material_.SetFloat("_Steepness_Power", MaterialData.waves[0].SteepnessPower);
            material_.SetFloat("_Peek_Value", MaterialData.waves[0].PeekValue);


            material_.SetColor("_Base_Color",MaterialData.BaseColor);
            material_.SetColor("_Specular_Color", MaterialData.SpecularColor);
            material_.SetFloat("_Specular_Power", MaterialData.SpecularPower);
            material_.SetColor("_Ambient_Light", MaterialData.AmbientColor);
            material_.SetFloat("_Ambient_Strength", MaterialData.AmbientStrenght);
            

            if (LightSource != null) { 
                material_.SetFloat("_Light_Intensity", LightSource.intensity);
                material_.SetVector("_Light_Direction", LightSource.transform.forward);
            }


        }


    }

}

