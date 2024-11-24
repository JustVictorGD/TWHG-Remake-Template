@icon("res://core/misc_assets/images/node_icons/world.png")
extends Node2D
class_name World

# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

## Enter a key from "res://game/connections.json" here, and the associated
## file path will be loaded if it's an area scene.
@export var starting_level: String

# Tracking objects and game state.
static var walls: Array[Rect2] = []
static var collected_money: int = 0
static var money_requirement: int = 0

# Important nodes.
var canvas_layer: CanvasLayer = CanvasLayer.new()
var interface: Interface = preload("res://core/system/interface/interface.tscn").instantiate()
var camera: Camera2D = Camera2D.new()
var player: Player = preload("res://core/system/player/player.tscn").instantiate()

# Level switching.
var connections: Dictionary = json_to_dict("res://game/connections.json")
static var current_level: Area = null


func _ready() -> void:
	add_child(canvas_layer)
	canvas_layer.add_child(interface)
	add_child(camera)
	add_child(player)
	
	focus_camera(current_level)
	
	GlobalSignal.switch_level.connect(switch_level)
	
	switch_level(starting_level)


func focus_camera(area: Area) -> void:
	if area == null:
		return
	
	camera.zoom.x = PLAYABLE_WINDOW.size.x / (area.area_size.x * 48)
	camera.zoom.y = camera.zoom.x
	
	# The "area_size" of areas is measured in tiles, which are 48x48 pixels in size.
	# The value in pixels is halved because the halfway point is needed.
	camera.offset = area.position + Vector2(area.area_size) / 2 * 48


func switch_level(key: String) -> void:
	if connections.has(key):
		if current_level != null:
			current_level.queue_free()
		
		walls.clear()
		
		GlobalSignal.level_switched.emit()
		
		current_level = load(connections[key]).instantiate()
		
		GameManager.finished = false
		GameManager.invincible = false
		
		collected_money = 0
		money_requirement = 0
		
		
		add_child(current_level)
		focus_camera(current_level)
		
		var checkpoints: Array[Node] = get_tree().get_nodes_in_group("checkpoints")
		
		for i: int in range(checkpoints.size()):
			checkpoints[i].id = i
			
			if checkpoints[i].is_start():
				player.move_to(checkpoints[i].hitbox.get_center() * 1000 + Vector2(500, 500))
	else:
		push_error("Level switch failed: The key '", key, "' does not exist in connections.json")


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
