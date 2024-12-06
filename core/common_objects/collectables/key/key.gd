@icon("res://core/misc_assets/images/node_icons/key.png")
extends Collectable
class_name Key

@export var key_id: int = -1

@onready var hitbox: CircleCollider = $CircleCollider
var id: int # Not to be confused with the key_id,
# this one is only for collision and collectable saving


func _ready() -> void:
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
	hitbox.global_position = self.global_position
	hitbox.radius = self.global_scale.x * 21 # 21 units is the default scale of the key.
	# This assumes that enemy scale.x and scale.y are equal as oval hitboxes are not implemented.
