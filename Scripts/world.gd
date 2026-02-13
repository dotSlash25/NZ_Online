extends Node2D

@onready var players: Node2D = $Players
const player_scene = preload("res://Scenes/Player.tscn")
const TOUCH_CONTROLS = preload("uid://b0bbnkndhe5vr")

var mobile : bool = false

func add_player(id: int):
	var p = player_scene.instantiate()
	p.name = str(id)
	p.global_position = $SpawnPoints.get_child(players.get_child_count()).global_position
	print("Player ", id, " spawned at ", p.global_position)
	return p

func _ready() -> void:
	mobile = OS.get_name().to_lower() in ["android", "ios"]
	if mobile:
		Input.set("emulate_mouse_from_touch", false)
		add_child(TOUCH_CONTROLS.instantiate())
		
	if(multiplayer.is_server()):
		var seed = randi()
		$TileMapLayer.build_map(seed)
		$TileMapLayer.build_map.rpc(seed)
	#await multiplayer.connected_to_server
	$MultiplayerSpawner.spawn_function = add_player
	
	if multiplayer.is_server():
		for id in multiplayer.get_peers():
			$MultiplayerSpawner.spawn(id)
		$MultiplayerSpawner.spawn(multiplayer.get_unique_id())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func request_respawn():
	print("respawning")
	return $SpawnPoints.get_child(randi() % $SpawnPoints.get_child_count()).global_position
