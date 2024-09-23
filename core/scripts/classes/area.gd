extends Node2D
class_name Area

## Remember how areas could have coordinates like A1 and B4?
## Due to them being off-grid, you need to set them manually.
@export var displayed_coordinates: String = "Z0"
@export var bottom_text: String = ""
@export var theme: AreaTheme
@export var area_size: Vector2i = Vector2(32, 20)

# Multi-area travel purposes.
var boundary: Rect2

@onready var edges: Dictionary = {
	"up": RectangleCollider.new(Rect2(boundary.position, Vector2(boundary.size.x, 0))),
	"left": RectangleCollider.new(Rect2(boundary.position, Vector2(0, boundary.size.y))),
	"down": RectangleCollider.new(Rect2(boundary.position.x, boundary.end.y, boundary.size.x, 0)),
	"right": RectangleCollider.new(Rect2(boundary.end.x, boundary.position.y, 0, boundary.size.y))
}

var id: int = -1

# Activates VERY early, before any call of ready().
func _enter_tree() -> void:
	add_to_group("areas")
