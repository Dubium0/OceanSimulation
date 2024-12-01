
using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

namespace ProceduralMeshes
{
    [BurstCompile(FloatPrecision.Standard, FloatMode.Fast, CompileSynchronously = true)]
    public struct MeshJob<G, S> : IJobFor
        where G : struct, IMeshGenerator
        where S : struct, IMeshStreams
    {
        G generator;

        [WriteOnly]
        S streams;
        public void Execute(int index)
        {
            generator.Execute(index, streams);
        }

        public static JobHandle ScheduleParallel(
           Mesh mesh,Mesh.MeshData meshData, JobHandle dependency
        )
        {
            
            var job = new MeshJob<G, S>();
            
            job.streams.Setup(
                meshData,
                mesh.bounds = job.generator.Bounds,
                job.generator.VertexCount,
                job.generator.IndexCount
            );
            return job.ScheduleParallel(job.generator.JobLength, 1, dependency);
        }
    }
}
