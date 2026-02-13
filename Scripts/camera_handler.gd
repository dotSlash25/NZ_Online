extends Camera2D

func _process(delta: float) -> void:
	offset = lerp(offset, Vector2.ZERO, 0.02)
