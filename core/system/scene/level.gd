extends Node2D
class_name Level


#region Properties


# 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

# Multi-area handling
var area_data: Array[Dictionary] = []
var packed_areas: Array[PackedScene] = []
var current_area: Area

# Trans-dimensional nodes
var player: Player = preload("res://core/special_objects/player/player.tscn").instantiate()
var interface: Control = preload("res://core/special_objects/interface/interface.tscn").instantiate()
var canvas_layer: CanvasLayer = CanvasLayer.new()
var camera: Camera2D = Camera2D.new()


var id_generation: Dictionary = {
	"enemies": 0,
	"coins": 0,
	"keys": 0,
	"checkpoints": 0,
}


#endregion


#region Functions


func _ready() -> void:
	add_child(camera)
	add_child(canvas_layer)
	canvas_layer.add_child(interface)
	camera.zoom = Vector2(0.25, 0.25)
	
	
	create_area_dictionaries()
	process_objects()
	process_checkpoints()
	
	
	add_child(player)
	GameLoop.collision_update.connect(collision_update)



func collision_update() -> void:
	for i: int in range(area_data.size()):
		if i != current_area.id:
			if Rect2(player.position, Vector2.ZERO).intersects(area_data[i]["node"]["bounding_box"]):
				change_area(i)



func change_area(area_id: int) -> void:
	print("area changed")
	
	for existing_area: Area in get_tree().get_nodes_in_group("areas"):
		existing_area.queue_free()
	
	for element: int in id_generation.values():
		element = 0
	
	Collider.walls.clear()
	
	var chosen_area: Area = packed_areas[area_id].instantiate()
	var area_info: Dictionary = area_data[area_id]["node"]
	
	chosen_area.global_position = area_info["position_offset"]
	current_area = chosen_area
	current_area.id = area_id
	
	add_child(chosen_area)
	
	camera.zoom.x = PLAYABLE_WINDOW.size.x / area_info["bounding_box"].size.x
	camera.zoom.y = camera.zoom.x
	camera.offset = area_info["bounding_box"].position + area_info["bounding_box"].size / 2
	
	interface.area.text = str("Level: 1-", area_info["displayed_coordinates"])
	
	process_objects()
	#process_checkpoints()


#endregion


#region Dictionary setup


func create_area_dictionaries() -> void:
	var areas: Array[Node] = get_tree().get_nodes_in_group("areas")
	var area_counter: int = 0
	
	for area: Area in areas:
		area.id = area_counter
		area_counter += 1
		
		packed_areas.append(load(area.scene_file_path))
		
		area_data.append(
			{
				"node": {
					"bounding_box": Rect2(area.global_position, area.area_size * 48),
					"file_path": area.scene_file_path,
					"position_offset": Vector2(area.global_position),
					"displayed_coordinates": area.displayed_coordinates
				},
				"collectable_states": {
					"coins": [],
					"keys": [],
				},
				"checkpoints": []
			}
		)
 


func set_area_data(area_id: int, object_type_plural: String, state: int) -> void:
	area_data[area_id]["collectable_states"][object_type_plural].append(state)



func process_objects() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.id = id_generation["enemies"]
		id_generation["enemies"] += 1
	
	for coin: Coin in get_tree().get_nodes_in_group("coins"):
		coin.id = id_generation["coins"]
		id_generation["coins"] += 1
		GameManager.max_money += 1
		set_area_data(coin.owner.id, "coins", coin.state)
	
	for key: Key in get_tree().get_nodes_in_group("keys"):
		key.id = id_generation["keys"]
		id_generation["keys"] += 1
		set_area_data(key.owner.id, "keys", key.state)
	
	for gold_door: GoldDoor in get_tree().get_nodes_in_group("gold_doors"):
		if gold_door.money_requirement <= 0:
			gold_door.money_requirement += GameManager.max_money



func process_checkpoints() -> void:
	var start_checkpoints: PackedStringArray = []
	
	for checkpoint: Checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		Collider.checkpoints.append(checkpoint)
		checkpoint.id = id_generation["checkpoints"]
		id_generation["checkpoints"] += 1
		
		if checkpoint.is_start():
			player.last_checkpoint_id = checkpoint.id
			start_checkpoints.append(self.name + "/" + str(get_path_to(checkpoint)))
			
			player.move_to(checkpoint.hitbox.get_center() * 1000 + Vector2(500, 500))
			change_area(checkpoint.owner.id)
	
	if start_checkpoints.size() > 1:
		push_warning("More than one start checkpoint has been found, \
				choosing the latest one in the scene tree. Paths to all start type checkpoints: ", \
				start_checkpoints)
	elif start_checkpoints.size() == 0:
		push_error("No start checkpoint has been found! Placing the player at (0, 0) and not focusing on any area.")


#endregion
