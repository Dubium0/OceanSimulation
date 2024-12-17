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
        public float warping;
        public float maxHeight;
        public float steepness;
    }



    public static int GetGPUWaveByteSize()
    {
        return sizeof(float)*10;
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
    public float Warping;
    public float MaxHeight;
    public float Steepness;

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
        gPUWave.warping = Warping;
        gPUWave.maxHeight = MaxHeight;
        gPUWave.steepness = Steepness;

        return gPUWave;

    }
     

    }

}