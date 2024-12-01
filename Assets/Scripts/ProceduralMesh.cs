using ProceduralMeshes;
using ProceduralMeshes.Generators;
using ProceduralMeshes.Streams;
using UnityEngine;

[RequireComponent (typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralMesh : MonoBehaviour
{

    Mesh mesh;

    void Awake()
    {
        mesh = new Mesh
        {
            name = "Procedural Mesh"
        };
        GenerateMesh();
        GetComponent<MeshFilter>().mesh = mesh;
    }

    void GenerateMesh() {
        Mesh.MeshDataArray meshDataArray = Mesh.AllocateWritableMeshData(1);
        Mesh.MeshData meshData = meshDataArray[0];

        MeshJob<SquareGrid, SingleStream>.ScheduleParallel(
            mesh,
            meshData,
            default
        ).Complete();

        Mesh.ApplyAndDisposeWritableMeshData(meshDataArray, mesh);
    }
}

