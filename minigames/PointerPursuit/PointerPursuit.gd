extends Node2D

const PLAY_AREA := Rect2(Vector2.ZERO, Vector2(1152, 648))
const TOTAL_TIME := 10.0
const BASE_RECT_SIZE := Vector2(90, 64)

@onready var chaser: Node2D = $Chaser
@onready var chaser_body: ColorRect = $Chaser/Body
@onready var score_label: Label = $UI/TopBar/HBoxContainer/ScoreLabel
@onready var time_label: Label = $UI/TopBar/HBoxContainer/TimeLabel
@onready var status_label: Label = $UI/TopBar/HBoxContainer/StatusLabel
@onready var instructions_label: Label = $UI/Instructions
@onready var result_label: Label = $UI/ResultLabel

var is_game_active := false
var has_finished := false
var elapsed_time := 0.0
var current_score := 0
var velocity := Vector2.ZERO
var growth_level := 0
var countdown_timer: Timer

var base_speed := 260.0
var speed_ramp := 55.0
var chase_responsiveness := 4.0
var scale_step := 0.1
var capture_radius := 40.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	apply_difficulty_settings()
	setup_chaser_visual()
	status_label.text = "Estado: Prepárate"
	time_label.text = "Tiempo: %.1f" % TOTAL_TIME
	instructions_label.visible = true
	result_label.visible = false
	await get_tree().create_timer(2.0).timeout
	start_minigame()

func apply_difficulty_settings():
	match GameManager.get_difficulty():
		GameManager.Difficulty.EASY:
			base_speed = 400.0
			speed_ramp = 80.0
			chase_responsiveness = 6.2
			scale_step = 0.24
		GameManager.Difficulty.NORMAL:
			base_speed = 500.0
			speed_ramp = 90.0
			chase_responsiveness = 7.2
			scale_step = 0.34
		GameManager.Difficulty.HARD:
			base_speed = 600.0
			speed_ramp = 100.0
			chase_responsiveness = 8.2
			scale_step = 0.44

func setup_chaser_visual():
	chaser.position = PLAY_AREA.size * 0.5
	chaser_body.size = BASE_RECT_SIZE
	chaser_body.position = -BASE_RECT_SIZE * 0.5
	chaser_body.pivot_offset = BASE_RECT_SIZE * 0.5
	growth_level = 0
	update_chaser_scale()

func start_minigame():
	if has_finished:
		return
	is_game_active = true
	elapsed_time = 0.0
	current_score = 0
	velocity = Vector2.ZERO
	growth_level = 0
	update_chaser_scale()
	instructions_label.visible = false
	status_label.text = "Estado: Sobrevive"
	countdown_timer = GameManager.start_countdown_timer(TOTAL_TIME, Callable(self, "_on_game_timeout"))

func _process(delta: float) -> void:
	if not is_game_active:
		return

	var mouse_pos := get_viewport().get_mouse_position()
	if not PLAY_AREA.has_point(mouse_pos):
		end_minigame(false, "¡No salgas del área de juego!")
		return

	elapsed_time += delta
	var remaining_time := maxf(0.0, TOTAL_TIME - elapsed_time)
	time_label.text = "Tiempo: %.1f" % remaining_time

	update_score_display()
	handle_growth()
	update_chaser(delta, mouse_pos)

	if chaser.position.distance_to(mouse_pos) <= capture_radius:
		end_minigame(false, "¡El rectángulo te atrapó!")

func update_score_display():
	var progress := clampf(elapsed_time / TOTAL_TIME, 0.0, 1.0)
	current_score = int(round(progress * 100.0))
	score_label.text = "Puntos: %d" % current_score

func handle_growth():
	var new_growth := int(floor(elapsed_time))
	if new_growth > growth_level:
		growth_level = new_growth
		update_chaser_scale()

func update_chaser(delta: float, target_position: Vector2):
	var to_target := target_position - chaser.position
	var distance := to_target.length()
	var target_velocity := Vector2.ZERO
	if distance > 0.01:
		var direction := to_target / distance
		var desired_speed := base_speed + speed_ramp * elapsed_time
		target_velocity = direction * desired_speed

	velocity = velocity.lerp(target_velocity, clampf(chase_responsiveness * delta, 0.0, 1.0))
	chaser.position += velocity * delta
	chaser.position.x = clampf(chaser.position.x, capture_radius, PLAY_AREA.size.x - capture_radius)
	chaser.position.y = clampf(chaser.position.y, capture_radius, PLAY_AREA.size.y - capture_radius)

func update_chaser_scale():
	var scale_factor := 1.0 + float(growth_level) * scale_step
	chaser.scale = Vector2.ONE * scale_factor
	capture_radius = max(BASE_RECT_SIZE.x, BASE_RECT_SIZE.y) * 0.5 * scale_factor

func end_minigame(won: bool, message: String):
	if has_finished:
		return
	has_finished = true
	is_game_active = false
	if countdown_timer and countdown_timer.is_inside_tree():
		countdown_timer.stop()

	var time_survived := minf(elapsed_time, TOTAL_TIME)
	var final_score := calculate_final_score(time_survived)
	score_label.text = "Puntos: %d" % final_score
	if won:
		status_label.text = "Estado: ¡Sobreviviste!"
	else:
		status_label.text = "Estado: Fin del juego"

	result_label.visible = true
	result_label.text = message + "\nPuntuación: " + str(final_score)

	await get_tree().create_timer(2.0).timeout
	GameManager.complete_minigame(won, final_score)

func calculate_final_score(time_survived: float) -> int:
	if time_survived < 1.0:
		return 0
	var normalized := clampf(time_survived / TOTAL_TIME, 0.0, 1.0)
	return int(round(normalized * 100.0))

func _on_game_timeout():
	end_minigame(true, "¡Resististe los 10 segundos!")
