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
    [Range(1, 100)]
    public int WaveCount;
    public WaveTypes WaveType;
    public float Amplitude;
    [Range(0.0f, 1.0f)]
    public float AmplitudeMultiplier;
    public float Wavelength;
    public float WavelengthMultiplier;
    public float Speed;
    public Vector2 Direction;
    [Min(1)]
    public int SteepnessPower;
    public float PeekValue;

}
