extends Node2D

var child: Gun = null

var joypad_mode := false
var mobile := false
var joypad_id := 0
var look_input := Vector2.ZERO
var facing_right := false

@export var joystick_deadzone : float = 0.05

func _ready() -> void:
	update_child()
	Input.joy_connection_changed.connect(check_joystick)
	joypad_mode = len(Input.get_connected_joypads()) > 0
	mobile = OS.get_name().to_lower() in ["android", "ios"]

func update_child() -> void:
	if get_child_count():
		child = get_child(0)
	else:
		child = null

func _physics_process(_delta: float) -> void:
	if !get_parent().is_multiplayer_authority(): 
		return
	
	var look_changed := false
	if joypad_mode:
		var right_axis := Vector2(Input.get_joy_axis(joypad_id, JOY_AXIS_RIGHT_X), Input.get_joy_axis(joypad_id, JOY_AXIS_RIGHT_Y))
		print(right_axis)
		look_input = global_position + right_axis
		if not right_axis.length() < joystick_deadzone:
			look_changed = true
	elif mobile:
		var input := Input.get_vector("look_left", "look_right", "look_up", "look_down")
		look_input = input + global_position
		if not input.is_zero_approx():
			look_changed = true
	else:
		look_changed = true
		look_input = get_global_mouse_position()
	
	if look_changed:
		rotation = lerp_angle(rotation, (look_input - global_position).angle(), 0.2)
		facing_right = look_input.x > global_position.x
		if not facing_right: 
			child.flip_v = true
		else:
			child.flip_v = false
	
	var shoot_input : bool = Input.is_action_pressed("fire") if child.automatic else Input.is_action_just_pressed("fire")
	
	if shoot_input:
		child.shoot()

func check_joystick(device_id: int, connected: bool):
	joypad_mode = connected
	joypad_id = device_id
