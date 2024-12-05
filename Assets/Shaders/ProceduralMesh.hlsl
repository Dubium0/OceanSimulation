struct DirectionFunctionValues
{
    float2 direction;
    float derivative0;
    float derivativeX;
    float derivativeY;
};

DirectionFunctionValues SumDirectionFunction(float3 position, float3 origin)
{
    DirectionFunctionValues result;
    result.direction = (position - origin).xz;
    
    result.derivative0 = result.direction.x + result.direction.y;
    
    result.derivativeX = 1;
    result.derivativeY = 1;
    
    return result;
}



void Ripple_float(
	float3 PositionIn, float3 Origin,
	float Period, float Speed, float Amplitude,
	out float3 PositionOut, out float3 NormalOut, out float3 TangentOut
)
{
    float3 p = PositionIn - Origin;
    float d = length(p);
    float f = 2.0 * PI * Period * (d - Speed * _Time.y);

    PositionOut = PositionIn + float3(0.0, Amplitude * sin(f), 0.0);

    float2 derivatives = (2.0 * PI * Amplitude * Period * cos(f) / max(d, 0.0001)) * p.xz;

    TangentOut = float3(1.0, derivatives.x, 0.0);
    NormalOut = cross(float3(0.0, derivatives.y, 1.0), TangentOut);
}

/*
Position is on object space and between -0.5 and 0.5

*/
void WaveFunction_float(
    float3 position,
    float3 origin,
    float amplitude,
    float wavelenght,
    float speed,
   
    out float3 PositionOut,
    out float3 NormalOut,
    out float3 TangentOut)
{
    
    float2 direction = (position - origin).xz;
    //direction.y = 0;
    
    
    float directionFunc = direction.x + direction.y;

    float frequency = 2.0 / wavelenght;
    float phase = speed * frequency;
    
    
    float subFunction = directionFunc * frequency + _Time.y * phase;
    float function = amplitude * sin(subFunction);
    
    float2 derivatives = (amplitude * frequency * cos(subFunction) / max(directionFunc, 0.0001)) * direction.xy;
   
    
    float3 binormal = float3(0.0, derivatives.y, 1.0);
    float3 tangent = float3(1.0, derivatives.x, 0.0);
    
  
    PositionOut = position + float3(0, function, 0);
    NormalOut = cross(binormal, tangent);
    TangentOut = tangent;

}




