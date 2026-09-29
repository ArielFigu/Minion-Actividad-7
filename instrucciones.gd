extends CanvasLayer

# Ruta a tu escena del nivel de prueba (ajusta la ruta según donde tengas guardado tu archivo .tscn)
@export_file("*.tscn") var escena_nivel_test: String = "res://niveltest.tscn"

func _unhandled_input(event: InputEvent) -> void:
	# Detecta si se presionó Enter o la acción ui_accept
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		get_tree().change_scene_to_file(escena_nivel_test)
