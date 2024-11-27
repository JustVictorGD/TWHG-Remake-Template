class_name VelocityComponent
extends Node2D

@export var velocity: Vector2 = Vector2.ZERO
@onready var parent: Node = self.get_parent()

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)

func movement_update() -> void:
	if parent is Node2D:
		parent.position += velocity
	
