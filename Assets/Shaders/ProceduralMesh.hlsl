struct DirectionFunctionValues
{
    float2 direction;
    float derivative0;
    float2 derivatives;
};

DirectionFunctionValues SumDirectionFunction(float3 position, float3 origin)
{
    DirectionFunctionValues result;
    result.direction = (position - origin).xz;
    
    result.derivative0 = result.direction.x + result.direction.y;
    
    result.derivatives = float2(1, 1);
   
    
    return result;
}

DirectionFunctionValues LenghtXZDirectionFunction(float3 position, float3 origin)
{
    DirectionFunctionValues result;
    result.direction = (position - origin).xz;
    
    result.derivative0 = length(result.direction);
    
    result.derivatives = float2(result.direction.x, result.direction.y) / max(result.derivative0, 0.01);
  
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

    float2 derivatives = (2.0 * PI * Amplitude * Period * cos(f) / max(d, 0.001)) * p.xz;

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
    
   
    //direction.y = 0;
    DirectionFunctionValues directionFunctionValues = LenghtXZDirectionFunction(position, origin);
    


    float frequency = 2.0 / wavelenght;
    float phase = speed * frequency;
    
    
    float subFunction = directionFunctionValues.derivative0 * frequency + _Time.y * phase;
    float function = amplitude * sin(subFunction);
    
    float2 derivatives = amplitude * frequency * cos(subFunction) * directionFunctionValues.derivatives;
   
    
    float3 binormal = float3(0.0, derivatives.y, 1.0);
    float3 tangent = float3(1.0, derivatives.x, 0.0);
    
  
    PositionOut = position + float3(0, function, 0);
    NormalOut = normalize(cross(binormal, tangent));
    TangentOut = normalize(tangent);

}




