extends Node2D

var point: PointCollider = PointCollider.new()

var rect: RectangleCollider = RectangleCollider.new()
var rect_2: RectangleCollider = RectangleCollider.new()

@onready var enemy_1: Node2D = $BlueEnemy
@onready var enemy_2: Node2D = $BlueEnemy2
@onready var enemy_3: Node2D = $BlueEnemy3

@onready var circle_1: CircleCollider = enemy_1.hitbox
@onready var circle_2: CircleCollider = enemy_2.hitbox
@onready var circle_3: CircleCollider = enemy_3.hitbox

@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2

func _ready() -> void:
	rect.position = color_rect.position
	rect.size = color_rect.size
	rect.rotation = color_rect.rotation
	rect.pivot_offset = color_rect.pivot_offset
	
	rect_2.position = color_rect_2.position
	rect_2.size = color_rect_2.size
	rect_2.rotation = color_rect_2.rotation
	rect_2.pivot_offset = color_rect_2.pivot_offset
	
	print(rect.intersects(rect_2))
	print(rect.get_center())
	print(rect_2.get_center())
