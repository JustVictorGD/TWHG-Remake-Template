extends Node2D

var point: PointCollider = PointCollider.new()

var rect: RectangleCollider = RectangleCollider.new()
var rect_2: RectangleCollider = RectangleCollider.new()

var circle_1: CircleCollider = CircleCollider.new()
var circle_2: CircleCollider = CircleCollider.new()
var circle_3: CircleCollider = CircleCollider.new()

@onready var enemy_1: Node2D = $BlueEnemy
@onready var enemy_2: Node2D = $BlueEnemy2
@onready var enemy_3: Node2D = $BlueEnemy3

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
	
	circle_1.position = enemy_1.position
	circle_1.radius = enemy_1.radius
	
	circle_2.position = enemy_2.position
	circle_2.radius = enemy_2.radius
	
	circle_3.position = enemy_3.position
	circle_3.radius = enemy_3.radius
	
	print(rect.intersects(rect_2))
