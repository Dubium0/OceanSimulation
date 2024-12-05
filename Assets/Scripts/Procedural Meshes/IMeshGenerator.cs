

using UnityEngine;

namespace ProceduralMeshes
{
    public interface IMeshGenerator
    {
        void Execute<S> (int index, S streams) where S : struct, IMeshStreams;

        int VertexCount { get; }

        int IndexCount { get; }

        int JobLength { get; }

        Bounds Bounds { get; }

        int Resolution { get; set; }
    }
}
