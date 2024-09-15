extends Node2D
class_name Level

# On a 1280x720 pixel viewport.
const PLAYABLE_WINDOW: Rect2 = Rect2(160, 60, 960, 600)

var player: Node2D = preload("res://core/game_objects/player.tscn").instantiate()
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
			change_area(checkpoint.owner)
	
	
	if start_checkpoints.size() > 1:
		push_warning("More than one start checkpoint has been found, \
				choosing the latest one in the scene tree. Paths to all start type checkpoints: ", \
				start_checkpoints)
	elif start_checkpoints.size() == 0:
		push_error("No start checkpoint has been found! Placing the player at (0, 0) and not focusing on any area.")
	
	
	add_child(player)

func change_area(area: Area) -> void:
	camera.zoom.x = PLAYABLE_WINDOW.size.x / (area.area_size.x * 48)
	camera.zoom.y = camera.zoom.x
	
	camera.offset = area.bounding_box.position + area.bounding_box.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
