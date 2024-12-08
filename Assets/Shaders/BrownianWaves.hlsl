#ifndef _BROWNIANWAVES
#define _BROWNIANWAVES


#define EulerNumber 2.71666666667

//0-1
float Random(float2 seed)
{
    return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

float2 GetRandomDirection(int waveIndex, float directionSeed)
{
    float2 dir = float2(1,1);

    dir.x = 2.0 * Random(float2(waveIndex, 0.96)) - 1.0;
    dir.y = 2.0 * Random(float2(waveIndex, 0.96 + 1)) - 1.0;

    return normalize(dir);
}


struct DirectionFunctionValues
{
    float2 direction;
    float derivative0;
    float2 derivatives;
};


DirectionFunctionValues DirectionFunction(float3 position, float2 direction)
{
    DirectionFunctionValues result;
    result.direction = direction;
    
    result.derivative0 = dot(direction, position.xz);
    
    result.derivatives = float2(direction.x, direction.y);
   
    
    return result;
}




struct WaveFunctionResult
{
    float derivative0;
    float2 derivatives;
};

WaveFunctionResult SinusoidalWave(
    int waveIndex,
    float2 previousDerivatives,
    float3 position,
    float2 direction,
    float amplitude,
    float wavelenght,
    float speed)
{
    WaveFunctionResult results;
    
    float2 randomDirection = GetRandomDirection(waveIndex, 20);
    DirectionFunctionValues directionFunctionValues = DirectionFunction(position, randomDirection);
    


    float frequency = 2.0 / wavelenght;
    float phase = speed * frequency;
    
    
    float subFunction = (directionFunctionValues.derivative0 + previousDerivatives.x + previousDerivatives.y) * frequency + _Time.y * phase;
    
    results.derivative0 = amplitude * sin(subFunction);
    
    results.derivatives = amplitude * frequency * cos(subFunction) * directionFunctionValues.derivatives;
       
    return results;
    
}

WaveFunctionResult SteeperSinusoidalWave(
    int waveIndex,
    float2 previousDerivatives,
    float3 position,
    float2 direction,
    float amplitude,
    float wavelenght,
    float speed,
    float steepExponent)
{
    WaveFunctionResult results;
    float2 randomDirection = GetRandomDirection(waveIndex, 20);
    DirectionFunctionValues directionFunctionValues = DirectionFunction(position, randomDirection);
    
 

    float frequency = 2.0 / wavelenght;
    float phase = speed * frequency;
    
    
    float subFunction = (directionFunctionValues.derivative0 + previousDerivatives.x + previousDerivatives.y) * frequency + _Time.y * phase;
    
    results.derivative0 = amplitude * pow((sin(subFunction) + 1) / 2.0,steepExponent);
    
    results.derivatives = steepExponent * frequency * cos(subFunction) * results.derivative0 * directionFunctionValues.derivatives;
       
    return results;
}

WaveFunctionResult NicePeekWave(
int waveIndex,
    float2 previousDerivatives,
    float3 position,
    float2 direction,
    float amplitude,
    float wavelenght,
    float speed,
    float peekValue)
{
    
    float2 randomDirection = GetRandomDirection(waveIndex, 20);
    WaveFunctionResult results;
    
    DirectionFunctionValues directionFunctionValues = DirectionFunction(position, randomDirection);
    


    float frequency = 2.0 * PI/ wavelenght;
    float phase = sqrt(speed * frequency);
    
    
    float subFunction = (directionFunctionValues.derivative0 + previousDerivatives.x + previousDerivatives.y) * frequency + _Time.y * phase;
    
    results.derivative0 = amplitude * pow(EulerNumber, sin(subFunction) + peekValue);
    
    results.derivatives =  frequency * cos(subFunction) * results.derivative0 * directionFunctionValues.derivatives;
       
    return results;
}




void BrownianWaveGenerator_float(
    float3 position,
    float2 direction,
    float initialAmplitude,
    float initialWavelenght,
    float speed,
    int waveCount,
    float amplitudeMultiplier,
    float waveLenghtMultiplier,
    float steepnessPower,
    float peekValue,
    float noiseValue,

    out float3 PositionOut,
    out float3 NormalOut,
    out float3 TangentOut
    )
{
    if (waveCount > 100)
    {
        waveCount = 100; // I dont wanna crash accidently
    }
    
    WaveFunctionResult sumOfWaves;
    
    WaveFunctionResult result;
    result.derivatives = float2(0, 0);
    float2 previousDerivatives = float2(0, 0);
    
    for (int i = 0; i < waveCount; i++)
    {
       
        #if _WAVE_MODE_SINUSODIAL
        result = SinusoidalWave(i,previousDerivatives,position, direction, initialAmplitude, initialWavelenght, speed);
        
        #elif _WAVE_MODE_STEEP_SINUSODIAL
        result = SteeperSinusoidalWave(i,previousDerivatives,position, direction, initialAmplitude, initialWavelenght, speed,steepnessPower);
        #elif _WAVE_MODE_NICE_PEEK
        result = NicePeekWave(i,previousDerivatives,position, direction, initialAmplitude, initialWavelenght, speed, peekValue);
        #else
        result = SteeperSinusoidalWave(i, previousDerivatives, position, direction, initialAmplitude, initialWavelenght, speed, steepnessPower);
        #endif
        
        sumOfWaves.derivative0 += result.derivative0;
        sumOfWaves.derivatives += result.derivatives;
        
        previousDerivatives = sumOfWaves.derivatives;
        
        initialAmplitude *= amplitudeMultiplier;
        initialWavelenght *= waveLenghtMultiplier;

    }
    

    PositionOut = float3(0, sumOfWaves.derivative0, 0);
    TangentOut = float3(1.0, sumOfWaves.derivatives.x, 0.0);
    NormalOut =  normalize(float3(-sumOfWaves.derivatives.x, 1.0, -sumOfWaves.derivatives.y));
    
    
}


#endif