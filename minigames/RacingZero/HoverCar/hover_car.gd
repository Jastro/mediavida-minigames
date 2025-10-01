extends CharacterBody3D

@export var game_manager	: RacingZero
@export var hovercar_type	: RacingZero.EHoverCar

var accel				: float
var max_speed			: float
var max_speed_reverse	: float
var maneuverability		: float
var break_power			: float

var desired_direction		: float
var desired_acceleration	: float

# for slopes
var target_rotation			: Vector3 = Vector3.ZERO

var current_speed			: float = 0
var external_impulse		: float = 0
func _ready():
	accel				= game_manager.ACCEL[hovercar_type]
	max_speed			= game_manager.MAX_SPEED[hovercar_type]
	maneuverability 	= game_manager.MANEUVERABILITY[hovercar_type]
	max_speed_reverse	= game_manager.MAX_SPEED_REVERSE[hovercar_type]
	break_power			= game_manager.BREAK[hovercar_type]
	$FastLaneDetector.collision_mask = RacingZero.L_FAST_LANE
	
func _physics_process(delta):
	var car_direction		= get_global_transform().basis
	var forward				= car_direction.z
	var friction			= RacingZero.FRICTION
	desired_acceleration	= Input.get_axis("up", "down")
	rotate_y(Input.get_axis("right", "left") * maneuverability * delta)
	
	# Rotate the car on the slopes
	if($FloorFrontRaycast.is_colliding() and $FloorBackRaycast.is_colliding()):
		var pf : Vector3 = $FloorFrontRaycast.get_collision_point()
		var pb : Vector3 =$FloorBackRaycast.get_collision_point()
		var slope = pb.direction_to(pf)
		target_rotation = Vector3(slope.y,0,0)
	if($FloorLeftRaycast.is_colliding() and $FloorRightRaycast.is_colliding()):
		var pl : Vector3 = $FloorLeftRaycast.get_collision_point()
		var pr : Vector3 = $FloorRightRaycast.get_collision_point()
		var slope = pl.direction_to(pr)
		target_rotation = Vector3(target_rotation.x,0,slope.y)
	
	if($FastLaneDetector.get_overlapping_areas()):
		var fast_lane : Area3D = $FastLaneDetector.get_overlapping_areas()[0]
		var lane_dir = Vector2(fast_lane.basis.z.x, fast_lane.basis.z.z).normalized()
		var car_dir = Vector2(forward.x, forward.z).normalized()
		external_impulse = (lane_dir + car_dir).length()/2
		if(external_impulse < 0.7):
			external_impulse = 0
		external_impulse = RacingZero.FAST_LANE_IMPULSE * external_impulse
		
	
	current_speed += desired_acceleration * delta
	current_speed = clamp(current_speed, -max_speed, max_speed)
	
	# we are not trying to go forward or backwards
	if(desired_acceleration == 0):
		current_speed = lerp(current_speed, 0.0, friction*delta)
	# we are accelerating in the opposite direction of our current movement
	elif(current_speed != 0 and sign(current_speed) != sign(desired_acceleration)):
		current_speed = lerp(current_speed, 0.0, break_power*delta)
		velocity = velocity.lerp(Vector3.ZERO, delta * 1)
	
	# Apply speed
	velocity += forward * current_speed
	if(!is_on_floor()):
		velocity += Vector3.DOWN * 9.8
	
	# Colliding with a wall slows you down
	if(is_on_wall()):
		velocity = velocity.lerp(Vector3.ZERO, 10 * delta)
		current_speed = lerp(current_speed, 0.0, 5 * delta)
	
	# Not accelerating slows you slowly
	if(desired_acceleration == 0):
		# Even more when you are very slow
		if(velocity.length() < 8.0):
			velocity = velocity.lerp(Vector3.ZERO, 25 * delta)
		elif(velocity.length() < 16.0):
			velocity = velocity.lerp(Vector3.ZERO, 6 * delta)
		else:
			velocity = velocity.lerp(Vector3.ZERO, 3 * delta)
	else:
		# Usual friction
		velocity = velocity.lerp(Vector3.ZERO, 4 * delta)
	# no clamping
	velocity += forward * external_impulse
	move_and_slide()
	$MeshInstance3D.rotation = lerp($MeshInstance3D.rotation, target_rotation, 0.3)
	# If we add other types of impulses we will have to split this
	external_impulse = lerp(external_impulse, 0.0, delta * RacingZero.FAST_LANE_DECAY)
