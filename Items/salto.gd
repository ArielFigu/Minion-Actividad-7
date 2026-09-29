extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# Incrementa permanentemente la cantidad de saltos del jugador
		body.cantidad_saltos += 1
		queue_free()
