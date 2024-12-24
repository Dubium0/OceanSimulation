Shader "Custom/TessellationShader"
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




        _DummyCameraPos("Dummy Camera Position", Vector) = (0, 0, 0, 0)
        [Enum(Off, 0, On, 1)] _ZWrite ("Z Write", Float) = 1
    }

    CGINCLUDE
        #define _TessellationEdgeLength 20
        float3 _DummyCameraPos;
        struct TessellationFactors {
            float edge[3] : SV_TESSFACTOR;
            float inside : SV_INSIDETESSFACTOR;
        };

        float TessellationHeuristic(float3 cp0, float3 cp1) {
            float edgeLength = distance(cp0, cp1);
            float3 edgeCenter = (cp0 + cp1) * 0.5;
            float viewDistance = distance(edgeCenter, _DummyCameraPos);

            return edgeLength * _ScreenParams.y / (_TessellationEdgeLength * (pow(viewDistance * 0.5f, 1.2f)));
        }

        bool TriangleIsBelowClipPlane(float3 p0, float3 p1, float3 p2, int planeIndex, float bias) {
            float4 plane = unity_CameraWorldClipPlanes[planeIndex];

            return dot(float4(p0, 1), plane) < bias && dot(float4(p1, 1), plane) < bias && dot(float4(p2, 1), plane) < bias;
        }

        bool cullTriangle(float3 p0, float3 p1, float3 p2, float bias) {
            return TriangleIsBelowClipPlane(p0, p1, p2, 0, bias) ||
                   TriangleIsBelowClipPlane(p0, p1, p2, 1, bias) ||
                   TriangleIsBelowClipPlane(p0, p1, p2, 2, bias) ||
                   TriangleIsBelowClipPlane(p0, p1, p2, 3, bias);
        }
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 400

        Pass
        {
            CGPROGRAM
            #pragma vertex dummyvp
            #pragma hull hp
            #pragma domain dp
            #pragma geometry gp
            #pragma fragment fp

            #pragma target 5.0
            #pragma multi_compile_fog

            #pragma shader_feature ENABLE_WAVES
            #pragma shader_feature WAVE_MODE_SINE
            #pragma shader_feature WAVE_MODE_GERTSNER
            #include "UnityCG.cginc"

            float _TessellationFactor;
          
            struct TessellationControlPoint {
                float4 vertex : INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
            };

            struct VertexData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float depth : TEXCOORD2;
                float height : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };

            struct g2f {
                v2g data;
                float2 barycentricCoordinates : TEXCOORD9;
            };

            TessellationControlPoint dummyvp(VertexData v) {
                TessellationControlPoint p;
                p.vertex = v.vertex;
                p.uv = v.uv;
                return p;
            }

            TessellationFactors PatchFunction(InputPatch<TessellationControlPoint, 3> patch) {
                float3 p0 = mul(unity_ObjectToWorld, patch[0].vertex).xyz;
                float3 p1 = mul(unity_ObjectToWorld, patch[1].vertex).xyz;
                float3 p2 = mul(unity_ObjectToWorld, patch[2].vertex).xyz;

                TessellationFactors f;
                float bias = -0.5 * 100;
                if (cullTriangle(p0, p1, p2, bias)) {
                    f.edge[0] = f.edge[1] = f.edge[2] = f.inside = 0;
                } else {
                     f.edge[0] = TessellationHeuristic(p1, p2);
                    f.edge[1] = TessellationHeuristic(p2, p0);
                    f.edge[2] = TessellationHeuristic(p0, p1);
                    f.inside = (TessellationHeuristic(p1, p2) +
                                TessellationHeuristic(p2, p0) +
                                TessellationHeuristic(p1, p2)) * (1 / 3.0);
                }
                return f;
            }

            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("integer")]
            [UNITY_patchconstantfunc("PatchFunction")]
            TessellationControlPoint hp(InputPatch<TessellationControlPoint, 3> patch, uint id : SV_OUTPUTCONTROLPOINTID) {
                return patch[id];
            }

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

    
                float subFunction = (directionFunc.derivative0 ) * frequency + _Time.y * phase;
    
                results.derivative0 = amplitude * pow(EulerNumber, sin(subFunction) + steepness);
    
                results.derivatives = frequency * cos(subFunction) * results.derivative0 * directionFunc.derivatives;
       
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
                sumOfWaves.derivative0 -= 2 ;
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


            v2g vp(VertexData v) {
                v2g g;
                v.uv = 0;
                g.worldPos = mul(unity_ObjectToWorld, v.vertex);



                #ifdef ENABLE_WAVES
   
                FunctionResult waveFunction = BrownianWaveGenerator(g.worldPos,_Wave[0]);

                v.vertex += fixed4(0,waveFunction.derivative0,0,0);
                g.height = waveFunction.derivative0;
                #endif



                float4 clipPos = UnityObjectToClipPos(v.vertex);
                float depth = 1 - Linear01Depth(clipPos.z / clipPos.w);

                g.pos = UnityObjectToClipPos(v.vertex);
                g.uv = g.worldPos.xz;
                g.worldPos = mul(unity_ObjectToWorld, v.vertex);
                g.depth = depth;

                UNITY_TRANSFER_FOG(g,g.pos);
                return g;
            }

            #define DP_INTERPOLATE(fieldName) data.fieldName = \
                data.fieldName = patch[0].fieldName * barycentricCoordinates.x + \
                                 patch[1].fieldName * barycentricCoordinates.y + \
                                 patch[2].fieldName * barycentricCoordinates.z;

            [UNITY_domain("tri")]
            v2g dp(TessellationFactors factors, OutputPatch<TessellationControlPoint, 3> patch, float3 barycentricCoordinates : SV_DOMAINLOCATION) {
                VertexData data;
                DP_INTERPOLATE(vertex)
                DP_INTERPOLATE(uv)

                return vp(data);
            }

            [maxvertexcount(3)]
            void gp(triangle v2g g[3], inout TriangleStream<g2f> stream) {
                g2f g0, g1, g2;
                g0.data = g[0];
                g1.data = g[1];
                g2.data = g[2];

                g0.barycentricCoordinates = float2(1, 0);
                g1.barycentricCoordinates = float2(0, 1);
                g2.barycentricCoordinates = float2(0, 0);

                stream.Append(g0);
                stream.Append(g1);
                stream.Append(g2);
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


            float4 fp(g2f f) : SV_TARGET {


                /*
                 struct g2f {
                v2g data;
                float2 barycentricCoordinates : TEXCOORD9;
            };
                struct v2g {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float depth : TEXCOORD2;
                float height : TEXCOORD3;
                UNITY_FOG_COORDS(4)
            };
                */
                float3 normal = calculateNormal(f.data.worldPos,_Wave[0]);

                float3 viewDir = normalize(_WorldSpaceCameraPos - f.data.worldPos );
                float3 N = normal; 
               // Calculate the light direction and half vector 
               float3 L = normalize(_WorldSpaceLightPos0.xyz); 
               float3 H = normalize(L + viewDir); 
               // Compute the diffuse and specular components 
               float diff = max(0, dot(N, L)); 
               float spec = pow(max(0, dot(N, H)), _Shininess * 128.0); 
               // Compute the Fresnel effect 
               float3 V = normalize(viewDir); 
               float fresnel = pow(1.0 - max(0, dot(N, V)), _FresnelPower); 
               // Sample the cubemap for reflections 
               float3 reflectDir = reflect(-V, N); 
               fixed4 reflection = texCUBE(_ReflectionCubemap, reflectDir); 
               reflection *= _ReflectionStrength; 
               // Combine the components with Fresnel effect, reflections, and ambient light

               
              // float4 tipColor = _TipColor * pow( saturate( f.data.height*2 +1), _TipAttenuation);

               fixed4 color =_AmbientStrength* _AmbientColor + _Color * diff + _SpecularColor * spec * fresnel + reflection * fresnel;

             
                // apply fog
                UNITY_APPLY_FOG(f.data.fogCoord, color);
                return color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}

