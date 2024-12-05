
using UnityEngine;

using static Unity.Mathematics.math;
namespace ProceduralMeshes.Generators
{
    public struct SquareGrid : IMeshGenerator
    {
        public int VertexCount => 4 * Resolution * Resolution;

        public int IndexCount => 6 * Resolution * Resolution;

        public int JobLength => Resolution;


        public Bounds Bounds => new Bounds(Vector3.zero, new Vector3(1f, 0f, 1f));

        public int Resolution { get; set; }

        public void Execute<S>(int index, S streams) where S : struct, IMeshStreams
        {

            int vertexIndex = 4 * Resolution * index;
            int triangleIndex = 2 * Resolution * index;

            for (int x = 0; x < Resolution; x++, vertexIndex += 4, triangleIndex += 2)
            {
                var xCoordinates = float2(x, x + 1f) / Resolution - 0.5f;
                var zCoordinates = float2(index, index + 1f) / Resolution - 0.5f;

                var vertex = new Vertex();
                vertex.normal.y = 1f;
                vertex.tangent.xw = float2(1f, -1f);

                vertex.position.x = xCoordinates.x;
                vertex.position.z = zCoordinates.x;
                streams.SetVertex(vertexIndex + 0, vertex);

                vertex.position.x = xCoordinates.y;
                vertex.texCoord0 = float2(1f, 0f);
                streams.SetVertex(vertexIndex + 1, vertex);

                vertex.position.x = xCoordinates.x;
                vertex.position.z = zCoordinates.y;
                vertex.texCoord0 = float2(0f, 1f);
                streams.SetVertex(vertexIndex + 2, vertex);

                vertex.position.x = xCoordinates.y;
                vertex.texCoord0 = 1f;
                streams.SetVertex(vertexIndex + 3, vertex);

                streams.SetTriangle(triangleIndex + 0, vertexIndex + int3(0, 2, 1));
                streams.SetTriangle(triangleIndex + 1, vertexIndex + int3(1, 2, 3));
            }

        }
    }
}
