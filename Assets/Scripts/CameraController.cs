using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.InputSystem;

[RequireComponent(typeof(Camera))]
public class CameraController : MonoBehaviour
{

    InputAction lookAction_;
    InputAction moveAction_;
    InputAction bounceAction_;
    [SerializeField]
    private float movementSpeed_;

    [SerializeField]
    private float rotationSpeed;
    private void Awake()
    {
        lookAction_ = InputSystem.actions.FindAction("Look");
        moveAction_ = InputSystem.actions.FindAction("Move");
        bounceAction_ = InputSystem.actions.FindAction("Bounce");
    }

    private void Update()
    {
        Move();
    }
    private void Move()
    {
        var inputMovementVector = moveAction_.ReadValue<Vector2>();


        transform.position += transform.forward * inputMovementVector.y * movementSpeed_ * Time.deltaTime; // W-S
        transform.position += transform.right * inputMovementVector.x * movementSpeed_ * Time.deltaTime;// A-D
        transform.position += transform.up * bounceAction_.ReadValue<float>() * movementSpeed_ * Time.deltaTime;

        var inputLookVector = lookAction_.ReadValue<Vector2>();
        inputLookVector  *= rotationSpeed * Time.deltaTime;
        var offSetRotation = new Vector3(-inputLookVector.y, inputLookVector.x, 0);
        transform.rotation = Quaternion.Euler(transform.eulerAngles + offSetRotation);
    }


}