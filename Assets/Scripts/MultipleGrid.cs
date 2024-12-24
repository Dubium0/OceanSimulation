

using UnityEngine;

public class MultipleGrid : MonoBehaviour
{

    public GameObject GridTilePrefab;

   

    [Range(1,20)]
    public int DimensionX = 1;
    [Range(1, 20)]
    public int DimensionZ= 1;
    [SerializeField]
    private float stepSize = 1;
    private bool awakeCheck = false;

    private void OnValidate()
    {
        if (awakeCheck)
        {
            if (GridTilePrefab != null)
            {
                DestroyGrid();
                CreateGrid();
            }
        }
    }

    private void Awake()
    {
        if(GridTilePrefab!= null)
        {
            DestroyGrid();
            CreateGrid();
        }
        awakeCheck = true;
    }
    private void DestroyGrid()
    {
        var count = transform.childCount;
        for (int i = 0; i < count; i++)
        {
            var obj = transform.GetChild(i).gameObject;
            if (obj != null)
            {
                if (Application.isEditor && !Application.isPlaying)
                {
                    UnityEngine.Object.DestroyImmediate(obj);
                }
                else
                {
                    UnityEngine.Object.Destroy(obj);
                }
            }
        }

    }
    private void CreateGrid()
    {   
        
        for (int x = 0; x < DimensionX; x++)
        {
            for (int y = 0; y < DimensionZ; y++)
            {
                Instantiate(GridTilePrefab,new Vector3(x, 0, y) * transform.localScale.x * stepSize, Quaternion.identity,transform);

            }
        }

    }
}
