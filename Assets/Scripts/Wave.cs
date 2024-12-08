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
    [Min(1)]
    public int SteepnessPower;

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
