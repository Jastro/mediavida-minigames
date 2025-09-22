extends CharacterBody2D

@export var speed := 300.0

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("action1"):
		direction.x -= 1
	if Input.is_action_pressed("action3"):
		direction.x += 1

	velocity = direction * speed
	move_and_slide()
	
		# Limita el movimiento a los bordes de la pantalla (por ejemplo, 0 a 640 px)
	position.x = clamp(position.x, 8, 1150)
