extends Node2D

@export var lock_scale : bool = true

var hitbox: CircleCollider = CircleCollider.new(Vector2.ZERO, 7)
var id: int
# For cases when opacity is changed externally, like from invincibility
@onready var original_opacity: float = modulate.a

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)
	# This is how collision works here!
	id = Collider.register_enemy_id(self)

func movement_update() -> void:
	hitbox.position = self.global_position
	
	if lock_scale:
		global_scale = Vector2(1, 1)

func _process(_delta: float) -> void:
	if AreaManager.invincible:
		modulate.a = original_opacity * 0.5
	else:
		modulate.a = original_opacity
