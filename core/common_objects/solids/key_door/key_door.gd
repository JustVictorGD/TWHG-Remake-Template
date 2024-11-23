@icon("res://core/misc_assets/images/node_icons/key_door.png")
@tool
extends Door

## Collecting a key with the same ID will open the door.
@export var key_id: int = -1
