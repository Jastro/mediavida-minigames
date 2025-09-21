extends CharacterBody2D

signal Hurt(current_hp)

enum EState {
	Free,
	Attacking,
	Hurt,
	Dead,
}

const MOV_THRESHOLD = 7;
const DASH_STRENGTH = {
	GameManager.Difficulty.EASY		: 1900,
	GameManager.Difficulty.NORMAL	: 1600,
	GameManager.Difficulty.HARD		: 1400,
}
const MAX_IMPULSE	: float = 2500
const HURT_IMPULSE	: float = 1200

var dark_spell_scn : PackedScene
var desired_velocity = Vector2.ZERO
var external_impulse = Vector2.ZERO
var state : EState = EState.Free
var difficulty : GameManager.Difficulty

var current_hp	= 1
var max_hp		= {
	GameManager.Difficulty.EASY		: 3,
	GameManager.Difficulty.NORMAL	: 2,
	GameManager.Difficulty.HARD		: 1,
}

func _ready():
	dark_spell_scn = preload("res://minigames/TheOrcsAreComingFromTheEast/characters/dark_spell.tscn")
	collision_layer = Defs.L_PLAYER
	collision_mask = 1 # we collide with the environment only
	var mat : ShaderMaterial = %Animation.material
	mat.set_shader_parameter("percent", 0)
	difficulty = GameManager.get_difficulty()
	%Animation.animation_finished.connect(_on_animation_finished)
	%Hitbox.set_new_layer(Defs.L_PLAYER)
	%Hurtbox.set_new_mask(Defs.L_ENEMY)
	%Hurtbox.hurt.connect(_on_hurt)
	%Hitbox.disable() # By default disable until we attack
	current_hp = get_max_hp()

func _input(event):
	if(event.is_action_pressed("action1")):
		%Pivot.rotation_degrees = 180 if %Animation.flip_h else 0
		%Animation.play("Attack1")
		%Hitbox.enable(0.4)
		state = EState.Attacking
	elif(event.is_action_pressed("action2")):
		%Pivot.rotation_degrees = 180 if %Animation.flip_h else 0
		%Animation.play("Attack2")
		%Hitbox.enable(0.4)
		state = EState.Attacking
		var dark_spell = dark_spell_scn.instantiate()
		dark_spell.direction = Vector2.LEFT if $Animation.flip_h else Vector2.RIGHT
		dark_spell.flip_h = $Animation.flip_h
		get_parent().add_child(dark_spell)
		dark_spell.global_position = global_position + dark_spell.direction * 100 + Vector2.UP * 25
	elif(event.is_action_pressed("special")):
		if(desired_velocity.length() > MOV_THRESHOLD):
			external_impulse += desired_velocity.normalized() * DASH_STRENGTH[difficulty]
		else:
			external_impulse += Vector2.RIGHT * DASH_STRENGTH[difficulty] * (-1 if %Animation.flip_h else 1)
	
func _physics_process(_delta):
	if(state == EState.Free):
		desired_velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized() * 220
	else:
		desired_velocity = Vector2.ZERO
		
	if(external_impulse.length() > MAX_IMPULSE):
		external_impulse = external_impulse.normalized() * MAX_IMPULSE
	velocity = velocity.lerp(desired_velocity, 0.2)
	velocity += external_impulse
	external_impulse = external_impulse.lerp(Vector2.ZERO, 0.6)
	move_and_slide()
	animate()

func get_max_hp():
	return max_hp[GameManager.get_difficulty()]

func animate():
	if(desired_velocity.x != 0):
		%Animation.flip_h = false if (desired_velocity.x > 0) else true
	
	if(state == EState.Free):
		if(velocity.length() > MOV_THRESHOLD):
			%Animation.play("Run")
		else:
			%Animation.play("Idle")
			
func _on_animation_finished():
	match %Animation.animation:
		"Attack1", "Attack2":
			state = EState.Free

func _on_hurt(source):
	external_impulse = source.global_position.direction_to(global_position) * HURT_IMPULSE
	%AnimationPlayer.play("Hurt")
	%Hurtbox.disable(1)
	current_hp = clamp(current_hp - 0.25, 0, get_max_hp())
	Hurt.emit(current_hp)
	if(current_hp == 0):
		%Hurtbox.disable_permanent()
		die()

func die():
	state = EState.Dead
	set_physics_process(false)
	set_process_input(false)
	%Animation.stop()
	var tween = create_tween()
	tween.tween_method(_animate_death, 0.0, 1.0, 0.5)
	tween.play()
	await tween.finished
	%Animation.visible = false

func _animate_death(percent : float):
	var mat : ShaderMaterial = %Animation.material
	mat.set_shader_parameter("percent", percent)
