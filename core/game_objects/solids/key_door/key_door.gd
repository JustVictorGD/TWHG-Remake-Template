@icon("res://core/misc_assets/images/node_icons/key_door.png")
@tool
extends Door
class_name KeyDoor

signal initialized

## Collecting a key with the same ID will open the door.
@export var key_id: int = -1

var is_initialized: bool = false


func _ready() -> void:
	super()
	# The purpose of this code is the order of operations. A key
	# shouldn't be able to access the door before it initializes.
	is_initialized = true
	initialized.emit()
