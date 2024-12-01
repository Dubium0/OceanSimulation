using System.Runtime.InteropServices;
using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;
using Unity.Mathematics;

using static Unity.Mathematics.math;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class AdvancedSingleStreamProceduralMesh : MonoBehaviour
{

    [StructLayout(LayoutKind.Sequential)]
    struct Vertex
    {
        public float3 position, normal;
        public half4 tangent;
        public half2 texCoord0;
    }

    void OnEnable()
    {
        int vertexAttributeCount = 4;
        int vertexCount = 4;
        int triangleIndexCount = 6;

        Mesh.MeshDataArray meshDataArray = Mesh.AllocateWritableMeshData(1);
        Mesh.MeshData meshData = meshDataArray[0];

        var vertexAttributes = new NativeArray<VertexAttributeDescriptor>(
            vertexAttributeCount, Allocator.Temp, NativeArrayOptions.UninitializedMemory
        );
        vertexAttributes[0] = new VertexAttributeDescriptor(dimension:3);

        vertexAttributes[1] = new VertexAttributeDescriptor(
            VertexAttribute.Normal, dimension: 3
        );
        vertexAttributes[2] = new VertexAttributeDescriptor(
            VertexAttribute.Tangent, VertexAttributeFormat.Float16, 4
        );
        vertexAttributes[3] = new VertexAttributeDescriptor(
            VertexAttribute.TexCoord0, VertexAttributeFormat.Float16, 2
        );
        meshData.SetVertexBufferParams(vertexCount, vertexAttributes);
        vertexAttributes.Dispose();

        NativeArray<Vertex> vertices = meshData.GetVertexData<Vertex>();

        half h0 = half(0f), h1 = half(1f);

        var vertex = new Vertex
        {
            normal = back(),
            tangent = half4(h1, h0, h0, half(-1f))
        };

        vertex.position = 0f;
        vertex.texCoord0 = h0;
        vertices[0] = vertex;

        vertex.position = right();
        vertex.texCoord0 = half2(h1, h0);
        vertices[1] = vertex;

        vertex.position = up();
        vertex.texCoord0 = half2(h0, h1);
        vertices[2] = vertex;

        vertex.position = float3(1f, 1f, 0f);
        vertex.texCoord0 = h1;
        vertices[3] = vertex;

        meshData.SetIndexBufferParams(triangleIndexCount, IndexFormat.UInt16);
        NativeArray<ushort> triangleIndices = meshData.GetIndexData<ushort>();
        triangleIndices[0] = 0;
        triangleIndices[1] = 2;
        triangleIndices[2] = 1;
        triangleIndices[3] = 1;
        triangleIndices[4] = 2;
        triangleIndices[5] = 3;

        var bounds = new Bounds(new Vector3(0.5f, 0.5f), new Vector3(1f, 1f));

        meshData.subMeshCount = 1;
        meshData.SetSubMesh(0, new SubMeshDescriptor(0, triangleIndexCount)
        {
            bounds = bounds,
            vertexCount = vertexCount
        }, MeshUpdateFlags.DontRecalculateBounds);

        var mesh = new Mesh
        {
            bounds = bounds,
            name = "Procedural Mesh"
        };
        Mesh.ApplyAndDisposeWritableMeshData(meshDataArray, mesh);

        GetComponent<MeshFilter>().mesh = mesh;
    }
}