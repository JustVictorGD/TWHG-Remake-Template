@icon("res://core/misc_assets/images/node_icons/world.png")
extends Node2D
class_name World

# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

## Used for turning the world node into a sort of singleton for easier access.
static var instance: World

## Enter a key from "res://game/connections.json" here, and the associated
## file path will be loaded if it's an area scene.
@export var starting_level_code: String

# Important nodes.
@onready var canvas_layer: CanvasLayer = $UILayer
@onready var interface: Interface = $UILayer/Interface
@onready var camera: Camera2D = $Camera2D
@onready var player: Player = $Player
@onready var shader_container: Control = $Camera2D/ShaderLayer/ShaderContainer # Contains all the full screen shaders and scales them to fit the game window

# Level switching.
var connections: Dictionary = json_to_dict("res://game/connections.json")
var active_level: Area = null


func _ready() -> void:
	instance = self
	GameManager.starting_level_code = self.starting_level_code
	
	Signals.switch_level.connect(queue_switch_level)
	Signals.load_game.connect(load_game)
	
	SaveData.load_game()


func load_game() -> void:
	queue_switch_level(Utilities.fallback(
		SaveData.try_get_data(["global", "current_level"]),
		starting_level_code
		))


func queue_switch_level(key: String, teleport_position: Vector2 = Vector2.ZERO) -> void:
	call_deferred("switch_level", key, teleport_position)


func switch_level(key: String, teleport_position: Vector2 = Vector2.ZERO) -> void:
	if key == "NULL_LEVEL":
		key = starting_level_code
	
	if not connections.has(key):
		push_error("Level switch failed: The key '", key, "' does not exist in connections.json")
		return
	
	if active_level != null:
		remove_child(active_level)
		active_level.queue_free()
	
	Signals.level_switched.emit()
	GameManager.current_level = key
	IdGenerator.data = {}
	
	active_level = load(connections[key]).instantiate()
	
	GameManager.finished = false
	GameManager.invincible = false
	
	GameManager.collected_money = 0
	GameManager.money_requirement = 0
	GameManager.walls.clear()
	
	player.change_size(active_level.player_size)
	
	add_child(active_level)
	focus_camera(active_level)
	
	load_room_state(active_level.get_last_checkpoint_id(), teleport_position)


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


func load_room_state(checkpoint_id: int = -1, teleport_position: Vector2 = Vector2.ZERO) -> void:
	GameManager.collectables_processed = true
	
	# Assign checkpoint ids and spawn the player on the correct one
	var checkpoints: Array[Node] = get_tree().get_nodes_in_group("checkpoints") as Array[Node]
	
	if teleport_position != Vector2.ZERO:
		player.move_to(Vector2i(teleport_position * 1000))
		return
	
	# this code needs to be cleaned up so much
	if checkpoint_id != -1:
		if Utilities.index_in_range(checkpoint_id, checkpoints.size()):
			player.move_to((checkpoints[checkpoint_id].global_position + \
					checkpoints[checkpoint_id].size / 2) * 1000)
			checkpoints[checkpoint_id].state = Checkpoint.states.SELECTED
		else:
			push_error("Checkpoint ID was out of range when loading the level.")
	else:
		for i: int in range(checkpoints.size()):
			if checkpoints[i].is_start():
				player.move_to((checkpoints[i].global_position + checkpoints[i].size / 2) * 1000)
				checkpoints[i].state = Checkpoint.states.SELECTED
				return
			push_error("No starting checkpoint found.")


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
