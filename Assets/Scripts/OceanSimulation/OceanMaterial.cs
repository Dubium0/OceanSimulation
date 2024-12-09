using Unity.Mathematics;
using UnityEngine;


namespace OceanSimulation
{



    [CreateAssetMenu(fileName = "Ocean Material Preset", menuName = "Ocean Simulation/Ocean Material Preset")]
    public class OceanMaterial : ScriptableObject
    {

        public struct GPUOceanMaterial
        {
            public Vector3 diffuse;
            public Vector3 ambient;
            public Vector3 specular;
            public Vector3 fresnelColor;
            public float shininess;
            public float fresnelStrength;
            public float fresnelBias;
            public float fresnelShininess;
        }

        public static int GetGPUOceanMaterialByteSize()
        {
            return sizeof(float) * 16;
        }

        public Color diffuse;
        public Color ambient;
        public Color specular;
        public Color fresnelColor;
        public float shininess;
        public float fresnelStrength;
        public float fresnelBias;
        public float fresnelShininess;


        public GPUOceanMaterial GetGpuWritableData()
        {
            GPUOceanMaterial gpuOceanMaterial = new GPUOceanMaterial();
            gpuOceanMaterial.diffuse = new Vector3(diffuse.r,diffuse.g,diffuse.b);
            gpuOceanMaterial.ambient = new Vector3(ambient.r,ambient.g,ambient.b);
            gpuOceanMaterial.specular = new Vector3(specular.r, specular.g, specular.b);
            gpuOceanMaterial.fresnelColor = new Vector3(fresnelColor.r, fresnelColor.g, fresnelColor.b);
        
            gpuOceanMaterial.shininess = shininess;
     
            gpuOceanMaterial.fresnelStrength = fresnelStrength;
            gpuOceanMaterial.fresnelBias = fresnelBias;
            gpuOceanMaterial.fresnelShininess = fresnelShininess;
         

            return gpuOceanMaterial;

        }


    }

}