extends Node2D

var point: PointCollider = PointCollider.new()

var rect: RectangleCollider = RectangleCollider.new()
var rect_2: RectangleCollider = RectangleCollider.new()

@onready var enemy_1: Node2D = $BlueEnemy
@onready var enemy_2: Node2D = $BlueEnemy2
@onready var enemy_3: Node2D = $BlueEnemy3
@onready var enemy_4: Node2D = $BlueEnemy4

@onready var circle_1: CircleCollider = enemy_1.hitbox
@onready var circle_2: CircleCollider = enemy_2.hitbox
@onready var circle_3: CircleCollider = enemy_3.hitbox

@onready var color_rect: ColorRect = $ColorRect
@onready var color_rect_2: ColorRect = $ColorRect2

func _ready() -> void:
	rect.set_properties(
		color_rect.global_position,
		color_rect.size,
		color_rect.rotation,
		color_rect.pivot_offset
	)
	
	
	
	
	
	var vertices: PackedVector2Array = rect.get_vertices()
	
	enemy_1.position = vertices[0]
	enemy_2.position = vertices[1]
	enemy_3.position = vertices[2]
	enemy_4.position = vertices[3]
	
	print(color_rect.position, ", ", color_rect.global_position)
	print(color_rect_2.position, ", ", color_rect_2.global_position)
	#print(rect.intersects(rect_2))
	#print(rect.get_center())
	#print(rect_2.get_center())
