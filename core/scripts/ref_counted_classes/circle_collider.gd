extends AbstractCollider
class_name CircleCollider

var position: Vector2
var radius: float

func _init(_position: Vector2 = Vector2.ZERO, _radius: float = 0) -> void:
	position = _position
	radius = _radius

func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			if create_rect_with_radius(position, radius).intersects(\
					create_rect_with_radius(shape.position, shape.radius)):
				return position.distance_squared_to(shape.position) < (radius + shape.radius) ** 2
		
		elif shape is PointCollider:
			return position.distance_squared_to(shape.position) < radius ** 2
		
		elif shape is RectangleCollider:
			var relative_point: Vector2 = position - shape.position
			relative_point -= shape.pivot_offset
			
			if not is_zero_approx(shape.rotation):
				relative_point = relative_point.rotated(-shape.rotation)
			
			relative_point += shape.pivot_offset
			
			var nearest_point: Vector2 = Vector2(
				clamp(relative_point.x, 0, shape.size.x),
				clamp(relative_point.y, 0, shape.size.y))
			
			return relative_point.distance_squared_to(nearest_point) < radius ** 2
		
		else:
			push_warning("You're attempting to check intersection with an unrecognized collider.")
			return false
	
	return false
