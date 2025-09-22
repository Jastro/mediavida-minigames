extends Node2D

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel
@onready var round_label: Label = %RoundLabel
@onready var difficulty_label: Label = %DifficultyLabel
@onready var instructions: Label = %Instructions
@onready var game_over_label: Label = %GameOverLabel

@onready var cards_container = $CardsContainer
@onready var response_timer = $ResponseTimer

const BACK = preload("uid://dkmfojomb80fy")
const EIGHT = preload("uid://du6xcrnsw2afy")
const FIVE = preload("uid://cpqvq6lcffjow")
const JACK = preload("uid://bf2ixuv61idsp")
const NINE = preload("uid://dq33c7fdapt8m")
const QUEEN_HEARTS = preload("uid://ffk3sm3igtn1")
const SEVEN = preload("uid://dejtxdo603b4")
const TWO = preload("uid://ccujedag7y5i3")

var score: int = 0
var current_round: int = 1
var total_time: float = 0.0
var is_game_active: bool = false
var is_responding: bool = false
var queen_card_index: int = 0
var cards: Array[Node2D] = []
var card_positions: Array[Vector2] = []
var response_start_time: float = 0.0

# Configuración de rondas
var round_config = {
	1: {
		"cards": 2,
		"shuffle_duration": 4.0
	},
	2: {
		"cards": 3,
		"shuffle_duration": 5.0
	},
	3: {
		"cards": 4,
		"shuffle_duration": 6.0
	}
}

func _ready():
	instructions.visible = true
	game_over_label.visible = false
	
	# Configurar UI para que no interfiera con clics
	$UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in $UI.get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	await get_tree().create_timer(2.0).timeout
	start_game()

func start_game():
	is_game_active = true
	instructions.visible = false
	score = 0
	current_round = 1
	total_time = 0.0
	start_round()

func start_round():
	clear_cards()
	setup_round()
	show_cards_face_up()
	
	# Mostrar cartas por 2 segundos antes de voltear
	await get_tree().create_timer(2.0).timeout
	flip_cards_down()
	
	await get_tree().create_timer(0.5).timeout
	shuffle_cards()

func setup_round():
	var config = get_difficulty_config()
	var num_cards = config.cards_per_round[current_round - 1]  # Número de cartas por dificultad
	var card_spacing = 120
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (1152 - total_width) / 2
	
	# Calcular posiciones de las cartas
	card_positions.clear()
	for i in range(num_cards):
		var pos = Vector2(start_x + i * card_spacing, 324)
		card_positions.append(pos)
	
	# Crear cartas
	cards.clear()
	queen_card_index = randi() % num_cards
	
	for i in range(num_cards):
		var card = create_card(i == queen_card_index)
		card.position = card_positions[i]
		cards_container.add_child(card)
		cards.append(card)

func create_card(is_queen: bool) -> Node2D:
	var card = Node2D.new()
	
	# Área clickeable
	var area = Area2D.new()
	area.input_pickable = true
	
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(80, 120)
	collision.shape = rect_shape
	area.add_child(collision)
	
	# Visual del dorso (siempre la misma imagen)
	var back = Sprite2D.new()
	back.texture = BACK
	back.name = "Back"
	
	# Visual del frente
	var front = Sprite2D.new()
	front.name = "Front"
	
	if is_queen:
		front.texture = QUEEN_HEARTS
	else:
		# Carta aleatoria de relleno
		var filler_cards = [TWO, FIVE, SEVEN, EIGHT, NINE, JACK]
		front.texture = filler_cards[randi() % filler_cards.size()]
	
	card.add_child(area)
	card.add_child(back)
	card.add_child(front)
	
	# Inicialmente mostrar el frente
	back.visible = false
	front.visible = true
	
	# Conectar clic pasando la referencia de la carta
	area.input_event.connect(_on_card_clicked.bind(card))
	
	return card

func show_cards_face_up():
	for card in cards:
		card.get_node("Back").visible = false
		card.get_node("Front").visible = true

func flip_cards_down():
	for card in cards:
		var tween = create_tween()
		tween.tween_property(card, "scale:x", 0.0, 0.2)
		tween.tween_callback(func():
			card.get_node("Back").visible = true
			card.get_node("Front").visible = false
		)
		tween.tween_property(card, "scale:x", 1.0, 0.2)

func shuffle_cards():
	var shuffle_steps = get_shuffle_steps_for_round()  # Número variable de pasos
	var config = get_difficulty_config()
	
	for step in range(shuffle_steps):
		await perform_shuffle_step()
		# Delay entre steps según dificultad
		if step < shuffle_steps - 1:  # No esperar después del último step
			await get_tree().create_timer(config.step_delay).timeout
	
	enable_card_selection()

func get_shuffle_steps_for_round() -> int:
	match current_round:
		1:
			return 6
		2:
			return 8
		3:
			return 10
		_:
			return 6

func get_difficulty_config():
	"""Obtener configuración basada en la dificultad actual"""
	var difficulty = GameManager.get_difficulty()
	
	match difficulty:
		GameManager.Difficulty.EASY:
			return {
				"step_delay": 0.3,
				"shuffle_speed_multiplier": 1.5,
				"response_time_free": 1.0,
				"response_time_total": 6.0,
				"points": [15, 35, 50],
				"min_points": [3, 7, 10],
				"cards_per_round": [2, 3, 4]
			}
		GameManager.Difficulty.NORMAL:
			return {
				"step_delay": 0.1,
				"shuffle_speed_multiplier": 1.0,
				"response_time_free": 1.0,
				"response_time_total": 3.0,
				"points": [20, 40, 60],
				"min_points": [4, 8, 12],
				"cards_per_round": [3, 4, 5]
			}
		GameManager.Difficulty.HARD:
			return {
				"step_delay": 0.1,
				"shuffle_speed_multiplier": 0.7,
				"response_time_free": 0.5,
				"response_time_total": 2.0,
				"points": [25, 50, 75],
				"min_points": [5, 10, 15],
				"cards_per_round": [4, 5, 6]
			}
		_:
			# Default a normal
			return {
				"step_delay": 0.1,
				"shuffle_speed_multiplier": 1.0,
				"response_time_free": 1.0,
				"response_time_total": 3.0,
				"points": [20, 40, 60],
				"min_points": [4, 8, 12],
				"cards_per_round": [3, 4, 5]
			}

func perform_shuffle_step():
	var num_cards = cards.size()
	
	# Decidir qué cartas participan en este paso
	var pairs_to_swap = []
	var cards_involved = []
	
	# Crear pares de cartas adyacentes que pueden intercambiarse
	var available_positions = range(num_cards)
	
	while available_positions.size() >= 2:
		# Elegir dos posiciones adyacentes aleatoriamente
		var pos1 = available_positions[randi() % available_positions.size()]
		available_positions.erase(pos1)
		
		# Buscar una posición adyacente disponible
		var adjacent_positions = []
		if pos1 > 0 and available_positions.has(pos1 - 1):
			adjacent_positions.append(pos1 - 1)
		if pos1 < num_cards - 1 and available_positions.has(pos1 + 1):
			adjacent_positions.append(pos1 + 1)
		
		if adjacent_positions.size() > 0:
			var pos2 = adjacent_positions[randi() % adjacent_positions.size()]
			available_positions.erase(pos2)
			
			# 70% probabilidad de intercambio real
			if randf() < 0.7:
				pairs_to_swap.append([pos1, pos2])
			
			cards_involved.append(pos1)
			cards_involved.append(pos2)
		else:
			cards_involved.append(pos1)
	
	# Agregar cartas restantes que harán movimiento decoy
	for i in range(num_cards):
		if not cards_involved.has(i):
			cards_involved.append(i)
	
	# Ejecutar movimientos simultáneamente
	var tweens = []
	
	for pair in pairs_to_swap:
		var pos1 = pair[0]
		var pos2 = pair[1]
		var card1 = cards[pos1]
		var card2 = cards[pos2]
		
		# Intercambio real con semi-círculos
		var tween_pair = perform_card_swap(card1, card2, pos1, pos2)
		tweens.append_array(tween_pair)
		
		# Actualizar índice de la reina
		if pos1 == queen_card_index:
			queen_card_index = pos2
		elif pos2 == queen_card_index:
			queen_card_index = pos1
		
		# Intercambiar en el array
		cards[pos1] = card2
		cards[pos2] = card1
	
	# Movimientos decoy para cartas no involucradas en intercambios
	for i in range(num_cards):
		var is_in_swap = false
		for pair in pairs_to_swap:
			if i in pair:
				is_in_swap = true
				break
		
		if not is_in_swap:
			var card = cards[i]
			var tween = perform_decoy_movement(card, card_positions[i])
			tweens.append(tween)
	
	# Esperar a que terminen todos los movimientos
	if tweens.size() > 0:
		await tweens[0].finished

func perform_card_swap(card1: Node2D, card2: Node2D, pos1: int, pos2: int) -> Array:
	var config = get_difficulty_config()
	var base_duration = 0.2 * config.shuffle_speed_multiplier
	
	var start_pos1 = card_positions[pos1]
	var start_pos2 = card_positions[pos2]
	var end_pos1 = card_positions[pos2]
	var end_pos2 = card_positions[pos1]
	
	# Determinar dirección del intercambio (aleatoria)
	var clockwise = randf() < 0.5
	
	# Crear puntos de control para los semi-círculos
	var mid_x = (start_pos1.x + start_pos2.x) / 2
	var arc_height = 80  # Altura del arco
	
	var control1: Vector2
	var control2: Vector2
	
	if clockwise:
		# Carta izquierda va por arriba, derecha por abajo
		if pos1 < pos2:  # pos1 está a la izquierda
			control1 = Vector2(mid_x, start_pos1.y - arc_height)  # Arriba
			control2 = Vector2(mid_x, start_pos2.y + arc_height)  # Abajo
		else:  # pos2 está a la izquierda
			control1 = Vector2(mid_x, start_pos1.y + arc_height)  # Abajo
			control2 = Vector2(mid_x, start_pos2.y - arc_height)  # Arriba
	else:
		# Invertir direcciones
		if pos1 < pos2:
			control1 = Vector2(mid_x, start_pos1.y + arc_height)  # Abajo
			control2 = Vector2(mid_x, start_pos2.y - arc_height)  # Arriba
		else:
			control1 = Vector2(mid_x, start_pos1.y - arc_height)  # Arriba
			control2 = Vector2(mid_x, start_pos2.y + arc_height)  # Abajo
	
	# Crear tweens para ambas cartas
	var tween1 = create_tween()
	var tween2 = create_tween()
	
	card1.z_index = 5
	card2.z_index = 5
	
	# Movimiento de carta1
	tween1.tween_method(
		func(pos): card1.position = pos,
		start_pos1,
		control1,
		base_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween1.tween_method(
		func(pos): card1.position = pos,
		control1,
		end_pos1,
		base_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Movimiento de carta2
	tween2.tween_method(
		func(pos): card2.position = pos,
		start_pos2,
		control2,
		base_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween2.tween_method(
		func(pos): card2.position = pos,
		control2,
		end_pos2,
		base_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Restaurar z_index al final
	tween1.tween_callback(func(): card1.z_index = 0)
	tween2.tween_callback(func(): card2.z_index = 0)
	
	return [tween1, tween2]

func perform_decoy_movement(card: Node2D, original_pos: Vector2) -> Tween:
	var tween = create_tween()
	
	# Movimiento circular completo alrededor de la posición original
	var radius = 40  # Radio del círculo
	var clockwise = randf() < 0.5
	var num_points = 8  # Puntos para hacer el círculo suave
	
	card.z_index = 2
	
	# Crear puntos del círculo completo
	for i in range(num_points + 1):  # +1 para cerrar el círculo completamente
		var angle = (i * 2 * PI) / num_points
		if not clockwise:
			angle = -angle
		var offset = Vector2(cos(angle), sin(angle)) * radius
		var target_pos = original_pos + offset
		tween.tween_property(card, "position", target_pos, 0.4 / num_points).set_trans(Tween.TRANS_SINE)
	
	# Asegurar que vuelve a la posición exacta
	tween.tween_property(card, "position", original_pos, 0.05)
	tween.tween_callback(func(): card.z_index = 0)
	
	return tween

func enable_card_selection():
	is_responding = true
	response_start_time = Time.get_ticks_msec() / 1000.0  # Convertir a segundos
	# Asegurarnos de que el timer esté parado y reiniciado
	response_timer.stop()
	
	var config = get_difficulty_config()
	response_timer.wait_time = config.response_time_free + config.response_time_total
	response_timer.start()

func _on_card_clicked(_viewport, event, _shape_idx, card):
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not is_responding:
		return
	
	is_responding = false
	response_timer.stop()
	
	# Encontrar el índice actual de la carta en el array
	var card_index = cards.find(card)
	if card_index == -1:
		return  # Carta no encontrada
	
	# Calcular puntos basados en tiempo transcurrido desde el inicio
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_taken = current_time - response_start_time
	var points = calculate_points(time_taken)
	
	if card_index == queen_card_index:
		# Acierto
		score += points
		create_particles(card.position, Color.GREEN, true)
		show_result(true, points)
		
		# Revelar todas las cartas
		reveal_all_cards()
		
		await get_tree().create_timer(2.0).timeout
		
		if current_round < 3:
			current_round += 1
			start_round()
		else:
			end_game(true)
	else:
		# Fallo
		create_particles(card.position, Color.RED, false)
		show_result(false, 0)
		reveal_all_cards()
		
		await get_tree().create_timer(2.0).timeout
		end_game(false)

func calculate_points(time_taken: float) -> int:
	var config = get_difficulty_config()
	var max_points = config.points[current_round - 1]
	var min_points = config.min_points[current_round - 1]
	
	# Tiempo gratis sin penalización
	if time_taken <= config.response_time_free:
		return max_points
	
	# Calcular puntos para el tiempo de penalización
	var penalty_time = time_taken - config.response_time_free
	penalty_time = clamp(penalty_time, 0.0, config.response_time_total)
	
	# Interpolación lineal desde max_points hasta min_points
	var ratio = 1.0 - (penalty_time / config.response_time_total)
	ratio = clamp(ratio, 0.0, 1.0)
	
	var points = min_points + (max_points - min_points) * ratio
	return int(points)

func reveal_all_cards():
	for i in range(cards.size()):
		var card = cards[i]
		var tween = create_tween()
		tween.tween_property(card, "scale:x", 0.0, 0.2)
		tween.tween_callback(func():
			card.get_node("Back").visible = false
			card.get_node("Front").visible = true
			if i == queen_card_index:
				card.modulate = Color.GREEN
			else:
				card.modulate = Color.RED
		)
		tween.tween_property(card, "scale:x", 1.0, 0.2)

func show_result(_success: bool, points: int):
	var popup = preload("res://scenes/ui/ScorePopup.tscn").instantiate()
	add_child(popup)
	popup.setup(points, Vector2(576, 200))

func _on_response_timer_timeout():
	if is_responding:
		# Tiempo agotado
		is_responding = false
		show_result(false, 0)
		reveal_all_cards()
		
		await get_tree().create_timer(2.0).timeout
		end_game(false)

func clear_cards():
	for card in cards:
		card.queue_free()
	cards.clear()

func end_game(won: bool):
	is_game_active = false
	
	# Limpiar las cartas antes de mostrar el game over
	clear_cards()
	
	game_over_label.visible = true
	
	if won:
		game_over_label.text = "¡PERFECTO!\nCompletaste las 3 rondas\nPuntuación: " + str(score)
		game_over_label.modulate = Color.GREEN
	else:
		game_over_label.text = "¡FALLASTE!\nRonda " + str(current_round) + " de 3\nPuntuación: " + str(score)
		game_over_label.modulate = Color.RED
	
	await get_tree().create_timer(3.0).timeout
	GameManager.complete_minigame(won, score)

func _process(delta):
	if is_game_active:
		total_time += delta
		update_ui()

func create_particles(_position: Vector2, color: Color, is_success: bool):
	# Crear sistema de partículas
	var particles = CPUParticles2D.new()
	add_child(particles)
	particles.position = position
	
	# Configuración básica
	particles.emitting = true
	particles.amount = 30 if is_success else 20
	particles.lifetime = 1.5
	particles.one_shot = true
	
	# Forma de emisión
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	
	# Propiedades de movimiento
	particles.direction = Vector2(0, -1)  # Hacia arriba
	particles.spread = 45.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 120.0
	particles.gravity = Vector2(0, 200)  # Gravedad hacia abajo
	
	# Propiedades visuales
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	particles.color = color
	
	# Configurar fade out
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(color.r, color.g, color.b, 1.0))
	gradient.add_point(1.0, Color(color.r, color.g, color.b, 0.0))
	particles.color_ramp = gradient
	
	# Auto-destruir después de la animación
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()

func update_ui():
	score_label.text = "Puntos: " + str(score)
	time_label.text = "Tiempo: " + str(int(total_time))
	round_label.text = "Ronda: " + str(current_round) + "/3"
	difficulty_label.text = "Dificultad: " + GameManager.get_difficulty_name()
