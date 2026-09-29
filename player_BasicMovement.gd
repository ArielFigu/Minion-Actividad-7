extends CharacterBody3D

@export var camara_controller: Node3D
@export var skin: Node3D
@export var raycast_3d: RayCast3D
@export var shape_cast_gancho: ShapeCast3D
@export var linea_gancho: MeshInstance3D

@export var SPEED: float = 5.0
@export var JUMP_VELOCITY: float = 4.5
@export var rotation_speed: float = 10.0
@export var gravedad: float = 18.0
@export var cantidad_saltos: int = 2
@export var pausa_entre_saltos: float = 0.03
@export var aceleracion: float = 0.02
@export var velocidad_minima_wall_run: float = 0.06
@export var tiempo_sin_avanzar_wall: float = 0.03

@export var wall_jump_up_force: float = 5.5
@export var wall_jump_out_force: float = 6.0
@export var tiempo_agarre_pared: float = 0.08


@export var distancia_gancho: float = 25.0
@export var velocidad_gancho: float = 30.0
@export var velocidad_disparo_gancho: float = 60.0

var velocidad_inicial: float
var saltos_realizados: int = 0
var tiempo_salto: float = 0.0
var haciendo_wall_run: bool = false
var tiempo_sin_avanzar: float = 0.0
var velocidad_wall_run: float = 0.0

var agarrado_a_pared: bool = false
var timer_agarre: float = 0.0
var ya_se_agarro_en_este_salto: bool = false

var tiene_dash: bool = false
@export var distancia_dash: float = 5.0

@export var tiene_gancho: bool = true
var disparando_gancho: bool = false
var enganchado: bool = false
var punto_objetivo_gancho: Vector3 = Vector3.ZERO
var posicion_punta_gancho: Vector3 = Vector3.ZERO


func _ready() -> void:
	velocidad_inicial = SPEED
	add_to_group("player")
	if linea_gancho:
		linea_gancho.visible = false


func _physics_process(delta: float) -> void:
	tiempo_salto -= delta

	if Input.is_key_pressed(KEY_F) and tiene_dash:
		hacer_dash()

	if Input.is_key_pressed(KEY_G):
		if tiene_gancho and not enganchado and not disparando_gancho:
			usar_gancho()

	if disparando_gancho:
		procesar_lanzamiento_gancho(delta)
	elif enganchado:
		procesar_atraccion_gancho(delta)
	elif agarrado_a_pared:
		procesar_agarre_pared(delta)
	elif haciendo_wall_run:
		procesar_wall_run(delta)
	else:
		procesar_movimiento(delta)

	move_and_slide()
	comprobar_colisiones_meta()


func comprobar_colisiones_meta() -> void:
	for i in range(get_slide_collision_count()):
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		if objeto and (objeto.is_in_group("meta") or "meta" in objeto.name.to_lower()):
			get_tree().quit()


func procesar_movimiento(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0
		saltos_realizados = 0
		ya_se_agarro_en_este_salto = false

	if Input.is_action_just_pressed("ui_accept"):
		intentar_salto()

	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if not Input.is_action_pressed("ui_up"):
		SPEED = velocidad_inicial

	var move_direction = get_move_direction(input_dir)

	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		rotate_character(move_direction, delta)

		if Input.is_action_pressed("ui_up") and is_on_floor():
			SPEED += velocidad_inicial * aceleracion * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)

	if not is_on_floor() and is_on_wall():
		if not ya_se_agarro_en_este_salto:
			iniciar_agarre_pared()
		elif velocidad_puede_hacer_wall_run() and Input.is_action_pressed("ui_up"):
			iniciar_wall_run()


func iniciar_agarre_pared() -> void:
	agarrado_a_pared = true
	ya_se_agarro_en_este_salto = true
	timer_agarre = tiempo_agarre_pared
	saltos_realizados = 0
	velocity = Vector3.ZERO


func procesar_agarre_pared(delta: float) -> void:
	timer_agarre -= delta
	velocity = Vector3.ZERO

	if Input.is_action_just_pressed("ui_accept"):
		ejecutar_wall_jump()
		agarrado_a_pared = false
		return

	if timer_agarre <= 0.0:
		agarrado_a_pared = false
		if velocidad_puede_hacer_wall_run() and Input.is_action_pressed("ui_up") and is_on_wall():
			iniciar_wall_run()


func intentar_salto() -> void:
	if saltos_realizados >= cantidad_saltos:
		return

	if tiempo_salto > 0:
		return

	saltos_realizados += 1
	tiempo_salto = pausa_entre_saltos
	velocity.y = JUMP_VELOCITY
	ya_se_agarro_en_este_salto = false

	if not is_on_floor():
		if velocidad_puede_hacer_wall_run():
			if is_on_wall() and Input.is_action_pressed("ui_up"):
				iniciar_wall_run()


func velocidad_puede_hacer_wall_run() -> bool:
	return SPEED >= velocidad_inicial * (1.0 + velocidad_minima_wall_run)


func iniciar_wall_run() -> void:
	haciendo_wall_run = true
	tiempo_sin_avanzar = 0.0
	velocidad_wall_run = SPEED
	velocity.y = 0
	saltos_realizados = 0


func procesar_wall_run(delta: float) -> void:
	if not is_on_wall():
		haciendo_wall_run = false
		velocity.y -= gravedad * delta
		return

	if Input.is_action_just_pressed("ui_accept"):
		ejecutar_wall_jump()
		return

	if not Input.is_action_pressed("ui_up"):
		tiempo_sin_avanzar += delta
		if tiempo_sin_avanzar >= tiempo_sin_avanzar_wall:
			haciendo_wall_run = false
			velocity.y -= gravedad * delta
		return

	tiempo_sin_avanzar = 0.0
	velocity.y = 0

	var input_dir := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var move_direction = get_move_direction(input_dir)

	if move_direction:
		velocity.x = move_direction.x * velocidad_wall_run
		velocity.z = move_direction.z * velocidad_wall_run
		rotate_character(move_direction, delta)


func ejecutar_wall_jump() -> void:
	haciendo_wall_run = false
	agarrado_a_pared = false
	saltos_realizados = 1
	tiempo_salto = pausa_entre_saltos

	var wall_normal = get_wall_normal()

	velocity.y = wall_jump_up_force
	velocity.x = wall_normal.x * wall_jump_out_force
	velocity.z = wall_normal.z * wall_jump_out_force

	var jump_direction = Vector3(wall_normal.x, 0, wall_normal.z).normalized()
	if jump_direction != Vector3.ZERO:
		skin.rotation.y = atan2(-jump_direction.x, -jump_direction.z)


func hacer_dash() -> void:
	tiene_dash = false

	var direccion = camara_controller.get_forward_direction()
	direccion.y = 0
	direccion = direccion.normalized()

	raycast_3d.target_position = direccion * distancia_dash
	raycast_3d.force_raycast_update()

	if raycast_3d.is_colliding():
		var objeto = raycast_3d.get_collider()

		if objeto.is_in_group("pared_rompible"):
			objeto.queue_free()
			global_position += direccion * distancia_dash
		else:
			var punto = raycast_3d.get_collision_point()
			global_position = punto - direccion * 0.5
	else:
		global_position += direccion * distancia_dash


func usar_gancho() -> void:
	if not shape_cast_gancho or not camara_controller:
		return

	shape_cast_gancho.add_exception(self)

	var dir_camara: Vector3 = -camara_controller.global_transform.basis.z.normalized()
	shape_cast_gancho.target_position = shape_cast_gancho.global_transform.basis.inverse() * (dir_camara * distancia_gancho)
	shape_cast_gancho.force_shapecast_update()

	if not shape_cast_gancho.is_colliding():
		return

	var conteo = shape_cast_gancho.get_collision_count()
	for i in range(conteo):
		var objeto = shape_cast_gancho.get_collider(i)
		if not objeto:
			continue

		var nodo_padre = objeto.get_parent()
		var nombre_objeto = objeto.name.to_lower()
		var nombre_padre = nodo_padre.name.to_lower() if nodo_padre else ""

		var es_por_grupo = objeto.is_in_group("punto_gancho") or (nodo_padre and nodo_padre.is_in_group("punto_gancho"))
		var es_por_nombre = "puntogancho" in nombre_objeto or "gancho" in nombre_objeto or "puntogancho" in nombre_padre or "gancho" in nombre_padre

		if es_por_grupo or es_por_nombre:
			var objetivo = objeto
			if nodo_padre and ("puntogancho" in nombre_padre or nodo_padre.is_in_group("punto_gancho")):
				objetivo = nodo_padre
			
			punto_objetivo_gancho = objetivo.global_position
			disparando_gancho = true
			posicion_punta_gancho = global_position
			saltos_realizados = 0
			break


func procesar_lanzamiento_gancho(delta: float) -> void:
	posicion_punta_gancho = posicion_punta_gancho.move_toward(
		punto_objetivo_gancho, 
		velocidad_disparo_gancho * delta
	)

	actualizar_cable_gancho(global_position, posicion_punta_gancho)

	if posicion_punta_gancho.distance_to(punto_objetivo_gancho) < 0.3:
		disparando_gancho = false
		enganchado = true


func procesar_atraccion_gancho(_delta: float) -> void:
	var distancia = global_position.distance_to(punto_objetivo_gancho)
	var direccion = (punto_objetivo_gancho - global_position).normalized()
	velocity = direccion * velocidad_gancho
	actualizar_cable_gancho(global_position, punto_objetivo_gancho)

	if distancia < 1.5 or Input.is_action_just_pressed("ui_accept"):
		enganchado = false
		if linea_gancho:
			linea_gancho.visible = false


func actualizar_cable_gancho(origen: Vector3, destino: Vector3) -> void:
	if not linea_gancho:
		return

	var distancia = origen.distance_to(destino)

	if distancia < 0.05:
		linea_gancho.visible = false
		return

	linea_gancho.visible = true

	var medio = (origen + destino) / 2.0
	var dir = (destino - origen).normalized()

	var up_vector = Vector3.UP
	if abs(dir.dot(Vector3.UP)) > 0.99:
		up_vector = Vector3.FORWARD

	var nueva_base = Basis.looking_at(dir, up_vector)
	nueva_base = nueva_base.rotated(Vector3.RIGHT, PI / 2.0)

	linea_gancho.global_transform = Transform3D(nueva_base, medio)
	linea_gancho.scale = Vector3(1.0, distancia, 1.0)


func get_move_direction(input_dir: Vector2) -> Vector3:
	var forward = camara_controller.get_forward_direction()
	var right = camara_controller.get_right_direction()

	return (
		forward * -input_dir.y +
		right * input_dir.x
	).normalized()


func rotate_character(move_direction: Vector3, delta: float) -> void:
	var target_rotation = atan2(
		-move_direction.x,
		-move_direction.z
	)

	var new_rotation = lerp_angle(
		skin.rotation.y,
		target_rotation,
		rotation_speed * delta
	)

	skin.rotation.y = new_rotation
	skin.rotation.y = new_rotation
