extends Node

@export var coordinates: Vector2i
@export var bottom_text: String = ""

var player : Node = preload("res://core/game_objects/player.tscn").instantiate()
var interface : Node = preload("res://core/game_objects/interface.tscn").instantiate()

func _ready() -> void:
	var start_checkpoints: PackedStringArray = []
	
	for checkpoint: ColorRect in Collider.checkpoints:
		if checkpoint.is_start():
			player.last_checkpoint_id = checkpoint.id
			start_checkpoints.append(self.name + "/" + str(get_path_to(checkpoint)))
	
	add_child(player)
	
	if start_checkpoints.size() > 1:
		push_warning("More than one start checkpoint has been found, \
				choosing the latest one in the scene tree. Paths to all start type checkpoints: ", \
				start_checkpoints)
