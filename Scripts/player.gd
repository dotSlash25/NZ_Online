class_name Player
extends CharacterBody2D

const SPEED := 80.0

@export var health: float = 100
const MAX_HEALTH: float = 100

@export var kills: int = 0

@export var is_terrorist: bool = true

@onready var gun_pivot: Node2D = $GunPivot
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _enter_tree() -> void:
	set_multiplayer_authority(int(name))

func _ready() -> void:
	if is_multiplayer_authority():
		$Camera2D.enabled = true
	else:
		$PointLight2D.queue_free()
	$MultiplayerSynchronizer.set_multiplayer_authority(int(name))
	$StatsSync.set_multiplayer_authority(1)
	if not is_terrorist:
		$AnimatedSprite2D.sprite_frames = load("res://Misc/counter_terrorist_frames.tres")
	
func _physics_process(_delta: float) -> void:
	$Control/TextureProgressBar.value = health
	$Control/Label.text = str(kills)
	
	if not is_multiplayer_authority(): return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	direction = direction.normalized()
	
	if direction == Vector2.ZERO: sprite.play("idle")
	else: sprite.play("run")
	
	sprite.flip_h = not gun_pivot.facing_right
	
	velocity = direction * SPEED

	move_and_slide()
	

@rpc("any_peer", "call_local")
func take_damage(dmg, attacker_id):
	if not multiplayer.is_server(): return
	health -= dmg
	print(name, " : ", health)
	if health <= 0:
		die(attacker_id)
		health = MAX_HEALTH

func die(killer_id):
	var attacker = get_parent().get_node_or_null(str(killer_id))
	print(name, " was killed by ", killer_id)
	print("requesting respawn")
	respawn.rpc_id(int(name), get_parent().get_parent().request_respawn())
	if attacker:
		attacker.kills += 1

@rpc("call_local", "any_peer")
func respawn(pos):
	global_position = pos


func _on_body_area_entered(area: Area2D) -> void:
	var item := area.get_parent()
	if item is Bomb:
		if not item.equipped:
			item.call_deferred("reparent", self, false)
			item.equip()
