using Unity.VisualScripting;
using UnityEngine;


namespace OceanSimulation
{



[CreateAssetMenu(fileName ="Wave Preset",menuName ="Ocean Simulation/Wave Preset")]
public class Wave : ScriptableObject
{

    public struct GPUWave
    {
        public int octaveCount;
        public float amplitude;
        public float amplitudeMultiplier;
        public float waveLength;
        public float frequencyMultiplier;
        public float speed;
        public float randomDirectionSeed;
    }

    public static int GetGPUWaveByteSize()
    {
        return sizeof(float)*7;
    }
    public enum WaveType
    {
        Sinus = 0,
        Gertsner = 1,
    }
    public WaveType CurrentWaveType;
    [Range(1,100)]
    public int OctaveCount;
    public float Amplitude;
    [Range(0,1)]
    public float AmplitudeMultiplier;
    public float WaveLength;
    public float FrequencyMultiplier;
    public float Speed;
    public float RandomDirectionSeed;
    
    public GPUWave GetGpuWritableData()
    {
        GPUWave gPUWave = new GPUWave();
        gPUWave.octaveCount = OctaveCount;
        gPUWave.amplitude = Amplitude;
        gPUWave.amplitudeMultiplier = AmplitudeMultiplier;
        gPUWave.waveLength = WaveLength;
        gPUWave.frequencyMultiplier = FrequencyMultiplier;
        gPUWave.speed = Speed;
        gPUWave.randomDirectionSeed = RandomDirectionSeed;

        return gPUWave;

    }
     

    }

}