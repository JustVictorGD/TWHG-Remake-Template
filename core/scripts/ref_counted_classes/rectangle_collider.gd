extends AbstractCollider
class_name RectangleCollider

var position: Vector2
var size: Vector2
var rotation: float
var pivot_offset: Vector2

func _init(bounding_box: Rect2 = Rect2(), _rotation: float = 0, _pivot_offset: Vector2 = Vector2.ZERO) -> void:
	position = bounding_box.position
	size = bounding_box.size
	
	rotation = _rotation
	pivot_offset = _pivot_offset

func intersects(shape: AbstractCollider) -> bool:
	if enabled and shape.enabled:
		if shape is CircleCollider:
			pass
		
		if shape is PointCollider:
			pass
		
		if shape is RectangleCollider:
			pass
	
	return false
