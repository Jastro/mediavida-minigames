extends Node3D
class_name RacingZero
# Defs
enum EHoverCar {
	TestCar,
}

const L_FAST_LANE		: int	= 8
const FRICTION			: float = 0.2
const FAST_LANE_IMPULSE : float = -10.0
const FAST_LANE_DECAY	: float = 3.0

var ACCEL = {
	EHoverCar.TestCar : 35.0,
}

var MAX_SPEED = {
	EHoverCar.TestCar : 350.0,
}

var MAX_SPEED_REVERSE = {
	EHoverCar.TestCar : 20.0,
}

var MANEUVERABILITY = {
	EHoverCar.TestCar : 1.0,
}

var BREAK = {
	EHoverCar.TestCar : 1.0,
}
