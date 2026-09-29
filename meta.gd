extends Area3D

@export var ruta_escena_victoria: String = "res://escena_victoria.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		finalizar_juego()

func finalizar_juego() -> void:
	get_tree().change_scene_to_file(ruta_escena_victoria)
