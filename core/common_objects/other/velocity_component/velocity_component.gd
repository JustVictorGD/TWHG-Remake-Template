class_name VelocityComponent
extends Node2D

@export var velocity: Vector2 = Vector2.ZERO
@export var enabled: bool = true
@onready var parent: Node = self.get_parent()

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)

func movement_update() -> void:
	if parent is Node2D and enabled:
		parent.position += velocity
	
