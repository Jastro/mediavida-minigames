extends Node3D
class_name RacingZero
# Defs
enum EHoverCar {
	TestCar,
}

const FRICTION = 0.2

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
