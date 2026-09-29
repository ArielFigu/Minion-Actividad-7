extends Camera3D


@export var mouse_sensitivity := 0.002

@onready var player: CharacterBody3D = get_parent()

var pitch := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		# Giro horizontal para rotar al Player
		player.rotate_y(-event.relative.x * mouse_sensitivity)
		# Giro vertical para rotar la CameraPlayer
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80.0), deg_to_rad(80.0))

		rotation.x = pitch
