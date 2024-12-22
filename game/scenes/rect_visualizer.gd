extends Node2D
class_name DataVisualizer

@export var active: bool = true

static var red_walls: Array[Rect2i] = []
static var vectors: Array[Rect2i] = []


func _physics_process(_delta: float) -> void:
	if active:
		queue_redraw()


func _draw() -> void:
	for i: int in range(red_walls.size()):
		if i <= 4:
			draw_rect(red_walls[i], Color(1, i * 0.25, 0, 0.25))
		
		elif i <= 6:
			draw_rect(red_walls[i], Color(3 - i * 0.5, 1, 0, 0.25))
		
		else:
			draw_rect(red_walls[i], Color(0, 1, (-3) + i * 0.5, 0.25))
	
	for vector: Rect2i in vectors:
		draw_line(vector.position, vector.position + vector.size * 8, Color(0.25, 1, 0, 0.75), 6, true)
		draw_line(vector.position, vector.position - vector.size * 8, Color(1, 0, 0.25, 0.75), 6, true)
		draw_circle(vector.position, 12, Color(1, 1, 1, 1), true, -1, true)
	
	red_walls.clear()
	vectors.clear()
