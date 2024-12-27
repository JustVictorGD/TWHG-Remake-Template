@tool
extends Node2D
## The event which the trigger triggers.
@export var event_id: int
## If true, the trigger automatically deactivates when the colliding objects exit it. 
## (Currently doesn't work with multiple objects)
@export var button_mode: bool = false
## Whether or not the trigger activates if it has already been activated.
@export var deactivated_color: Color = Color(Color.HOT_PINK, 1)
@export var activated_color: Color = Color(Color.HOT_PINK, 0.25)
@export var collider: RectangleCollider

var is_activated: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint() and collider != null:
		collider.collision_entered.connect(on_collision_enter)
		collider.all_collisions_exited.connect(on_all_collisions_exited)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): # Runs only in editor
		modulate = deactivated_color


func on_collision_enter(node: Node) -> void:
	modulate = activated_color
	GlobalSignal.event.emit(event_id, true)

func on_all_collisions_exited() -> void:
	if button_mode:
		modulate = deactivated_color
		GlobalSignal.event.emit(event_id, false)
