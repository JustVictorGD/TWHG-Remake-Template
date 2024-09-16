extends Node2D
class_name Area

@export var bottom_text: String = ""
@export var theme: AreaTheme
@export var area_size: Vector2i = Vector2(32, 20)

# Multi-area travel purposes.
@onready var bounding_box: Rect2 = Rect2(self.global_position, area_size * 48)

func _ready() -> void:
	GameManager.area_bounds[self] = bounding_box
