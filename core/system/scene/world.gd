@icon("res://core/misc_assets/images/node_icons/world.png")
extends Node2D
class_name World

# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

## Enter a key from "res://game/connections.json" here, and the associated
## file path will be loaded if it's an area scene.
@export var starting_level: String

static var starting_level_static: String

# Tracking objects and game state.
static var walls: Array[Rect2i] = []
static var collected_money: int = 0
static var money_requirement: int = 0
static var touched_checkpoint_ids: PackedInt32Array = []

static var rect_visualizer: Node

# Important nodes.
@onready var canvas_layer: CanvasLayer = $UILayer
@onready var interface: Interface = $UILayer/Interface
@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var shader_container: Control = $Camera2D/ShaderLayer/ShaderContainer # Contains all the full screen shaders and scales them to fit the game window

# Level switching.
var connections: Dictionary = json_to_dict("res://game/connections.json")
static var current_level: Area = null


func _ready() -> void:
	rect_visualizer = $RectVisualizer
	
	# Making it easy for end_screen to reset the game.
	starting_level_static = starting_level
	
	Signals.switch_level.connect(queue_switch_level)
	
	queue_switch_level(starting_level)


func focus_camera(area: Area) -> void:
	if area == null:
		return
	
	camera.zoom.x = PLAYABLE_WINDOW.size.x / (area.area_size.x * 48)
	camera.zoom.y = camera.zoom.x
	shader_container.size = PLAYABLE_WINDOW.size
	shader_container.position = PLAYABLE_WINDOW.position
	
	# The "area_size" of areas is measured in tiles, which are 48x48 pixels in size.
	# The value in pixels is halved because the halfway point is needed.
	camera.position = area.position + Vector2(area.area_size) / 2 * 48


func queue_switch_level(key: String, teleport_position: Vector2 = Vector2.ZERO) -> void:
	call_deferred("switch_level", key, teleport_position)


func switch_level(key: String, teleport_position: Vector2 = Vector2.ZERO) -> void:
	if not connections.has(key):
		push_error("Level switch failed: The key '", key, "' does not exist in connections.json")
		return
	
	if current_level != null:
		remove_child(current_level)
		current_level.queue_free()
	
	Signals.level_switched.emit()
	GameManager.current_level = key
	
	current_level = load(connections[key]).instantiate()
	
	GameManager.finished = false
	GameManager.invincible = false
	
	collected_money = 0
	money_requirement = 0
	walls.clear()
	
	player.change_size(current_level.player_size)
	
	add_child(current_level)
	focus_camera(current_level)
	
	load_room_state(teleport_position)


func load_room_state(teleport_position: Vector2 = Vector2.ZERO) -> void:
	# Assign checkpoint ids and spawn the player on the correct one
	var checkpoints: Array[Node] = get_tree().get_nodes_in_group("checkpoints")
	
	for i: int in range(checkpoints.size()):
		checkpoints[i].id = i
		
		if teleport_position == Vector2.ZERO:
			if checkpoints[i].is_start():
				player.move_to((checkpoints[i].global_position + checkpoints[i].size / 2) * 1000 + Vector2(500, 500))
		else:
			player.move_to(Vector2i(teleport_position * 1000))
			print(player.position)
	
	GameManager.collectables_processed = true
	
	for gold_door: GoldDoor in get_tree().get_nodes_in_group("gold_doors"):
		if collected_money >= gold_door.money_requirement:
			gold_door.stay_triggered()


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


static func get_child_by_name(node: Node, target_name: String) -> Node:
	for child: Node in node.get_children():
		if child.name == target_name:
			return child
	return null
