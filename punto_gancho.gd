extends Area3D # Cambia a StaticBody3D si tu nodo es un StaticBody3D

func _enter_tree() -> void:
	add_to_group("punto_gancho")

func _ready() -> void:
	if not is_in_group("punto_gancho"):
		add_to_group("punto_gancho")
