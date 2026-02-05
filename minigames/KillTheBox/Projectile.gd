extends Area2D
class_name KTB_Projectile

var _from_player: bool = false
var _dir: Vector2 = Vector2.RIGHT
var _speed: float = 400.0
var _damage: int = 1

var _life_timer: Timer = Timer.new()

func _ready() -> void:
	monitoring = true
	input_pickable = false

	body_entered.connect(_on_body_entered)

	_life_timer.one_shot = true
	_life_timer.wait_time = 2.5
	add_child(_life_timer)
	_life_timer.timeout.connect(_on_life_timeout)
	_life_timer.start()

	queue_redraw()

func setup(from_player: bool, dir: Vector2, speed: float, damage: int) -> void:
	_from_player = from_player
	_dir = dir
	_speed = speed
	_damage = damage

func _physics_process(delta: float) -> void:
	global_position += _dir * _speed * delta

func _draw() -> void:
	# Bola simple: azul si jugador, roja si boss
	var col: Color = Color(1.0, 0.25, 0.25, 1.0)
	if _from_player:
		col = Color(0.25, 0.65, 1.0, 1.0)
	draw_circle(Vector2.ZERO, 6.0, col)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func _on_body_entered(body: Node) -> void:
	if _from_player:
		if body is KTB_Boss:
			var boss_ref: KTB_Boss = body as KTB_Boss
			boss_ref.take_damage(_damage)
			queue_free()
			return
	else:
		if body is KTB_Player:
			var player_ref: KTB_Player = body as KTB_Player
			player_ref.take_damage(_damage)
			queue_free()
			return

	# Obstáculos absorben proyectiles enemigos (y también puedes decidir que absorban ambos)
	if body is KTB_Obstacle:
		queue_free()
		return

func _on_life_timeout() -> void:
	queue_free()
