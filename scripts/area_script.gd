extends Node

@export var coordinates: Vector2i
@export var bottom_text: String = ""

var player : Node = preload("res://scenes/player.tscn").instantiate()
var interface : Node = preload("res://scenes/interface.tscn").instantiate()

func _ready() -> void:
	# Setting up the camera and the GUI
	add_child(interface)
	$Gameplay.scale.x = Collider.GAMEPLAY_SCALE
	$Gameplay.scale.y = Collider.GAMEPLAY_SCALE
	$Gameplay.position.x += Collider.GAMEPLAY_POSITION.x
	$Gameplay.position.y += Collider.GAMEPLAY_POSITION.y
