extends Node2D

## The room which the teleporter teleports the player to. 
## Must be written as a key defined in connections.json. 
## If empty, the teleporter doesn't change the player's room.
@export var destination_room: String
## The coordinates, which the player gets teleported to.
@export var destination_position: Vector2
## Whether or not the destination position is relative to the teleporter.
## Doesn't work if the teleporter goes to a different room.
@export var is_relative: bool = true
## Controls in what axes the player gets teleported. Useful for mechanics like screen wrapping.
#@export var teleporter_setting: teleporter_settings = teleporter_settings.TELEPORT_X_AND_Y

@onready var collider: RectangleCollider = $RectangleCollider
@onready var sprite: Sprite2D = $Sprite2D

#enum teleporter_settings {
	#TELEPORT_X_AND_Y,
	#TELEPORT_X,
	#TELEPORT_Y
#}

func _ready() -> void:
	collider.collision_entered.connect(on_collision_enter)
	sprite.visible = false
	

func _process(delta: float) -> void:
	collider.scale = 48 * scale

func on_collision_enter(node: Node) -> void:
	if node is not Player:
		return
	
	#var final_position: Vector2i
	
	#if teleporter_setting == teleporter_settings.TELEPORT_X_AND_Y:
		#final_position = destination_position
	#elif teleporter_setting == teleporter_settings.TELEPORT_X:
		#final_position = Vector2(destination_position.x, node.position.y)
	#elif teleporter_setting == teleporter_settings.TELEPORT_Y:
		#final_position = Vector2(node.position.x, destination_position.y)

	if destination_room != "":
		GlobalSignal.switch_level.emit(destination_room, destination_position)
	elif is_relative:
		node.move(destination_position * 1000)
	else:
		node.move_to(destination_position * 1000)
