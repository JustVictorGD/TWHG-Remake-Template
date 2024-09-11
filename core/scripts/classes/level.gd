extends Node2D
class_name Level

# On a 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

var interface: Control = preload("res://core/game_objects/interface.tscn").instantiate()
var canvas_layer: CanvasLayer = CanvasLayer.new()
var camera: Camera2D = Camera2D.new()

var current_area: Area

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(camera)
	add_child(canvas_layer)
	canvas_layer.add_child(interface)
	
	for area: Node in get_children():
		if area is Area:
			print(area.name)

func change_area(area: Area) -> void:
	camera.zoom.x = PLAYABLE_WINDOW.size.x / (area.area_size.x * 48)
	camera.zoom.y = camera.zoom.x
	
	camera.offset = area.bounding_box.position + area.bounding_box.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
