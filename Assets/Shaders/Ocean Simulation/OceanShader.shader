Shader "Custom/OceanShader"
{
    Properties
    {
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
          
            #pragma multi_compile_fog
            #pragma shader_feature ENABLE_WAVES
            #pragma shader_feature WAVE_MODE_SINE
            #pragma shader_feature WAVE_MODE_GERTSNER
           
            #include "UnityCG.cginc"

            struct FunctionResult
            {
                float derivative0;
                float2 derivatives;
                float2 derivatives2;
            };

            struct Wave
            {
                int octaveCount;
                float amplitude;
                float amplitudeMultiplier;
                float waveLength;
                float frequencyMultiplier;
                float speed;
                float randomDirectionSeed;
            };
            StructuredBuffer<Wave> _Wave;

            float _WarpingCoeff;
            float _VertexHeightCoeff;
            float Random(float2 seed)
            {
                return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453123);
            }

            float2 GetRandomDirection(int index, float seed)
            {
                float2 dir = float2(1, 1);
                // -1,1
                dir.x = 2* frac(Random(float2(index, seed))) - 1;
                dir.y = 2* frac(Random(float2(index, seed + 1))) - 1;

                return normalize(dir);
            }

            

            FunctionResult DirectionFunction(float3 position,float2 direction){
                FunctionResult result;
                 
                result.derivative0 = dot(direction, position.xz);
    
                result.derivatives = float2(direction.x, direction.y);
                return result;
            
            }

            FunctionResult SinusoidalWave(
                
                float3 position,
                FunctionResult directionFunc,
                float amplitude,
                float frequency,
                float phase)
            {
                FunctionResult results;

                float subFunction = (directionFunc.derivative0 ) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * sin(subFunction);
    
                results.derivatives = amplitude * frequency * cos(subFunction) * directionFunc.derivatives;
       
                return results;
    
            }

            FunctionResult BrownianWaveGenerator(float3 position, Wave wave )
            {
                if (wave.octaveCount > 100)
                {
                    wave.octaveCount = 100; // I dont wanna crash accidently
                }
    
                FunctionResult sumOfWaves;
    
                float2 previousDerivatives = float2(0, 0);
                float amplitude = wave.amplitude;
                float frequency = 2.0 * UNITY_PI  / wave.waveLength;
                float sumOfAmplitude = 0;
                for (int i = 0; i < wave.octaveCount; i++)
                {
                    float2 randomDirection  = GetRandomDirection(i,wave.randomDirectionSeed);
                    float phase = sqrt(wave.speed * frequency);
                    position.xz += randomDirection * -previousDerivatives.x * amplitude *_WarpingCoeff ;
                   
                    FunctionResult waveResult;

                    #ifdef WAVE_MODE_SINE
                    waveResult = SinusoidalWave(position,DirectionFunction(position,randomDirection),amplitude,frequency,phase);
                 

                    #else

                    #endif
        
      
                    sumOfWaves.derivative0 += waveResult.derivative0;
                    sumOfWaves.derivatives += waveResult.derivatives;
        
                    previousDerivatives = sumOfWaves.derivatives;
        
                    sumOfAmplitude+= amplitude;
                    amplitude *= wave.amplitudeMultiplier;
                    frequency *= wave.frequencyMultiplier;

                }
    
                sumOfWaves.derivative0 /= sumOfAmplitude;
                sumOfWaves.derivatives /= sumOfAmplitude;
                sumOfWaves.derivative0 *= _VertexHeightCoeff;
                return sumOfWaves;
    
    
            }



           


            struct VertexData
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };

            struct FragmentData
            {
                float4 fragmentPosition : SV_POSITION;
                float3 normal : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				float3 worldPos : TEXCOORD2;
            };



            FragmentData vert (VertexData v)
            {
                FragmentData o;





                o.fragmentPosition = UnityObjectToClipPos(v.position);
                o.normal = normalize( UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.position).xyz;
                
                #ifdef ENABLE_WAVES

                FunctionResult waveFunction = BrownianWaveGenerator(o.worldPos,_Wave[0]);
                o.fragmentPosition = UnityObjectToClipPos(v.position + fixed4(0,waveFunction.derivative0,0,0));
                o.normal = normalize( UnityObjectToWorldNormal( float3(-waveFunction.derivatives.x, 1.0,-waveFunction.derivatives.y)));
                o.worldPos = mul(unity_ObjectToWorld, v.position + fixed4(0,waveFunction.derivative0,0,0)).xyz;
                UNITY_TRANSFER_FOG(o,o.fragmentPosition);
                #endif
                
                
                return o;
            }

            fixed4 frag (FragmentData i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(i.normal,1.0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
