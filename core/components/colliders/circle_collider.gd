extends AbstractCollider
class_name CircleCollider

@export var radius: float
var lock_scale: bool = true
var global_radius: float:
	get:
		if !lock_scale:
			return radius * global_scale.x # Assuming scale.x and scale.y 
		return radius
		# to be equal as oval colliders are not implemented.

func _init(_position: Vector2 = Vector2.ZERO, _radius: float = 0) -> void:
	position = _position
	radius = _radius


func _to_string() -> String:
	return str("[Enabled: ", enabled, ", Position: ", position, ", Radius: ", radius, "]")


func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			if create_rect_with_radius(global_position, global_radius).intersects(\
					create_rect_with_radius(shape.global_position, shape.global_radius)):
				return global_position.distance_squared_to(shape.global_position) < (global_radius + shape.global_radius) ** 2
		
		elif shape is PointCollider:
			return global_position.distance_squared_to(shape.global_position) < global_radius ** 2
		
		elif shape is RectangleCollider:
			var relative_point: Vector2 = global_position - shape.global_position
			relative_point -= shape.pivot_offset
			
			if not is_zero_approx(shape.rotation):
				relative_point = relative_point.rotated(-shape.rotation)
			
			relative_point += shape.pivot_offset
			
			var nearest_point: Vector2 = Vector2(
				clamp(relative_point.x, 0, shape.scale.x),
				clamp(relative_point.y, 0, shape.scale.y))
			
			return relative_point.distance_squared_to(nearest_point) < global_radius ** 2
		
		else:
			push_warning("You're attempting to check intersection with an unrecognized collider.")
			return false
	
	return false
