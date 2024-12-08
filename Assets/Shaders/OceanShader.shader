Shader "Custom/OceanShader"
{
    Properties
    {
        _DiffuseColor       ("Diffuse Color", Color) = (0, 0, 1, 1)
        _AmbientColor       ("Ambient Color",Color) = (0, 0, 1, 1)
        _SpecularColor      ("Specular Color",Color) = (1, 1, 1, 1)
        
        
        _AmbientStrength    ("Ambient Strength", Float) = 0.1
        _Shininess          ("Shininess", Float) = 1


        _WaveBufferSize     ("Wave Buffer Size",Float) = 1

    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "AutoLight.cginc"

            // Properties
            
            
            #define WAVE_DEFAULT 0
            #define WAVE_SINUSODIAL 1
            #define WAVE_STEEP_SINUSODIAL 2
            #define WAVE_NICE_PEEK 3

            #define EulerNumber 2.71666666667
            #define PI 3.141592653590

            struct Wave
            {
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
            };
            StructuredBuffer<Wave> _Waves;

            fixed4 _DiffuseColor;
            fixed4 _AmbientColor;   
            fixed4 _SpecularColor;  
            
            
            float _AmbientStrength;
            float _Shininess; 
            
            
            float _WaveBufferSize;




            struct VertexData
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            
            };

            struct FragmentData
            {
                
                UNITY_FOG_COORDS(1)
                float4 fragPos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
            };


            float Random(float2 seed)
            {
                return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float2 GetRandomDirection(int waveIndex, float directionSeed)
            {
                float2 dir = float2(1, 1);

                dir.x = 2.0 * Random(float2(waveIndex, directionSeed)) - 1.0;
                dir.y = 2.0 * Random(float2(waveIndex, directionSeed + 1)) - 1.0;

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
                float directionSeed,
                float amplitude,
                float frequency,
                float speed)
            {
                WaveFunctionResult results;
 
                position.x += previousDerivatives.x;
                position.z += previousDerivatives.y;
    
                DirectionFunctionValues directionFunctionValues = DirectionFunction(position, GetRandomDirection(waveIndex, 20));
    
                float phase = sqrt(speed * frequency);
    
    
                float subFunction = (directionFunctionValues.derivative0 ) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * sin(subFunction);
    
                results.derivatives = amplitude * frequency * cos(subFunction) * directionFunctionValues.derivatives;
       
                return results;
    
            }

            WaveFunctionResult SteeperSinusoidalWave(
                int waveIndex,
                float2 previousDerivatives,
                float3 position,
                float directionSeed,
                float amplitude,
                float frequency,
                float speed,
                float steepExponent)
            {
                WaveFunctionResult results;
      
                position.x += previousDerivatives.x;
                position.z += previousDerivatives.y;
    
                DirectionFunctionValues directionFunctionValues = DirectionFunction(position, GetRandomDirection(waveIndex, 20));
    
                float phase = sqrt(speed * frequency);
    
    
                float subFunction = (directionFunctionValues.derivative0) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * pow((sin(subFunction) + 1) / 2.0, steepExponent);
    
                results.derivatives = steepExponent * frequency * cos(subFunction) * results.derivative0 * directionFunctionValues.derivatives;
       
                return results;
            }

            WaveFunctionResult NicePeekWave(
                int waveIndex,
                float2 previousDerivatives,
                float3 position,
                float directionSeed,
                float amplitude,
                float frequency,
                float speed,
                float peekValue)
            {
                WaveFunctionResult results;
    
                position.x += previousDerivatives.x;
                position.z += previousDerivatives.y;
    
                DirectionFunctionValues directionFunctionValues = DirectionFunction(position, GetRandomDirection(waveIndex, 20));
    
                float phase = sqrt(speed * frequency);
    
    
                float subFunction = (directionFunctionValues.derivative0 ) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * pow(EulerNumber, sin(subFunction) + peekValue);
    
                results.derivatives = frequency * cos(subFunction) * results.derivative0 * directionFunctionValues.derivatives;
       
                return results;
            }




            WaveFunctionResult BrownianWaveGenerator(float3 position,Wave wave)
            {
                if (wave.octaveCount > 100)
                {
                    wave.octaveCount = 100; // I dont wanna crash accidently
                }
    
                WaveFunctionResult sumOfWaves;
    
                WaveFunctionResult result;
                result.derivatives = float2(0, 0);
                float2 previousDerivatives = float2(0, 0);
                float initialAmplitude = wave.amplitude;
                float initialFrequency = 2.0 * PI / wave.waveLength;
                for (int i = 0; i < wave.octaveCount; i++)
                {
                   /*
                     WAVE_DEFAULT 0
                     WAVE_SINUSODIAL 1
                     WAVE_STEEP_SINUSODIAL 2
                     WAVE_NICE_PEEK 3
                    */
                    if (wave.waveType == WAVE_SINUSODIAL)
                    {
                        result = SinusoidalWave(i, previousDerivatives, position, wave.randomDirectionSeed, initialAmplitude, initialFrequency, wave.speed);
                    }
                    else if (wave.waveType == WAVE_STEEP_SINUSODIAL)
                    {
                        result = SteeperSinusoidalWave(i, previousDerivatives, position, wave.randomDirectionSeed, initialAmplitude, initialFrequency, wave.speed, wave.steepnessPower);
                    }
                    else if (wave.waveType == WAVE_NICE_PEEK)
                    {
                        result = NicePeekWave(i, previousDerivatives, position, wave.randomDirectionSeed, initialAmplitude, initialFrequency, wave.speed, wave.steepnessPower);
                    }
                    else
                    {
                        result = SinusoidalWave(i, previousDerivatives, position, wave.randomDirectionSeed, initialAmplitude, initialFrequency, wave.speed);
                    }
        
        
                    sumOfWaves.derivative0 += result.derivative0;
                    sumOfWaves.derivatives += result.derivatives;
        
                    previousDerivatives = sumOfWaves.derivatives;
        
                    initialAmplitude *= wave.amplitudeMultiplier;
                    initialFrequency *= wave.frequencyMultiplier;

                }
    

                return sumOfWaves;
    
    
            }
           /*

            void GenerateWaveMap_float(float3 position, 
                out float3 PositionOut,
                out float3 NormalOut,
                out float3 TangentOut)
            {
    
                uint length = 0;
                uint stride = 0;
                _WaveBuffer.GetDimensions(length, stride);
    
    
                WaveFunctionResult result;
                WaveFunctionResult intermidiateResult;
                intermidiateResult.derivatives = float2(0, 0);
                for (int i = 0; i < length; i++)
                {

                    Wave wave = _WaveBuffer[i];
        
                    intermidiateResult = BrownianWaveGenerator(position, wave);
                    intermidiateResult.derivative0 *= wave.influence;
                    intermidiateResult.derivatives *= wave.influence;
        
                    result.derivative0 += intermidiateResult.derivative0;
                    result.derivatives += intermidiateResult.derivatives;

                }
    
                PositionOut = position + float3(0, result.derivative0, 0);
                TangentOut = float3(1.0, result.derivatives.x, 0.0);
                NormalOut = normalize(cross(float3(0.0, result.derivatives.y, 1.0), TangentOut));

    
            }

           */

            FragmentData vert (VertexData v)
            {
                FragmentData output;

                WaveFunctionResult result;
               
                

                float3 position =  v.position;
                for (int i = 0; i < _WaveBufferSize; i++)
                {
                    WaveFunctionResult intermidiateResult;

                    Wave wave = _Waves[i];

                    intermidiateResult = BrownianWaveGenerator(position, wave);
                    intermidiateResult.derivative0 *= wave.influence;
                    intermidiateResult.derivatives *= wave.influence;
        
                    result.derivative0 += intermidiateResult.derivative0;
                    result.derivatives += intermidiateResult.derivatives;

                    position.x += result.derivatives.x;
                    position.z += result.derivatives.y;
                }

                v.position = v.position + float4(0, result.derivative0, 0,0);
                output.fragPos = UnityObjectToClipPos(v.position);
                output.worldPos =  mul(unity_ObjectToWorld, v.position).xyz;
                output.worldNormal = normalize( UnityObjectToWorldNormal(v.normal));
                


                UNITY_TRANSFER_FOG(output,output.fragPos);
                return output;
            }

            fixed4 frag (FragmentData i) : SV_Target
            {
               
      
                float3 lightDir = _WorldSpaceLightPos0;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 halfwayDir = normalize(lightDir + viewDir);

                float3 diffuse = _LightColor0.rgb * DotClamped(lightDir, normalize(i.worldNormal)) ;
				diffuse *= _DiffuseColor;

                 // specular
            
                float specular = _LightColor0.rgb * pow(DotClamped(i.worldNormal, halfwayDir), _Shininess);
                
                float3 specularColor =  _SpecularColor * specular;
                // ambient
                float3 ambientColor = _AmbientColor * _AmbientStrength;


                fixed4 color = fixed4(diffuse + specularColor +  ambientColor ,1.0);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
}
