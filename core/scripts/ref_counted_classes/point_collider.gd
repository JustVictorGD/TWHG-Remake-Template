extends AbstractCollider
class_name PointCollider

var position: Vector2

func _init(_position: Vector2 = Vector2.ZERO) -> void:
	position = _position

func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			return position.distance_squared_to(shape.position) < shape.radius ** 2
		
		elif shape is PointCollider:
			return false # Infinitely small points can have no intersection.
		
		elif shape is RectangleCollider:
			var relative_point: Vector2 = position - shape.position
			relative_point -= shape.pivot_offset
			if not is_zero_approx(shape.rotation): relative_point = relative_point.rotated(-shape.rotation)
			relative_point += shape.pivot_offset
			return relative_point > Vector2.ZERO and relative_point < shape.size
		
		else:
			push_warning("You're attempting to check if a PointCollider intersects with an unrecognized collider.")
	
	return false
