extends Node2D

## Time until the object gets destroyed in frames. 60 frames = 1 second. 
## Set this to -1 if you don't want the enemy destroyed.
@export var object_lifetime: int = 60
@export var object_speed: float = 1
@export var fire_delay: int = 60 # Temporary, gonna refactor soon

var object: PackedScene
@onready var timer: TickBasedTimer = $FireTimer

func _ready() -> void:
	object = preload("res://core/common_objects/other/enemy/enemy.tscn")
	
	timer.duration = fire_delay # Temporary, gonna refactor soon
	
	# Makes the cyan square invisible in-game
	$Sprite2D.modulate.a = 0
	
	timer.timeout.connect(fire_turret)
	timer.reset_and_play()
	#fire_turret() # Fires the turret immediately when loaded
	

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
	
	
