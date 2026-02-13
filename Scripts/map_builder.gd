extends TileMapLayer

var generator : MapGenerator

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

@rpc("authority")
func build_map(_seed: int) -> void:
	generator = MapGenerator.new(Rect2(0, 0, 71, 39), _seed)
	var steps = generator.walk(1000)
	var spawnpoints = generator.get_spawn_points()
	for spawnpoint in spawnpoints:
		spawnpoint = to_global(map_to_local(spawnpoint))
		var marker = Marker2D.new()
		marker.position = spawnpoint
		$"../SpawnPoints".add_child(marker)
	for step in steps:
		set_cell(step, 0, Vector2(randi() % 4, 2))
	for cell in get_used_cells():
		if get_cell_atlas_coords(cell).y == 0 and get_cell_atlas_coords(cell + Vector2i(0, 1)).y != 0:
			set_cell(cell + Vector2i(0, 1), 0, Vector2(randi() % 4, 1))
	generator.queue_free()
