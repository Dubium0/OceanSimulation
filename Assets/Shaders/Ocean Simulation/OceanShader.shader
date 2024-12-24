Shader "Custom/OceanShader"
{
    Properties
    {
        _Color ("Color", Color) = (0.0, 0.5, 0.7, 1) 
        _AmbientColor ("Ambient Color", Color) = (0.2, 0.2, 0.2, 1) 
         _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.5 
        _SpecularColor ("Specular Color", Color) = (1,1,1,1) 
        _Shininess ("Shininess", Range(0.03, 1)) = 0.5 
        _FresnelPower ("Fresnel Power", Range(0.1, 5)) = 2.0 
        _ReflectionCubemap ("Reflection Cubemap", CUBE) = "" {}
        _ReflectionStrength ("Reflection Strength", Range(0, 1)) = 0.5
      
        _TipColor ("Tip Color", Color) = (1.0, 1.0, 0.2, 1) 
         _TipAttenuation ("Tip Attenuation", Range(0.0, 128)) = 0.5 
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
       
            #define EulerNumber 2.71666666667
           

            struct Wave
            {
                int octaveCount;
                float amplitude;
                float amplitudeMultiplier;
                float waveLength;
                float frequencyMultiplier;
                float speed;
                float randomDirectionSeed;
                float warping;
                float maxHeight;
                float steepness;
            };
            
            
            //unity_AmbientSky

            StructuredBuffer<Wave> _Wave;
          

            
     

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

                //dir.x = clamp(dir.x,-1,1);
                //dir.y = clamp(dir.x,-1,1);
                
                
                return normalize(dir);
            }

             struct FunctionResult
            {
                float derivative0;
                float2 derivatives;
            };

            FunctionResult DirectionFunction(float3 position,float2 direction){
                FunctionResult result;
                 
                result.derivative0 = dot(direction, position.xz); // direction.x * position.x + direction.y *position.z
    
                result.derivatives = float2(direction.x, direction.y); // /dx =>direction.x , /dz => direction.y 
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
    
                results.derivatives.x = amplitude * frequency * cos(subFunction) * directionFunc.derivatives.x;
                results.derivatives.y = amplitude * frequency * cos(subFunction) * directionFunc.derivatives.y;
                return results;
            }

            FunctionResult NicePeekWave(
                float3 position,
                 FunctionResult directionFunc,
                float amplitude,
                float frequency,
                float phase,
                float steepness)
            {
                FunctionResult results;

    
                float subFunction = ( directionFunc.derivative0 ) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * pow(EulerNumber, sin(subFunction) + steepness);
    
                results.derivatives = frequency * cos(subFunction) * results.derivative0 * directionFunc.derivatives;
       
                return results;
            }

            FunctionResult BrownianWaveGenerator(float3 position, Wave wave )
            {
                if (wave.octaveCount > 200)
                {
                    wave.octaveCount = 200; // I dont wanna crash accidently
                }
    
                FunctionResult sumOfWaves;
    
                float2 previousDerivatives = float2(0, 0);
                float amplitude = wave.amplitude;
                float frequency = 2.0 * UNITY_PI  / wave.waveLength;
                float sumOfAmplitude = 0;
               
                for (int i = 0; i < wave.octaveCount; i++)
                {
                     float2 randomDirection  = GetRandomDirection(i ,wave.randomDirectionSeed);
                    float phase = sqrt(wave.speed * frequency);
                    position.xz += randomDirection * -previousDerivatives.x * amplitude * wave.warping;
                   
                    FunctionResult waveResult;

                    #ifdef WAVE_MODE_SINE
                    waveResult = SinusoidalWave(position,DirectionFunction(position,randomDirection),amplitude,frequency,phase);
                 

                    #elif WAVE_MODE_GERTSNER
                    waveResult = NicePeekWave(position,DirectionFunction(position,randomDirection),amplitude,frequency,phase,wave.steepness );

                    #else
                    waveResult = SinusoidalWave(position,DirectionFunction(position,randomDirection),amplitude,frequency,phase);
                 
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
                sumOfWaves.derivative0 *= wave.maxHeight;

                #ifdef WAVE_MODE_GERTSNER
                sumOfWaves.derivative0 -=2.5;
                #endif
                return sumOfWaves;

            }



            float3 calculateNormal(float3 position, Wave wave) {
            // Compute small offsets to estimate surface slope
            float eps = 0.001;
            float height = BrownianWaveGenerator(position, wave).derivative0;
            float heightX = BrownianWaveGenerator(position + float3(eps, 0, 0), wave).derivative0;
            float heightZ = BrownianWaveGenerator(position + float3(0, 0, eps), wave).derivative0;
            
            float3 normal = normalize(float3(
                -(heightX - height) / eps,
                1.0,
                -(heightZ - height) / eps
            ));
    
            return normal;
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
                float3 viewDir : TEXCOORD3;
                float height : TEXCOORD4;
            };



            FragmentData vert (VertexData v)
            {
                FragmentData o;

                o.fragmentPosition = UnityObjectToClipPos(v.position);
                o.normal = normalize( UnityObjectToWorldNormal(v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.position).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos -  o.worldPos);

                #ifdef ENABLE_WAVES
   
                FunctionResult waveFunction = BrownianWaveGenerator(o.worldPos,_Wave[0]);

                o.fragmentPosition = UnityObjectToClipPos(v.position + fixed4(0,waveFunction.derivative0,0,0));
                o.height = waveFunction.derivative0;
                //float3 tangent = float3(1.0, waveFunction.derivatives.x, 0.0);
                //float3 normal = cross(float3(0.0, waveFunction.derivatives.y, 1.0), tangent);
                //o.normal = normalize( UnityObjectToWorldNormal(calculateNormal(o.worldPos,_Wave[0]) ));
                o.normal = 0.0;
                o.worldPos = mul(unity_ObjectToWorld, v.position + fixed4(0,waveFunction.derivative0,0,0)).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos -  o.worldPos);
              
                #endif

                UNITY_TRANSFER_FOG(o,o.fragmentPosition);
                
                return o;
            }


            samplerCUBE _ReflectionCubemap; 
            float _ReflectionStrength; 
            float4 _Color; 
            float4 _SpecularColor; 
            float _Shininess; 
            float _FresnelPower; 
            float _WaveSpeed; 
            float4 _AmbientColor;
            float _AmbientStrength;
            float4 _TipColor;
            float _TipAttenuation;


            fixed4 frag (FragmentData i) : SV_Target
            {
               
               i.normal =calculateNormal(i.worldPos,_Wave[0]);
             
               float3 N = i.normal; 
               // Calculate the light direction and half vector 
               float3 L = normalize(_WorldSpaceLightPos0.xyz); 
               float3 H = normalize(L + i.viewDir); 
               // Compute the diffuse and specular components 
               float diff = max(0, dot(N, L)); 
               float spec = pow(max(0, dot(N, H)), _Shininess * 128.0); 
               // Compute the Fresnel effect 
               float3 V = normalize(i.viewDir); 
               float fresnel = pow(1.0 - max(0, dot(N, V)), _FresnelPower); 
               // Sample the cubemap for reflections 
               float3 reflectDir = reflect(-V, N); 
               fixed4 reflection = texCUBE(_ReflectionCubemap, reflectDir); 
               reflection *= _ReflectionStrength; 
               // Combine the components with Fresnel effect, reflections, and ambient light

               
              // float4 tipColor = _TipColor * pow( saturate( i.height*2 +1), _TipAttenuation);

               fixed4 color =  _AmbientStrength* _AmbientColor + _Color * diff + _SpecularColor * spec * fresnel + reflection * fresnel;

             
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;

                //return fixed4(i.normal,1.0);
               // return fixed4( pow( saturate( i.height*2 +1), _TipAttenuation),0.0,0.0,1.0);
            }
            ENDCG
        }
    }
}
