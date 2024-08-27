extends AbstractCollider
class_name CircleCollider

var position: Vector2
var radius: float

func init(_position: Vector2, _radius: float) -> void:
	position = _position
	radius = _radius

func intersects(shape: AbstractCollider) -> bool:
	if shape is CircleCollider:
		pass
	
	if shape is PointCollider:
		pass
	
	if shape is RectangleCollider:
		pass
	
	return false
