extends Node2D
class_name KillTheBoss

const GAME_DURATION_SEC: float = 10.0

# Arena (ajusta a tu resolución real si hace falta)

@onready var arena_visual: KTB_ArenaVisual = $ArenaVisual as KTB_ArenaVisual
var _arena_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

const HP_BAR_SIZE: Vector2 = Vector2(520.0, 18.0)
# Powerups: zona válida y distancia mínima al jefe
const POWERUP_MIN_DIST_TO_BOSS: float = 140.0

@onready var boss: KTB_Boss = $Boss as KTB_Boss
@onready var player: KTB_Player = $Player as KTB_Player

@onready var obstacle_container: Node2D = $ObstacleContainer as Node2D
@onready var projectile_container: Node2D = $ProjectileContainer as Node2D
@onready var powerup_container: Node2D = $PowerupContainer as Node2D

@onready var game_timer: Timer = $GameTimer as Timer

@onready var time_label: Label = $CanvasLayer/TopBar/TimeLabel as Label
@onready var boss_hp_bar: ProgressBar = $CanvasLayer/TopBar/BossHPBar as ProgressBar
@onready var player_hp_bar: ProgressBar = $CanvasLayer/HUD/PlayerHPBar as ProgressBar
@onready var result_label: Label = $CanvasLayer/HUD/ResultLabel as Label
#queue powerup spawns
var _pending_powerup_spawns: int = 0
var _powerup_spawn_flush_scheduled: bool = false

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _elapsed_sec: float = 0.0
var _resolved: bool = false
var _won: bool = false
var _already_called_complete: bool = false

var _powerup_75_spawned: bool = false
var _powerup_25_spawned: bool = false

var _finish_in_progress: bool = false

func _ready() -> void:
	_rng.randomize()

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	var margin_left: float = 20.0
	var margin_right: float = 20.0
	var margin_top: float = 60.0
	var margin_bottom: float = 60.0

	_arena_rect = Rect2(
		Vector2(margin_left, margin_top),
		viewport_size - Vector2(margin_left + margin_right, margin_top + margin_bottom)
	)

	arena_visual.set_arena_rect(_arena_rect)
	result_label.visible = false

	# Inyectar contenedores para spawns
	player.set_projectile_container(projectile_container)
	boss.set_projectile_container(projectile_container)
#	Posiciones iniciales
	boss.set_player_ref(player)
	_apply_initial_positions()
	# Dificultad -> configurar vida del boss, daño, cadencias, etc.
	_apply_difficulty()
#	UI
	_setup_hp_bar(boss_hp_bar, Color(1.0, 0.2, 0.2, 1.0))   # rojo
	_setup_hp_bar(player_hp_bar, Color(0.2, 0.55, 1.0, 1.0)) # azul
	# Conectar señales
	boss.health_changed.connect(_on_boss_health_changed)
	boss.dead.connect(_on_boss_dead)
	player.dead.connect(_on_player_dead)

	game_timer.timeout.connect(_on_game_timer_timeout)
	game_timer.one_shot = true
	game_timer.wait_time = GAME_DURATION_SEC
	game_timer.start()

	_elapsed_sec = 0.0
	_update_hud()

func _process(delta: float) -> void:
	_elapsed_sec += delta
	if _elapsed_sec > GAME_DURATION_SEC:
		_elapsed_sec = GAME_DURATION_SEC
	_update_hud()
	
func _apply_initial_positions() -> void:
	# Boss centrado
	#boss.global_position = _arena_rect.get_center()

	# Player centrado, más abajo (como en el mockup)
	var player_pos: Vector2 = Vector2(_arena_rect.get_center().x, _arena_rect.position.y + _arena_rect.size.y * 0.72)
	player.global_position = player_pos

	# Pasar bounds al player para clamping
	player.set_arena_rect(_arena_rect)

	# Colocar obstáculos fijos (izquierda y derecha, a media altura)

func _apply_difficulty() -> void:
	var diff: GameManager.Difficulty = GameManager.get_difficulty()

	# Objetivo: EASY ~ 5s de puntería constante, HARD ~ 9s
	# Ajustamos la vida del boss en función de DPS estimado del jugador.
	# (El jugador dispara automático; si apuntas bien, casi todo impacta.)
	match diff:
		GameManager.Difficulty.EASY:
			boss.configure_stats(320, 1) # hp, daño proyectil boss
			player.configure_fire(0.14, 14) # fire_interval, daño bala jugador
		GameManager.Difficulty.NORMAL:
			boss.configure_stats(450, 2)
			player.configure_fire(0.14, 14)
		GameManager.Difficulty.HARD:
			boss.configure_stats(580, 3)
			player.configure_fire(0.14, 14)
		_:
			boss.configure_stats(450, 2)
			player.configure_fire(0.14, 14)

func _complete_minigame_once() -> void:
	if _already_called_complete:
		return
	_already_called_complete = true

	# Si no se resolvió antes, evaluar aquí
	if not _resolved:
		_won = boss.is_dead()

	var dmg_done: int = boss.get_max_hp() - boss.get_hp()
	if dmg_done < 0:
		dmg_done = 0

	GameManager.complete_minigame(_won, dmg_done)
func _update_hud() -> void:
	var time_left: float = GAME_DURATION_SEC - _elapsed_sec
	if time_left < 0.0:
		time_left = 0.0

	time_label.text = "Tiempo: " + str(int(ceil(time_left)))
#	HP Bars
	boss_hp_bar.max_value = float(boss.get_max_hp())
	boss_hp_bar.value = float(boss.get_hp())

	player_hp_bar.max_value = float(player.get_max_hp())
	player_hp_bar.value = float(player.get_hp())
func _setup_hp_bar(bar: ProgressBar, fill_color: Color) -> void:
	# Fondo
	var bg: StyleBoxFlat = StyleBoxFlat.new()
	bg.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	bg.border_color = Color(0.0, 0.0, 0.0, 1.0)
	bg.border_width_left = 2
	bg.border_width_right = 2
	bg.border_width_top = 2
	bg.border_width_bottom = 2

	# Relleno (vida)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = fill_color

	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)

	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(520.0, 18.0)
func _on_boss_health_changed(current_hp: int, max_hp: int) -> void:
	_update_hud()

	var frac: float = 0.0
	if max_hp > 0:
		frac = float(current_hp) / float(max_hp)

	# Powerup al 75% y al 25% (al cruzar hacia abajo)
	if (not _powerup_75_spawned) and frac <= 0.75:
		_powerup_75_spawned = true
		_queue_powerup_spawn(1)

	if (not _powerup_25_spawned) and frac <= 0.25:
		_powerup_25_spawned = true
		_queue_powerup_spawn(1)
func _queue_powerup_spawn(count: int) -> void:
	if count <= 0:
		return
	if _resolved:
		return

	_pending_powerup_spawns += count

	if _powerup_spawn_flush_scheduled:
		return

	_powerup_spawn_flush_scheduled = true
	call_deferred("_flush_powerup_spawns")

func _flush_powerup_spawns() -> void:
	_powerup_spawn_flush_scheduled = false

	while _pending_powerup_spawns > 0:
		_pending_powerup_spawns -= 1
		_spawn_powerup_now()

func _spawn_powerup_now() -> void:
	var powerup_scene: PackedScene = preload("res://minigames/KillTheBox/Powerup.tscn")
	var powerup: KTB_Powerup = powerup_scene.instantiate() as KTB_Powerup

	var spawn_pos: Vector2 = _find_valid_powerup_position()
	powerup.global_position = spawn_pos
	powerup.collected.connect(_on_powerup_collected)

	powerup_container.add_child(powerup)

func _find_valid_powerup_position() -> Vector2:
	# Rect predefinido dentro del arena
	var min_pos: Vector2 = _arena_rect.position + Vector2(60.0, 60.0)
	var max_pos: Vector2 = _arena_rect.position + _arena_rect.size - Vector2(60.0, 60.0)

	var attempts: int = 0
	while attempts < 30:
		attempts += 1
		var x: float = _rng.randf_range(min_pos.x, max_pos.x)
		var y: float = _rng.randf_range(min_pos.y, max_pos.y)
		var pos: Vector2 = Vector2(x, y)

		var dist: float = pos.distance_to(boss.global_position)
		if dist >= POWERUP_MIN_DIST_TO_BOSS:
			return pos

	# Fallback: si no encuentra, coloca lejos en diagonal
	return boss.global_position + Vector2(POWERUP_MIN_DIST_TO_BOSS, POWERUP_MIN_DIST_TO_BOSS)

func _on_powerup_collected() -> void:
	# Aumenta cadencia 2 segundos
	player.apply_fire_rate_boost(2.0, 2.0)

func _on_boss_dead() -> void:
	# Importante: el juego dura 10s. Marcamos victoria, pero no llamamos GameManager aún.
	_resolve(true)

func _on_player_dead() -> void:
	# Si ya era victoria resuelta, ignora (por seguridad)
	if _resolved and _won:
		return

	_resolve(false)
	_finish_defeat_after_delay(2.0)
func _finish_defeat_after_delay(delay_sec: float) -> void:
	if _finish_in_progress:
		return
	_finish_in_progress = true

	# Parar el timer de 10s para que no finalize por su cuenta
	game_timer.stop()

	await get_tree().create_timer(delay_sec).timeout
	_complete_minigame_once()
func _resolve(won: bool) -> void:
	if _resolved:
		return
	_resolved = true
	_won = won

	result_label.visible = true
	if won:
		result_label.text = "¡VICTORIA!"
	else:
		result_label.text = "DERROTA!"

	# Parar spawns/acciones para “congelar” el resultado
	boss.set_active(false)
	player.set_active(false)

	# Limpiar proyectiles (opcional)
	for child_node in projectile_container.get_children():
		var proj: Node = child_node
		proj.queue_free()

func _on_game_timer_timeout() -> void:
	_complete_minigame_once()
