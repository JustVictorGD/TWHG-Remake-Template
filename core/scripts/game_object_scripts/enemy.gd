extends Node2D
class_name Enemy

@export var lock_scale : bool = false

var hitbox: CircleCollider = CircleCollider.new(Vector2.ZERO, 7)
var id: int
@onready var original_opacity: float = modulate.a

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)

func movement_update() -> void:
	hitbox.position = self.global_position
	
	if lock_scale:
		global_scale = Vector2(1, 1)

func _process(_delta: float) -> void:
	if GameManager.invincible:
		modulate.a = original_opacity * 0.5
	else:
		modulate.a = original_opacity
