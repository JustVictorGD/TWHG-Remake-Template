@icon("res://core/misc_assets/images/node_icons/key.png")
extends Collectable
class_name Key

@export var key_id: int = -1

#var id: int # Not to be confused with the key_id,
# this one is only for collision and collectable saving

var key_states: Array

func _ready() -> void:
	super()
	
	hitbox = $CircleCollider
	await GlobalSignal.collectables_processed
	key_states = SaveFile.save_dictionary["levels"][GameManager.current_level]["keys"]
	

func stay_collected() -> void:
	super()
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.stay_triggered()
	

func collect() -> void:
	# Call the collect() function of the Collectable class.
	super()
	
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.trigger_door()


func drop() -> void:
	super()
	
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.untrigger_door()

func save() -> void:
	super()
	
	

func movement_update() -> void:
	hitbox.global_position = self.global_position
	hitbox.radius = self.global_scale.x * 21 # 21 units is the default scale of the key.
	# This assumes that enemy scale.x and scale.y are equal as oval hitboxes are not implemented.
