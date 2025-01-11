class_name VelocityComponent
extends Node

@export var velocity: Vector2 = Vector2.ZERO # Движение или скорост
# Вектор2 е вектор с X и Y координати
@export var acceleration: Vector2 = Vector2.ZERO
@export var angular_velocity: float = 0
@export var angular_acceleration: float = 0
@export var enabled: bool = true
@onready var parent: Node = self.get_parent()

func _init(_velocity: Vector2 = velocity) -> void:
	GameLoop.movement_update.connect(movement_update)
	velocity = _velocity

func movement_update() -> void:
	velocity += acceleration
	angular_velocity += angular_acceleration
	if parent is Node2D and enabled:
		parent.position += velocity
		parent.rotation_degrees += angular_velocity
