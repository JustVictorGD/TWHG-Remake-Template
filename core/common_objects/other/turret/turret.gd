extends Node2D

## Time until the object gets destroyed in frames. 60 frames = 1 second. 
## Set this to -1 if you don't want the enemy destroyed.
@export var object_lifetime: int = 60
@export var object_speed: float = 1
@export var fire_on_load: bool = true
@export var fire_timer: TickBasedTimer

var object: PackedScene

func _ready() -> void:
	object = preload("res://core/common_objects/other/enemy/enemy.tscn")
	# Makes the cyan square invisible in-game
	$Sprite2D.modulate.a = 0
	
	if fire_timer != null:
		fire_timer.timeout.connect(fire_turret)
	
	if fire_on_load:
		call_deferred("fire_turret") # Avoids the "Parent is busy setting up children" error.

func fire_turret() -> void:
	var new_object: Node2D = object.instantiate()
	self.get_parent().add_child(new_object)
	new_object.position = position
	
	var velocity_component: VelocityComponent = VelocityComponent.new(Vector2.RIGHT.rotated(rotation) * object_speed)
	new_object.add_child(velocity_component)
	
	if object_lifetime != -1:
		var lifetime_timer: TickBasedTimer = TickBasedTimer.new(object_lifetime)
		lifetime_timer.timeout.connect(func() -> void: new_object.queue_free())
		lifetime_timer.reset_and_play()
		new_object.add_child(lifetime_timer)
	
	
