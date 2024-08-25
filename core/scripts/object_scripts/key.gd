extends Collectable

@export var key_id: int = -1
var radius: int = 13
var id: int # Not to be confused with the key_id,
# this one is only for collision and collectable saving

func _ready() -> void:
	collect_sound = "Key"
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	
	# This is how collision (and assigning keys to doors) works here.
	id = Collider.register_key_id(self)

func extra_collect() -> void:
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.trigger_door()

func extra_drop() -> void:
	for key_door: Door in get_tree().get_nodes_in_group("key_doors"):
		if key_door.key_id == key_id:
			key_door.untrigger_door()

func checkpoint_touched(_id: int) -> void:
	save()
