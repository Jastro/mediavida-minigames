extends CharacterBody2D
enum EState {
	Free,
	Attacking,
	Hurt,
}

const MOV_THRESHOLD = 7;
const DASH_STRENGTH = {
	GameManager.Difficulty.EASY		: 1900,
	GameManager.Difficulty.NORMAL	: 1600,
	GameManager.Difficulty.HARD		: 1400,
}
const MAX_IMPULSE = 1900

var desired_velocity = Vector2.ZERO
var external_impulse = Vector2.ZERO
var state : EState = EState.Free
var difficulty : GameManager.Difficulty

func _ready():
	difficulty = GameManager.get_difficulty()
	%Animation.animation_finished.connect(_on_animation_finished)
	
func _input(event):
	if(event.is_action_pressed("action1")):
		%Animation.play("Attack1")
		state = EState.Attacking
	elif(event.is_action_pressed("action2")):
		%Animation.play("Attack2")
		state = EState.Attacking
	elif(event.is_action_pressed("special")):
		if(velocity.length() > MOV_THRESHOLD):
			external_impulse += velocity.normalized() * DASH_STRENGTH[difficulty]
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
