

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
    [Header("General Settings")]
    public bool EnableWave;


    private ComputeBuffer waveBuffer_;
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



     
      
        switch (WavePreset.CurrentWaveType)
        {

            case Wave.WaveType.Sinus:
                SimulationMaterial.EnableKeyword("WAVE_MODE_SINE");
                SimulationMaterial.DisableKeyword("WAVE_MODE_GERTSNER");
                 break;
            case Wave.WaveType.Gertsner:
                SimulationMaterial.EnableKeyword("WAVE_MODE_GERTSNER");
                SimulationMaterial.DisableKeyword("WAVE_MODE_SINE");
                break;

        }
      


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