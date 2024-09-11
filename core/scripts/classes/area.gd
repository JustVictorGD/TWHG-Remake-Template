extends Node2D
class_name Area

@export var coordinates: Vector2i
@export var bottom_text: String = ""
@export var theme: AreaTheme
@export var area_size: Vector2i = Vector2(32, 20)

# Multi-area travel purposes.
@onready var bounding_box: Rect2 = Rect2(self.global_position, area_size * 48)
var player: Node = preload("res://core/game_objects/player.tscn").instantiate()

func _ready() -> void:
	GameManager.area_bounds.append(bounding_box)
	owner.change_area(self)
	
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
	
	#GameLoop.collision_update.connect(collision_update)



func collision_update() -> void:
	if player.position.x < 0:
		print("Travel left")
		get_tree().quit()
	
	elif player.position.x > area_size.x * 48:
		print("Travel right")
		get_tree().quit()
	
	elif player.position.y < 0:
		print("Travel up")
		get_tree().quit()
	
	elif player.position.y > area_size.y * 48:
		print("Travel down")
		get_tree().quit()
