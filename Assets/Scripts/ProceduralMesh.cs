using ProceduralMeshes;
using ProceduralMeshes.Generators;
using ProceduralMeshes.Streams;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent (typeof(MeshFilter), typeof(MeshRenderer))]
public class ProceduralMesh : MonoBehaviour
{

    Mesh mesh;
    [SerializeField, Range(1, 50)]
    int resolution = 1;


    public enum MeshType
    {
        SquareGrid, SharedSquareGrid
    };

    [SerializeField]
    MeshType meshType;
    static Dictionary<MeshType, MeshJobScheduleDelegate> jobs = new Dictionary<MeshType, MeshJobScheduleDelegate>
    {
        { MeshType.SquareGrid, MeshJob<SquareGrid, SingleStream>.ScheduleParallel },
        { MeshType.SharedSquareGrid, MeshJob<SharedSquareGrid, SingleStream>.ScheduleParallel }
    };
    void Awake()
    {
        mesh = new Mesh
        {
            name = "Procedural Mesh"
        };
        GenerateMesh();
        GetComponent<MeshFilter>().mesh = mesh;
    }

    private void OnValidate()
    {
        enabled = true;
    }

    private void Update()
    {
        GenerateMesh();
        enabled = false;    
    }
    void GenerateMesh() {
        Mesh.MeshDataArray meshDataArray = Mesh.AllocateWritableMeshData(1);
        Mesh.MeshData meshData = meshDataArray[0];

        jobs[meshType]
            (mesh,
             meshData,
             resolution,
             default )
            .Complete();

        Mesh.ApplyAndDisposeWritableMeshData(meshDataArray, mesh);
    }
}

