extends AbstractCollider
class_name RectangleCollider

var bounding_box: Rect2
var rotation: float

func init(given_box: Rect2, given_rotation: float = 0) -> void:
	bounding_box = given_box
	rotation = given_rotation

func intersects(shape: AbstractCollider) -> bool:
	if shape is CircleCollider:
		pass
	
	if shape is PointCollider:
		pass
	
	if shape is RectangleCollider:
		pass
	
	return false
