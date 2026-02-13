extends CanvasLayer

@onready var left_stick: VirtualJoystickPlus = $left_stick
@onready var right_stick: VirtualJoystickPlus = $right_stick

@export var deadzone: float = 0.01
@export var firezone: float = 0.9

func _process(_delta: float) -> void:
	var left_value: Vector2 = left_stick.value
	var right_value: Vector2 = right_stick.value
	
	if left_value.x > deadzone:
		Input.action_press("right", left_value.x)
	elif left_value.x < -deadzone:
		Input.action_press("left", -left_value.x)
	else:
		Input.action_release("right")
		Input.action_release("left")
	
	if left_value.y > deadzone:
		Input.action_press("down", left_value.y)
	elif left_value.y < -deadzone:
		Input.action_press("up", -left_value.y)
	else:
		Input.action_release("up")
		Input.action_release("down")
	
	if right_value.x > deadzone:
		Input.action_press("look_right", right_value.x)
	elif right_value.x < -deadzone:
		Input.action_press("look_left", -right_value.x)
	else:
		Input.action_release("look_right")
		Input.action_release("look_left")
	
	if right_value.y > deadzone:
		Input.action_press("look_down", right_value.y)
	elif right_value.y < -deadzone:
		Input.action_press("look_up", -right_value.y)
	else:
		Input.action_release("look_up")
		Input.action_release("look_down")
	
	if right_stick.distance > firezone:
		Input.action_press("fire")
	else:
		Input.action_release("fire")
