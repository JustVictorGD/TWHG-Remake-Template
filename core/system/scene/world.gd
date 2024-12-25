@icon("res://core/misc_assets/images/node_icons/world.png")
extends Node2D
class_name World

# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

## Enter a key from "res://game/connections.json" here, and the associated
## file path will be loaded if it's an area scene.
@export var starting_level: String

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("0"):
		print(SaveFile.save_dictionary)


func _ready() -> void:
	rect_visualizer = $RectVisualizer
	
	#add_child(canvas_layer)
	#canvas_layer.add_child(interface)
	#add_child(camera)
	#add_child(player)
	
	focus_camera(current_level)
	
	GlobalSignal.switch_level.connect(switch_level)
	
	var stored_level: String = SaveFile.save_dictionary["global"]["level"]
	
	switch_level(starting_level if stored_level == "" else stored_level)

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


func switch_level(key: String) -> void:
	if not connections.has(key):
		push_error("Level switch failed: The key '", key, "' does not exist in connections.json")
		return
	
	if current_level != null:
		current_level.queue_free()
		await current_level.tree_exited
	
	GlobalSignal.level_switched.emit()
	GameManager.current_level = key
	
	current_level = load(connections[key]).instantiate()
	
	GameManager.finished = false
	GameManager.invincible = false
	
	collected_money = 0
	money_requirement = 0
	walls.clear()
	
	add_child(current_level)
	focus_camera(current_level)
	
	SaveFile.add_level_to_dict(key)
	
	# Assign checkpoint ids and spawn the player on the correct one
	var checkpoints: Array[Node] = get_tree().get_nodes_in_group("checkpoints")
	
	for i: int in range(checkpoints.size()):
		checkpoints[i].id = i
		
		var current_cp: int = SaveFile.save_dictionary["levels"][key]["checkpoint_id"]
		
		if i == current_cp or (current_cp == -1 and checkpoints[i].is_start()):
			player.move_to(checkpoints[i].hitbox.get_center() * 1000 + Vector2(500, 500))
	
	# Add extra coins count
	collected_money += SaveFile.save_dictionary["levels"][key]["extra_coins"]
	assign_collectable_ids("coins")
	assign_collectable_ids("keys")
	assign_collectable_ids("paints")
	
	GameManager.collectables_processed = true
	
	for collectable: Collectable in get_tree().get_nodes_in_group("collectables"):
		if collectable.store_behavior == collectable.store_behaviors.STORE_STATE:
			var group: String = collectable.get_groups()[0]
			
			if group == "collectables": group = collectable.get_groups()[1]
			
			collectable.group_states = SaveFile.save_dictionary["levels"][GameManager.current_level][group]
			
			if collectable.group_states.size() == 0:
				push_warning("Collectable state array for group " + group + " is not created.")
				return
			
			if collectable.group_states[collectable.id] == 1:
				collectable.stay_collected()
	
	for gold_door: GoldDoor in get_tree().get_nodes_in_group("gold_doors"):
		if collected_money >= gold_door.money_requirement:
			gold_door.stay_triggered()


func assign_collectable_ids(group_name: String) -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(group_name)
	var states: Array = SaveFile.save_dictionary["levels"][GameManager.current_level][group_name]
	for i: int in range(nodes.size()):
		nodes[i].id = i
		
		# Extend the array until it has all coins' states
		while states.size() < nodes.size():
			states.append(0)
		
		match group_name:
			"coins":
				if states[i] == 1:
					World.collected_money += 1
			
			"keys":
				nodes[i].key_states = SaveFile.save_dictionary["levels"][GameManager.current_level]["keys"]
	

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
