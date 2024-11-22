extends Collectable
class_name Key

@export var key_id: int = -1

var hitbox: CircleCollider = CircleCollider.new(Vector2.ZERO, 21)
var id: int # Not to be confused with the key_id,
# this one is only for collision and collectable saving


func _ready() -> void:
	collect_sound = "Key"
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)


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


func movement_update() -> void:
	hitbox.position = self.global_position
