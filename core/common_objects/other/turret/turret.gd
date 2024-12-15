extends Node2D

## Time until the object gets destroyed in frames. 60 frames = 1 second. 
## Set this to -1 if you don't want the enemy destroyed.
@export var object_lifetime: int = 60
@export var shot_node: PackedScene
@export var velocity: Vector2 = Vector2.ZERO
@export var fire_on_load: bool = true
@export var fire_timer: TickBasedTimer
@export var fire_event_id: int

var scene: PackedScene = PackedScene.new()

func _ready() -> void:
	GlobalSignal.event.connect(on_event)
	# Makes the cyan square invisible in-game
	$Sprite2D.modulate.a = 0
	
	if fire_timer != null:
		fire_timer.timeout.connect(fire_turret)
	
	if fire_on_load:
		call_deferred("fire_turret") # Avoids the "Parent is busy setting up children" error.

func fire_turret() -> void:
	if shot_node == null:
		push_warning("No scene is chosen, turret won't work.")
		return
	var copy: Node = shot_node.instantiate()
	
		
	get_parent().add_child(copy)
	
	if owner is Area:
		copy.owner = self.owner
	
	if copy is Coin:
		copy.store_state = false
	
	if copy is Enemy:
		copy.update_colors()
	
	copy.position = position
	
	var vc: VelocityComponent = VelocityComponent.new(velocity.rotated(rotation))
	copy.add_child(vc)
	
	var tbt: TickBasedTimer = TickBasedTimer.new(object_lifetime, false, false, true)
	copy.add_child(tbt)
	
	await tbt.timeout
	
	copy.queue_free()
	
	

func on_event(id: int, state: bool) -> void:
	if id == fire_event_id and state == true:
		fire_turret()
