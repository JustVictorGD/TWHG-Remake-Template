extends AbstractCollider
class_name PointCollider

var position: Vector2

func init(_position: Vector2) -> void:
	position = _position

func intersects(shape: AbstractCollider) -> bool:
	if shape is CircleCollider:
		pass
	
	if shape is PointCollider:
		if is_equal_approx(position.x, shape.position.x) and \
				is_equal_approx(position.y, shape.position.y):
			return true
	
	if shape is RectangleCollider:
		pass
	
	return false
