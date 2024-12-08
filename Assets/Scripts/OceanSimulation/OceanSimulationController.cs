

using System;
using UnityEngine;
using UnityEngine.LightTransport;

namespace OceanSimulation
{

public class OceanSimulationController : MonoBehaviour
{
    public Material OceanMaterial;

    [Header("Fields")]
    public Wave WavePreset;

    [Header("General Settings")]
    public bool EnableWave;
    public float WarpingCoefficent;
    public float VertexHeightCoefficent;

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
        if (OceanMaterial == null) { Debug.LogError("Ocean material is not assigned!"); return; }
        if (WavePreset == null) { Debug.LogError("Wave preset is not assigned!"); return; }

        if (EnableWave)
        {
            OceanMaterial.EnableKeyword("ENABLE_WAVES");
        }
        else
        {
            OceanMaterial.DisableKeyword("ENABLE_WAVES");
        }

        if(waveBuffer_ == null)
        {
            waveBuffer_ = new ComputeBuffer(1, Wave.GetGPUWaveByteSize());
 
        }

        Wave.GPUWave[] gPUWaves = { WavePreset.GetGpuWritableData() };
        waveBuffer_.SetData(gPUWaves);
        OceanMaterial.SetBuffer("_Wave", waveBuffer_);

        OceanMaterial.DisableKeyword("WAVE_MODE_SINE");
        OceanMaterial.DisableKeyword("WAVE_MODE_GERTSNER");
        switch (WavePreset.CurrentWaveType)
        {

            case Wave.WaveType.Sinus:
                OceanMaterial.EnableKeyword("WAVE_MODE_SINE");
            break;
            case Wave.WaveType.Gertsner:
                OceanMaterial.EnableKeyword("WAVE_MODE_GERTSNER");
            break;

        }
        OceanMaterial.SetFloat("_WarpingCoeff",WarpingCoefficent);
        OceanMaterial.SetFloat("_VertexHeightCoeff", VertexHeightCoefficent);


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