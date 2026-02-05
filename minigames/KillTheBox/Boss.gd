extends StaticBody2D
class_name KTB_Boss

signal health_changed(current_hp: int, max_hp: int)
signal dead

enum AttackPhase {
	SINGLE = 0,
	SHOTGUN = 1,
	SUPERNOVA = 2
}

var _active: bool = true

var _max_hp: int = 450
var _hp: int = 450

var _boss_projectile_damage: int = 2

var _phase: AttackPhase = AttackPhase.SINGLE

var _projectile_container: Node2D = null
var _player_ref: KTB_Player = null

var _attack_timer: Timer = Timer.new()

func _ready() -> void:
	_attack_timer.one_shot = false
	_attack_timer.wait_time = 0.75
	add_child(_attack_timer)
	_attack_timer.timeout.connect(_on_attack_timer_timeout)
	_attack_timer.start()

func _draw() -> void:
	# Cuadrado minimalista (jefe)
	var half: float = 34.0
	draw_rect(Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0)), Color(0.85, 0.85, 0.85, 1.0), true)
	draw_rect(Rect2(Vector2(-half, -half), Vector2(half * 2.0, half * 2.0)), Color(0.1, 0.1, 0.1, 1.0), false, 2.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()

func set_projectile_container(container_node: Node2D) -> void:
	_projectile_container = container_node

func set_player_ref(player_node: KTB_Player) -> void:
	_player_ref = player_node

func configure_stats(max_hp: int, boss_projectile_damage: int) -> void:
	_max_hp = max_hp
	_hp = max_hp
	_boss_projectile_damage = boss_projectile_damage
	health_changed.emit(_hp, _max_hp)
	_update_phase()

func set_active(active_flag: bool) -> void:
	_active = active_flag
	if _active:
		_attack_timer.start()
	else:
		_attack_timer.stop()

func take_damage(amount: int) -> void:
	if not _active:
		return
	if amount <= 0:
		return
	if _hp <= 0:
		return

	_hp -= amount
	if _hp <= 0:
		_hp = 0
		health_changed.emit(_hp, _max_hp)
		_active = false
		_attack_timer.stop()
		dead.emit()
		return

	health_changed.emit(_hp, _max_hp)
	_update_phase()

func _update_phase() -> void:
	var frac: float = 0.0
	if _max_hp > 0:
		frac = float(_hp) / float(_max_hp)

	if frac > 0.75:
		_phase = AttackPhase.SINGLE
	elif frac > 0.25:
		_phase = AttackPhase.SHOTGUN
	else:
		_phase = AttackPhase.SUPERNOVA

func _on_attack_timer_timeout() -> void:
	if not _active:
		return
	if _projectile_container == null:
		return
	if _player_ref == null:
		return

	match _phase:
		AttackPhase.SINGLE:
			_fire_single()
		AttackPhase.SHOTGUN:
			_fire_shotgun()
		AttackPhase.SUPERNOVA:
			_fire_supernova()
		_:
			_fire_single()

func _fire_single() -> void:
	var to_player: Vector2 = _player_ref.global_position - global_position
	if to_player.length() <= 0.001:
		return
	var dir: Vector2 = to_player.normalized()

	_spawn_boss_projectile(dir, 420.0)

func _fire_shotgun() -> void:
	var to_player: Vector2 = _player_ref.global_position - global_position
	if to_player.length() <= 0.001:
		return
	var base_dir: Vector2 = to_player.normalized()

	# Escopeta: 7 balas con spread
	var count: int = 7
	var spread_deg: float = 36.0
	var spread_rad: float = deg_to_rad(spread_deg)

	var i: int = 0
	while i < count:
		var t: float = 0.0
		if count > 1:
			t = float(i) / float(count - 1)
		var angle: float = lerp(-spread_rad * 0.5, spread_rad * 0.5, t)
		var dir: Vector2 = base_dir.rotated(angle)
		_spawn_boss_projectile(dir, 380.0)
		i += 1

func _fire_supernova() -> void:
	# 180 grados en dirección al jugador (pasillo de balas evitables)
	var to_player: Vector2 = _player_ref.global_position - global_position
	if to_player.length() <= 0.001:
		return
	var base_dir: Vector2 = to_player.normalized()

	var bullet_count: int = 18
	var half_pi: float = PI * 0.5

	var idx: int = 0
	while idx < bullet_count:
		var t: float = 0.0
		if bullet_count > 1:
			t = float(idx) / float(bullet_count - 1)
		var angle: float = lerp(-half_pi, half_pi, t)
		var dir: Vector2 = base_dir.rotated(angle)
		_spawn_boss_projectile(dir, 320.0)
		idx += 1

func _spawn_boss_projectile(dir: Vector2, speed: float) -> void:
	var proj_scene: PackedScene = preload("res://minigames/KillTheBox/Projectile.tscn")
	var proj: KTB_Projectile = proj_scene.instantiate() as KTB_Projectile
	proj.setup(false, dir, speed, _boss_projectile_damage)

	proj.global_position = global_position
	_projectile_container.add_child(proj)

func get_hp() -> int:
	return _hp

func get_max_hp() -> int:
	return _max_hp

func is_dead() -> bool:
	return _hp <= 0
