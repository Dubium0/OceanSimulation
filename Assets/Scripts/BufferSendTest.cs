
using System.Collections.Generic;
using UnityEngine;

public class BufferSendTest : MonoBehaviour
{

    public Material material;
    [System.Serializable]
    public struct CustomData
    {
        // Properties
        public Vector4  DiffuseColor;
        public Vector4  AmbientColor;
        public Vector4  SpecularColor;

        public float    AmbientStrength;
        public float    Shininess;

    }

    public List<CustomData> customDatas = new();
    private ComputeBuffer buffer;

    void Start()
    {
        // Example data
        CustomData[] data = customDatas.ToArray();


        // Create structured buffer
        buffer = new ComputeBuffer(data.Length, sizeof(float) * 14); // 3 floats for position + 4 floats for color
        buffer.SetData(data);

        // Pass the buffer to the material
        material.SetBuffer("_CustomBuffer", buffer);
    }

    void OnDestroy()
    {
        // Release buffer
        if (buffer != null) buffer.Release();
    }
}


