

using System;
using UnityEngine;
using UnityEngine.LightTransport;

namespace OceanSimulation
{

public class OceanSimulationController : MonoBehaviour
{
    public Material SimulationMaterial;

    [Header("Fields")]
    public Wave WavePreset;
    public OceanMaterial OceanMaterialPreset;
    public Cubemap SkyboxCubemap;
    public Light Light_;
    [Header("General Settings")]
    public bool EnableWave;
    public float WarpingCoefficent;
    public float VertexHeightCoefficent;
    

    private ComputeBuffer waveBuffer_;
    private ComputeBuffer materialBuffer_;
    private void OnValidate()
    {
        if (!Application.isEditor && Application.isPlaying)
        {

            UpdateMaterialData();
        }
    }
    private void Start()
    {
      
        UpdateMaterialData();
    }

    private void FixedUpdate()
    {
        UpdateMaterialData();
    }
    private void UpdateMaterialData()
    {
        if (SimulationMaterial == null) { Debug.LogError("Ocean material is not assigned!"); return; }
        if (WavePreset == null) { Debug.LogError("Wave preset is not assigned!"); return; }
        if (OceanMaterialPreset == null) { Debug.LogError("Ocean Material Preset is not assigned!"); return; }

            if (EnableWave)
        {
                SimulationMaterial.EnableKeyword("ENABLE_WAVES");
        }
        else
        {
                SimulationMaterial.DisableKeyword("ENABLE_WAVES");
        }

        if(waveBuffer_ == null)
        {
            waveBuffer_ = new ComputeBuffer(1, Wave.GetGPUWaveByteSize());
 
        }

        Wave.GPUWave[] gPUWaves = { WavePreset.GetGpuWritableData() };
        waveBuffer_.SetData(gPUWaves);
            SimulationMaterial.SetBuffer("_Wave", waveBuffer_);

        if(materialBuffer_ == null)
        {
            materialBuffer_  = new ComputeBuffer(1, OceanMaterial.GetGPUOceanMaterialByteSize());
        }
        OceanMaterial.GPUOceanMaterial[] gPUOceanMaterials = { OceanMaterialPreset.GetGpuWritableData() };
        materialBuffer_.SetData(gPUOceanMaterials);
        SimulationMaterial.SetBuffer("_Material", materialBuffer_);


        SimulationMaterial.DisableKeyword("WAVE_MODE_SINE");
        SimulationMaterial.DisableKeyword("WAVE_MODE_GERTSNER");
        switch (WavePreset.CurrentWaveType)
        {

            case Wave.WaveType.Sinus:
                    SimulationMaterial.EnableKeyword("WAVE_MODE_SINE");
            break;
            case Wave.WaveType.Gertsner:
                    SimulationMaterial.EnableKeyword("WAVE_MODE_GERTSNER");
            break;

        }
        SimulationMaterial.SetFloat("_WarpingCoeff",WarpingCoefficent);
        SimulationMaterial.SetFloat("_VertexHeightCoeff", VertexHeightCoefficent);
        SimulationMaterial.SetTexture("_Skybox", SkyboxCubemap);
        SimulationMaterial.SetVector("_SunDirection", Light_.transform.forward);


        }

    void OnDestroy()
    {
        // Release the buffer when no longer needed
        if (waveBuffer_ != null)
        {
            waveBuffer_.Release();
            waveBuffer_ = null;
        }
    }

}

}