extends Node2D
class_name MultiAreaLevel

var interface: Control = preload("res://core/game_objects/interface.tscn").instantiate()
var canvas_layer: CanvasLayer = CanvasLayer.new()
var camera: Camera2D = Camera2D.new()

var current_area: WhgArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.offset = Vector2(768, 480)
	camera.zoom = Vector2(0.625, 0.625)
	
	add_child(camera)
	add_child(canvas_layer)
	canvas_layer.add_child(interface)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
