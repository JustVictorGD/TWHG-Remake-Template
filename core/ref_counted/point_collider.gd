extends AbstractCollider
class_name PointCollider

func _init(_position: Vector2 = Vector2.ZERO) -> void:
	position = _position

func _to_string() -> String:
	return str("[Enabled: ", enabled, ", Position: ", position, "]")

func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			return global_position.distance_squared_to(shape.global_position) < shape.global_radius ** 2
		
		elif shape is PointCollider:
			return false # Infinitely small points can have no intersection.
		
		elif shape is RectangleCollider:
			if is_zero_approx(shape.rotation):
				return Rect2(global_position, Vector2.ZERO).intersects(Rect2(shape.global_position, shape.scale))
			
			var relative_point: Vector2 = global_position - shape.global_position
			relative_point -= shape.pivot_offset
			if not is_zero_approx(shape.rotation): relative_point = relative_point.rotated(-shape.rotation)
			relative_point += shape.pivot_offset
			return relative_point > Vector2.ZERO and relative_point < shape.scale
		
		else:
			push_warning("You're attempting to check if a PointCollider intersects with an unrecognized collider.")
	
	return false
