class_name Gun extends Node2D

@export var max_bullets : int
@export var magazines : int
@export var automatic : bool
@export var spread_number : int = 1
@export var firerate : float
@export var base_inaccuracy : float
@export var inaccuracy_gain : float
@export var inaccuracy_falloff : float
@export var reload_time : float
@export var damage : float
@export var headshot_multiplier : float
@export var shoot_range : float
@export var scope : float
@export var kickback : float

var equipped : bool = false
var current_bullets : int = 0
var current_inaccuracy : float = 0
var last_fired : float = 0
var flip_v : bool = false

@onready var raycast: RayCast2D = $Sprite/RayCast2D
@onready var sprite: Sprite2D = $Sprite
@onready var crosshair: Node2D = $Sprite/Muzzle/Crosshair

const TRACERS = preload("res://Scenes/Effects/tracers.tscn")

func _ready() -> void:
	set_multiplayer_authority(multiplayer.get_unique_id())
	set_process(is_multiplayer_authority())
	current_bullets = max_bullets
	raycast.target_position.x = shoot_range

func _process(delta: float) -> void:
	crosshair.rotation = lerp_angle(crosshair.rotation, 0, 0.2)
	sprite.flip_v = flip_v
	last_fired -= delta
	current_inaccuracy = base_inaccuracy + (current_inaccuracy - base_inaccuracy) * exp(-delta / inaccuracy_falloff)
	crosshair.scale = Vector2.ONE * current_inaccuracy


func shoot() -> void:
	if last_fired <= 0 and current_bullets > 0:
		shoot_process()
		current_bullets -= 1

func shoot_process() -> void:
	raycast.target_position.y = current_inaccuracy * randf_range(-1, 1)
	last_fired = firerate
	current_inaccuracy += inaccuracy_gain
	crosshair.rotate(randf_range(-2, 2))
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var headshot : bool = collider.name == "Head"
		collider = collider.get_parent().get_parent()
		if collider is Player:
			var actual_damage = damage
			if headshot: actual_damage *= headshot_multiplier
			collider.take_damage.rpc(actual_damage, multiplayer.get_unique_id())
		instantiate_tracer(raycast.get_collision_point())
	else:
		instantiate_tracer(global_position + raycast.target_position.rotated(global_rotation))

func instantiate_tracer(final_pos: Vector2) -> void:
	var tracer := TRACERS.instantiate()
	tracer.init($Sprite/Muzzle.global_position, final_pos)
	get_tree().current_scene.get_node("Effects").add_child(tracer)
	var ang_del := randf_range(-0.1, 0.1)
	get_viewport().get_camera_2d().offset += Vector2.from_angle(rotation + ang_del) * kickback
