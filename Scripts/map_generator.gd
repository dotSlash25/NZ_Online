class_name MapGenerator
extends Node

const DIRECTIONS = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]

var position = Vector2.ZERO
var direction = Vector2.RIGHT
var borders = Rect2()
var step_history = []
var steps_since_turn = 0
var spawn_points : Array[Vector2] = []

func _init(new_borders: Rect2, _seed):
	seed(_seed)
	var starting_position = Vector2(randi() % int(new_borders.size.x), randi() % int(new_borders.size.y))
	assert(new_borders.has_point(starting_position))
	position = starting_position
	step_history.append(position)
	borders = new_borders

func walk(steps):
	for s in steps:
		if steps_since_turn >= 12:
			change_direction()
		
		if step():
			step_history.append(position)
			if (randi() % 100 < 4): spawn_points.append(position)
			if (randi() % 100 < 30): change_direction()
		else:
			change_direction()
	return step_history

func step():
	var target_position = position + direction
	if borders.has_point(target_position):
		steps_since_turn += 1
		position = target_position
		return true
	else:
		return false

func change_direction():
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.shuffle()
	direction = directions.pop_front()
	while not borders.has_point(position + direction):
		direction = directions.pop_front()

func get_spawn_points() -> Array[Vector2]:
	return spawn_points
