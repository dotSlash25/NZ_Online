extends Node2D

@export var stack_size : int = 10
@export var tracer_speed : float = 30
@export var phi : float = 0.2

@onready var line: Line2D = $Line2D
const HIT_PARTICLES = preload("uid://dk6r6v4len03y")

var final_pos : Vector2
var time_passed : float = 0

const life_time := 1.0

func init(pos:Vector2, final: Vector2) -> void:
	global_position = pos
	final_pos = final
	phi = randf_range(0.1, 0.3)

func _ready() -> void:
	var end_pos := line.to_local(final_pos)
	line.add_point(lerp(Vector2.ZERO, end_pos, phi))
	line.add_point(Vector2.ZERO)
	var hit_effect := HIT_PARTICLES.instantiate()
	hit_effect.position = position + end_pos
	get_parent().add_child(hit_effect)

func _physics_process(delta: float) -> void:
	for i in range(2):
		var new_pos := line.get_point_position(i)
		new_pos = lerp(new_pos, line.to_local(final_pos), tracer_speed * delta)
		line.set_point_position(i, new_pos)
	time_passed += delta
	if time_passed >= life_time:
		queue_free()
