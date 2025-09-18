extends Node2D

@onready var score_label = $UI/TopBar/HBoxContainer/ScoreLabel
@onready var time_label = $UI/TopBar/HBoxContainer/TimeLabel
@onready var targets_label = $UI/TopBar/HBoxContainer/TargetsLabel
@onready var instructions = $UI/Instructions
@onready var game_over_label = $UI/GameOverLabel
@onready var targets_container = $TargetsContainer
@onready var target_template = $TargetsContainer/Target
@onready var game_timer = $GameTimer
@onready var spawn_timer = $SpawnTimer

var score: int = 0
var targets_hit: int = 0
var time_left: float = 30.0
var is_game_active: bool = false
var active_targets: Array[Area2D] = []

func _ready():
	print("ClickTheTarget: _ready() called")
	target_template.visible = false
	instructions.visible = true
	game_over_label.visible = false

	# Asegurar que la UI no bloquee los clics
	$UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in $UI.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	print("Target template: ", target_template)
	print("Target template has collision shape: ", target_template.has_node("CollisionShape2D"))

	await get_tree().create_timer(2.0).timeout
	start_game()

func start_game():
	is_game_active = true
	instructions.visible = false
	score = 0
	targets_hit = 0
	time_left = 10.0

	var spawn_rate = 1.5 / get_spawn_rate()
	spawn_timer.wait_time = spawn_rate
	spawn_timer.start()

	game_timer.wait_time = 10.0
	game_timer.start()

	spawn_target()

func _process(delta):
	if is_game_active:
		time_left -= delta
		update_ui()

func update_ui():
	score_label.text = "Puntos: " + str(score)
	time_label.text = "Tiempo: " + str(int(ceil(time_left)))
	targets_label.text = "Objetivos: " + str(targets_hit)

func spawn_target():
	if not is_game_active:
		return

	# Crear un nuevo Area2D desde cero
	var new_target = Area2D.new()
	new_target.input_pickable = true
	new_target.monitoring = true

	# Crear y añadir CollisionShape2D (más pequeño)
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 25.0  # Reducido de 40 a 25
	collision.shape = circle_shape
	new_target.add_child(collision)

	# Crear visual (más pequeño)
	var visual = Node2D.new()
	visual.name = "Visual"

	# Círculo exterior (rojo)
	var outer_circle = ColorRect.new()
	outer_circle.size = Vector2(50, 50)  # Reducido de 80x80
	outer_circle.position = Vector2(-25, -25)
	outer_circle.color = Color(1, 0.2, 0.2, 1)
	outer_circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(outer_circle)

	# Círculo medio (blanco)
	var middle_circle = ColorRect.new()
	middle_circle.size = Vector2(30, 30)  # Reducido de 50x50
	middle_circle.position = Vector2(-15, -15)
	middle_circle.color = Color(1, 1, 1, 1)
	middle_circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(middle_circle)

	# Círculo interior (rojo)
	var inner_circle = ColorRect.new()
	inner_circle.size = Vector2(10, 10)  # Reducido de 20x20
	inner_circle.position = Vector2(-5, -5)
	inner_circle.color = Color(1, 0.2, 0.2, 1)
	inner_circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.add_child(inner_circle)

	new_target.add_child(visual)

	# Márgenes más grandes para forzar movimiento del mouse
	var margin_x = 150  # Más margen horizontal
	var margin_y = 120  # Evitar la barra superior
	var bottom_margin = 80
	var random_x = randf_range(margin_x, 1152 - margin_x)
	var random_y = randf_range(margin_y, 648 - bottom_margin)
	new_target.position = Vector2(random_x, random_y)

	targets_container.add_child(new_target)
	active_targets.append(new_target)

	print("Target spawned at position: ", new_target.position)
	print("Active targets count: ", active_targets.size())

	# Conectar señal para detectar clics
	new_target.input_event.connect(func(_viewport, event, _shape_idx):
		print("Input event detected on target")
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Left click detected!")
			if is_game_active and new_target in active_targets:
				print("Hit target confirmed!")
				hit_target(new_target)
	)

	# Tiempo de vida ajustado por dificultad
	var base_lifetime = 1.5  # 1.5 segundos base
	var difficulty_multiplier = get_reaction_time() / 2.0  # Ajustado por dificultad
	var lifetime_timer = Timer.new()
	lifetime_timer.wait_time = base_lifetime * difficulty_multiplier
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_target_expired.bind(new_target))
	new_target.add_child(lifetime_timer)
	lifetime_timer.start()

	animate_target_spawn(new_target)

func animate_target_spawn(target: Area2D):
	var tween = create_tween()
	target.scale = Vector2(0.1, 0.1)
	tween.tween_property(target, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hit_target(target: Area2D):
	print("HIT_TARGET CALLED!")
	active_targets.erase(target)
	targets_hit += 1
	print("Targets hit: ", targets_hit)

	var reaction_time = get_reaction_time()
	var time_bonus = 0
	for child in target.get_children():
		if child is Timer:
			time_bonus = int((child.time_left / reaction_time) * 10)
			break

	var base_points = 10
	var difficulty_multiplier = get_difficulty_multiplier()
	var points = int((base_points + time_bonus) * difficulty_multiplier)

	score += points

	# Mostrar popup de puntos en la posición correcta
	var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
	add_child(popup)
	popup.setup(points, target.position)

	var tween = create_tween()
	tween.tween_property(target, "scale", Vector2(1.5, 1.5), 0.1)
	tween.parallel().tween_property(target, "modulate", Color(1, 1, 1, 0), 0.1)
	tween.tween_callback(target.queue_free)

func _on_target_expired(target: Area2D):
	if target in active_targets:
		active_targets.erase(target)

		# Restar puntos por target perdido
		var penalty = -5
		score += penalty
		score = max(0, score)  # No permitir puntuación negativa

		# Mostrar popup de puntos negativos
		var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
		add_child(popup)
		popup.setup(penalty, target.position)

		print("Target missed! Score penalty: ", penalty)

		var tween = create_tween()
		tween.tween_property(target, "modulate", Color(0.5, 0.5, 0.5, 0), 0.3)
		tween.tween_callback(target.queue_free)

func _on_spawn_timer_timeout():
	if is_game_active:
		spawn_target()

		# Más probabilidad de múltiples targets
		if randf() < 0.6:  # 60% de probabilidad
			spawn_target()

		if randf() < 0.3:  # 30% de probabilidad de un tercero
			spawn_target()

func _on_game_timer_timeout():
	end_game()

func end_game():
	is_game_active = false
	spawn_timer.stop()

	for target in active_targets:
		target.queue_free()
	active_targets.clear()

	game_over_label.visible = true

	# Mostrar resultado basado en puntuación
	if score >= 100:
		game_over_label.text = "¡OBJETIVO CONSEGUIDO!\n" + str(score) + " puntos"
		game_over_label.modulate = Color.GREEN
	else:
		game_over_label.text = "¡TIEMPO!\nNecesitas 100 puntos\nConseguiste: " + str(score)
		game_over_label.modulate = Color.RED

	# Victoria si consigue 100+ puntos
	var won = score >= 100
	await get_tree().create_timer(3.0).timeout

	GameManager.complete_minigame(won, score)

func get_reaction_time() -> float:
	"""Get reaction time based on difficulty (for minigames)"""
	match GameManager.get_difficulty():
		GameManager.Difficulty.EASY:
			return 2.5  # 2.5 seconds
		GameManager.Difficulty.NORMAL:
			return 2.0  # 2.0 seconds
		GameManager.Difficulty.HARD:
			return 1.2  # 1.2 seconds
		_:
			return 2.0

func get_spawn_rate() -> float:
	"""Get spawn rate multiplier based on difficulty"""
	match GameManager.get_difficulty():
		GameManager.Difficulty.EASY:
			return 0.7  # Slower spawning
		GameManager.Difficulty.NORMAL:
			return 1.0  # Normal rate
		GameManager.Difficulty.HARD:
			return 1.4  # Faster spawning
		_:
			return 1.0
			
func get_difficulty_multiplier() -> float:
	"""Get difficulty multiplier for scoring"""
	match GameManager.get_difficulty():
		GameManager.Difficulty.EASY:
			return 0.8
		GameManager.Difficulty.NORMAL:
			return 1.0
		GameManager.Difficulty.HARD:
			return 1.5
		_:
			return 1.0
