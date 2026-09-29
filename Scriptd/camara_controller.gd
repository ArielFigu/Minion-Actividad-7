extends Node3D
@export var mouse_sensitivity: float= 0.003
@onready var camara: Camera3D = $SpringArm3D/Camera3D
@onready var spring_arm: SpringArm3D = $SpringArm3D

var h_rotation : float= 0.00
var v_rotation : float= 0.00

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED



func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_camara (event.relative)

func rotate_camara(mouse_delta:Vector2):
	h_rotation -= mouse_delta.x*mouse_sensitivity
	rotation.y = h_rotation
	v_rotation-= mouse_delta.y*mouse_sensitivity
	v_rotation=clamp(v_rotation,deg_to_rad(-60),deg_to_rad(40))
	spring_arm.rotation.x =v_rotation
	
func get_forward_direction() -> Vector3:
	var forward = -camara.global_transform.basis.z
	return forward
func get_right_direction() -> Vector3:
	var right = camara.global_transform.basis.x
	return right
