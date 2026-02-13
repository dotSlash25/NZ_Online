class_name Bomb
extends Node2D

@export var plant_time: float = 5.0
@export var defuse_time: float = 5.0
@export var detonation_time: float = 45.0

var equipped := false

var time_passed: float = 0
var planting := false
var defusing := false

var planted := false
var defused := false
var plant_position: Vector2

func _ready() -> void:
	pass

func equip() -> void:
	$AnimatedSprite2D.hide()

func _physics_process(delta: float) -> void:
	
	if (planting): 
		time_passed += delta
		if (time_passed > plant_time):
			planted = true
			$AnimatedSprite2D.show()
			time_passed = 0
			$Timer.start(detonation_time)
	elif not planted: 
		time_passed = 0
	
	if (defusing): 
		time_passed += delta
		if (time_passed > defuse_time):
			defused = true
			#TODO Add gamemanager game won CT
	elif not defused: 
		time_passed = 0

func detonate() -> void:
	#TODO Add gamemanager game won T
	pass
