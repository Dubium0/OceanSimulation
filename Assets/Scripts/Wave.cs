using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;
public enum WaveTypes
{
    Default = 0,
    Sinusodial = 1,
    SteepSinusodial = 2,
    NicePeek = 3,
}
[System.Serializable]
public struct Wave
{
    [Header("Wave Settings")]
    public WaveTypes WaveType;
    public float Influence;
    [Range(1, 100)]
    public int OctaveCount;
    public float Amplitude;
    [Range(0.0f, 1.0f)]
    public float AmplitudeMultiplier;
    public float Wavelength;
    public float FrequencyMultiplier;
    public float Speed;
    public float RandomDirectionSeed;

    public int SteepnessPower;
};

public struct GPUWave
{
    public int WaveType;
    public float Influence;
    public int OctaveCount;
    public float Amplitude;
    public float AmplitudeMultiplier;
    public float Wavelength;
    public float FrequencyMultiplier;
    public float Speed;
    public float RandomDirectionSeed;
    public int SteepnessPower;
}

public static class WaveToGPUReadable {

    public static int GetGPUWaveSize()
    {

        return 10;
    }
    public static GPUWave Convert(Wave wave)
    {

        GPUWave gPUWave = new GPUWave();

        gPUWave.WaveType = (int)wave.WaveType;
        gPUWave.Influence = wave.Influence;

        gPUWave.OctaveCount = wave.OctaveCount;
        gPUWave.Amplitude = wave.Amplitude;
        gPUWave.AmplitudeMultiplier = wave.AmplitudeMultiplier;
        gPUWave.Wavelength = wave.Wavelength;
        gPUWave.FrequencyMultiplier = wave.FrequencyMultiplier;
        gPUWave.Speed = wave.Speed;
        gPUWave.RandomDirectionSeed = wave.RandomDirectionSeed;
        gPUWave.SteepnessPower = wave.SteepnessPower;
        return gPUWave;
    }

    public static GPUWave[] ConvertArray(Wave[] waves) {

        GPUWave[] result = new GPUWave[waves.Length];

        for (int i = 0; i < waves.Length; i++) {
            result[i]   = Convert(waves[i]);
        }
        return result;
    } 

}


/*
  int waveType;
  float influence;
  int octaveCount;
  float amplitude;
  float amplitudeMultiplier;
  float waveLength;
  float frequencyMultiplier;
  float speed;
  float randomDirectionSeed;
  int steepnessPower;

   */
