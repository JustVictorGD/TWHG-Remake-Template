extends Node2D
class_name Level

# On a 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

var frozen_areas: Array[Area] = []
var areas: Array[Area] = []

var player: Player = preload("res://core/game_objects/player.tscn").instantiate()
var interface: Control = preload("res://core/game_objects/interface.tscn").instantiate()
var canvas_layer: CanvasLayer = CanvasLayer.new()
var camera: Camera2D = Camera2D.new()

var current_area: Area


var id_generation: Dictionary = {
	"enemies": 0,
	"coins": 0,
	"keys": 0,
	"checkpoints": 0,
}


func _ready() -> void:
	add_child(camera)
	add_child(canvas_layer)
	canvas_layer.add_child(interface)
	camera.zoom = Vector2(0.625, 0.625)
	
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.id = id_generation["enemies"]
		id_generation["enemies"] += 1
	
	for coin: Coin in get_tree().get_nodes_in_group("coins"):
		coin.id = id_generation["coins"]
		id_generation["coins"] += 1
		GameManager.max_money += 1
	
	for key: Key in get_tree().get_nodes_in_group("key"):
		key.id = id_generation["key"]
		id_generation["key"] += 1
	
	for gold_door: Door in get_tree().get_nodes_in_group("gold_doors"):
		if gold_door.money_requirement <= 0:
			gold_door.money_requirement += GameManager.max_money
	
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
	
	add_child(player)
	GameLoop.collision_update.connect(collision_update)

 

func change_area(area_id: int) -> void:
	for existing_area: Area in get_tree().get_nodes_in_group("areas"):
		existing_area.queue_free()
	
	var chosen_area: Area = frozen_areas[area_id].duplicate()
	
	chosen_area.name = frozen_areas[area_id].name
	
	add_child(chosen_area)
	
	current_area = chosen_area
	current_area.id = area_id
	
	#camera.zoom.x = PLAYABLE_WINDOW.size.x / (chosen_area.area_size.x * 48)
	#camera.zoom.y = camera.zoom.x
	#camera.offset = chosen_area.boundary.position + chosen_area.boundary.size / 2
	
	interface.area.text = str("Level: 1-", chosen_area.displayed_coordinates)
	
	print("Change area")
	print(camera.zoom)
	print(camera.offset)
	
	print(get_children())



func collision_update() -> void:
	for area: Area in frozen_areas:
		if area.id != current_area.id:
			if Rect2(player.position, Vector2.ZERO).intersects(area.boundary):
				change_area(area.id)
