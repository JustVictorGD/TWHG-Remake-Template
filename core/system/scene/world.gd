@icon("res://core/misc_assets/images/node_icons/world.png")
extends Node2D
class_name World

# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

# Used for level switching.
var connections: Dictionary = json_to_dict("res://game/levels/connections.json")
var current_level: Area = null

var canvas_layer: CanvasLayer = CanvasLayer.new()
var interface: Interface = preload("res://core/system/interface/interface.tscn").instantiate()
var camera: Camera2D = Camera2D.new()
var player: Player = preload("res://core/system/player/player.tscn").instantiate()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("1"):
		switch_level("1")
	
	if event.is_action_pressed("2"):
		switch_level("2")


func _ready() -> void:
	add_child(canvas_layer)
	canvas_layer.add_child(interface)
	add_child(camera)
	add_child(player)
	
	focus_camera(current_level)


func focus_camera(area: Area) -> void:
	if area == null:
		return
	
	camera.zoom.x = PLAYABLE_WINDOW.size.x / (area.area_size.x * 48)
	camera.zoom.y = camera.zoom.x
	
	# The "area_size" of areas is measured in tiles, which are 48x48 pixels in size.
	# The value in pixels is halved because the halfway point is needed.
	camera.offset = area.position + Vector2(area.area_size) / 2 * 48


func switch_level(key: Variant) -> void:
	if connections.has(key):
		if current_level != null:
			current_level.queue_free()
		
		var something: String = connections[key]
		
		current_level = load(something).instantiate()
		
		add_child(current_level)
		focus_camera(current_level)
		
		for node: Node in get_tree().get_nodes_in_group("checkpoints"):
			if node is Checkpoint:
				if node.is_start():
					player.position = node.position


static func try_get(array: Array, index: int) -> Variant:
	# Negative check
	if index < 0:
		if index * -1 <= array.size():
			return array[index]
	else:
		if abs(index) <= array.size() - 1:
			return array[index]
	
	return null


static func json_to_dict(json_path: String) -> Dictionary:
	var item_def_file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	
	var item_lookup: Dictionary = JSON.parse_string(item_def_file.get_as_text())
	item_def_file.close()
	
	return item_lookup
