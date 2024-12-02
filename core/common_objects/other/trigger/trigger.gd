extends Node2D
## The event which the trigger triggers.
@export var event_id: int
## Whether or not the trigger activates if it has already been activated.
@export var multi_activate: bool = false
@onready var collider: RectangleCollider = $RectangleCollider

var is_activated: bool = false

func _ready() -> void:
	collider.collided.connect(collided)

func collided(node: Node) -> void:
	if multi_activate:
		GlobalSignal.event.emit(event_id)
		return
	
	if not is_activated:
		GlobalSignal.event.emit(event_id)
		is_activated = true
