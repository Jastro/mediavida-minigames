extends CharacterBody2D
class_name KTB_Player

signal dead
const PLAYER_RADIUS: float = 18.0

@export var move_speed: float = 380.0
var _arena_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var _active: bool = true

var _max_hp: int = 6
var _hp: int = 6

var _projectile_container: Node2D = null

var _base_fire_interval: float = 0.14
var _current_fire_interval: float = 0.14
var _projectile_damage: int = 14

var _shoot_timer: Timer = Timer.new()
var _boost_timer: Timer = Timer.new()

func _ready() -> void:
	# Timers internos
	_shoot_timer.one_shot = false
	_shoot_timer.wait_time = _current_fire_interval
	add_child(_shoot_timer)
	_shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	_shoot_timer.start()

	_boost_timer.one_shot = true
	add_child(_boost_timer)
	_boost_timer.timeout.connect(_on_boost_timeout)
func set_arena_rect(rect: Rect2) -> void:
	_arena_rect = rect
func _draw() -> void:
	# Círculo minimalista
	draw_circle(Vector2.ZERO, 18.0, Color(0.2, 0.6, 1.0, 1.0))

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func set_projectile_container(container_node: Node2D) -> void:
	_projectile_container = container_node

func configure_fire(fire_interval: float, projectile_damage: int) -> void:
	_base_fire_interval = fire_interval
	_current_fire_interval = fire_interval
	_projectile_damage = projectile_damage
	_shoot_timer.wait_time = _current_fire_interval

func set_active(active_flag: bool) -> void:
	_active = active_flag
	if _active:
		_shoot_timer.start()
	else:
		_shoot_timer.stop()
		velocity = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if not _active:
		return

	var dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.y += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1.0

	if dir.length() > 0.0:
		dir = dir.normalized()

	velocity = dir * move_speed
	move_and_slide()
	# Clamp al arena
	if _arena_rect.size.x > 0.0 and _arena_rect.size.y > 0.0:
		var min_x: float = _arena_rect.position.x + PLAYER_RADIUS
		var max_x: float = _arena_rect.position.x + _arena_rect.size.x - PLAYER_RADIUS
		var min_y: float = _arena_rect.position.y + PLAYER_RADIUS
		var max_y: float = _arena_rect.position.y + _arena_rect.size.y - PLAYER_RADIUS

		var clamped_pos: Vector2 = global_position
		clamped_pos.x = clampf(clamped_pos.x, min_x, max_x)
		clamped_pos.y = clampf(clamped_pos.y, min_y, max_y)
		global_position = clamped_pos
func _on_shoot_timer_timeout() -> void:
	if not _active:
		return
	_shoot_once()

func _shoot_once() -> void:
	if _projectile_container == null:
		return

	var mouse_pos: Vector2 = get_global_mouse_position()
	var to_mouse: Vector2 = mouse_pos - global_position
	if to_mouse.length() <= 0.001:
		return

	var dir: Vector2 = to_mouse.normalized()

	var proj_scene: PackedScene = preload("res://minigames/KillTheBox/Projectile.tscn")
	var proj: KTB_Projectile = proj_scene.instantiate() as KTB_Projectile
	proj.setup(true, dir, 620.0, _projectile_damage)

	proj.global_position = global_position
	_projectile_container.add_child(proj)

func apply_fire_rate_boost(duration_sec: float, multiplier: float) -> void:
	# multiplier = 2.0 significa el doble de cadencia => intervalo mitad
	if multiplier <= 0.01:
		return

	_current_fire_interval = _base_fire_interval / multiplier
	_shoot_timer.wait_time = _current_fire_interval
	_boost_timer.stop()
	_boost_timer.wait_time = duration_sec
	_boost_timer.start()

func _on_boost_timeout() -> void:
	_current_fire_interval = _base_fire_interval
	_shoot_timer.wait_time = _current_fire_interval

func take_damage(amount: int) -> void:
	if not _active:
		return
	if amount <= 0:
		return

	_hp -= amount
	if _hp <= 0:
		_hp = 0
		_active = false
		_shoot_timer.stop()
		dead.emit()

func get_hp() -> int:
	return _hp

func get_max_hp() -> int:
	return _max_hp
