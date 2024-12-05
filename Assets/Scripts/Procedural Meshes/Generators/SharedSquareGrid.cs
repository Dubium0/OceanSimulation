using UnityEngine;
using UnityEngine.UIElements;
using static Unity.Mathematics.math;
namespace ProceduralMeshes.Generators
{
    public struct SharedSquareGrid : IMeshGenerator
    {

        public int VertexCount => (Resolution + 1) * (Resolution + 1);

        public int IndexCount => 6 * Resolution * Resolution;

        public int JobLength => Resolution + 1;


        public Bounds Bounds => new Bounds(Vector3.zero, new Vector3(1f, 0f, 1f));

        public int Resolution { get; set; }

        public void Execute<S>(int index, S streams) where S : struct, IMeshStreams
        {
            int vertexIndex = (Resolution + 1) * index, triangleIndex = 2 * Resolution * (index - 1);

            var vertex = new Vertex();
            vertex.normal.y = 1f;
            vertex.tangent.xw = float2(1f, -1f);

            vertex.position.x = -0.5f;
            vertex.position.z = (float)index / Resolution - 0.5f;
            vertex.texCoord0.y = (float)index / Resolution;
            streams.SetVertex(vertexIndex, vertex);
            vertexIndex += 1;

            for (int x = 1; x <= Resolution; x++, vertexIndex++, triangleIndex += 2)
            {
                vertex.position.x = (float)x / Resolution - 0.5f;
                vertex.texCoord0.x = (float)x / Resolution;
                streams.SetVertex(vertexIndex, vertex);

                if (index > 0)
                {
                    streams.SetTriangle(
                        triangleIndex + 0, vertexIndex + int3(-Resolution - 2, -1, -Resolution - 1)
                    );
                    streams.SetTriangle(
                        triangleIndex + 1, vertexIndex + int3(-Resolution - 1, -1, 0)
                    );
                }
            }
        }



    }
}

