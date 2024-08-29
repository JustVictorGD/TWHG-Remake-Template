extends Node2D


var point_1: PointCollider = PointCollider.new()
var point_2: PointCollider = PointCollider.new(Vector2(32, 32))

var circle_1: CircleCollider = CircleCollider.new(Vector2(16, 16), 16)
var circle_2: CircleCollider = CircleCollider.new(Vector2(24, 24), 16)
var circle_3: CircleCollider = CircleCollider.new(Vector2(32, 32), 16)
var circle_4: CircleCollider = CircleCollider.new(Vector2(16, 16), 32)

var rect_1: RectangleCollider = RectangleCollider.new()

var unknown: AbstractCollider = AbstractCollider.new()

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	rect_1.position = color_rect.position
	rect_1.size = color_rect.size
	rect_1.rotation = color_rect.rotation
	rect_1.pivot_offset = color_rect.pivot_offset
	
	print(point_1.intersects(rect_1))
