extends RefCounted
class_name AbstractCollider

# This class primarily exists to give all extending colliders something
# in common, though this "enabled" definitely saves so much space.

var enabled: bool = true

func create_rect_with_radius(position: Vector2, radius: float) -> Rect2:
	return Rect2(position - Vector2(radius, radius), Vector2(radius * 2, radius * 2))

func point_in_rect(point: Vector2, rect: Rect2) -> bool:
	return rect.position.x < point.x and point.x < rect.end.x and \
			rect.position.y < point.y and point.y < rect.end.y
