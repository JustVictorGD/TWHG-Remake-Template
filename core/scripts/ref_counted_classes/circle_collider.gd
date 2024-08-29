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
			if position.distance_squared_to(shape.position) < (radius + shape.radius) ** 2:
				return true
		
		elif shape is PointCollider:
			if position.distance_squared_to(shape.position) <= radius ** 2:
				return true
		
		# STILL NOT IMPLEMENTED.
		elif shape is RectangleCollider:
			if not is_zero_approx(shape.rotation):
				position = position.rotated(-shape.rotation)
		
		else:
			push_warning("You're attempting to check intersection with an unrecognized collider.")
			return false
	
	return false
