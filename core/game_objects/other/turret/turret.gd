extends Node2D

## Time until the object gets destroyed in frames. 60 frames = 1 second. 
## Set this to -1 if you don't want the enemy destroyed.
@export var object_lifetime: int = 60
@export var shot_node: PackedScene
@export var properties: Resource
@export var velocity: Vector2 = Vector2.ZERO
## The group which gets added to the shot object when it gets created.
@export var group: String = ""
@export var fire_on_load: bool = true
@export var fire_timer: TickBasedTimer
@export var fire_event_id: int

var scene: PackedScene = PackedScene.new()
var last_copy: Node

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
	last_copy = shot_node.instantiate()
	
		
	#get_parent().add_child(last_copy)
	
	if owner is Area:
		owner.add_child(last_copy)
		last_copy.owner = self.owner
	
	if last_copy is Coin:
		last_copy.store_behavior = last_copy.store_behaviors.INCREMENT_TOTAL
	
	if last_copy is Enemy:
		if properties != null and properties is EnemyProperties:
			last_copy.set_properties(properties)
	
	if last_copy is GameObject2D:
		last_copy._ready()
	
	if group != "":
		last_copy.add_to_group(group)
	
	last_copy.position = position
	
	var vc: VelocityComponent = VelocityComponent.new(velocity.rotated(rotation))
	last_copy.add_child(vc)
	
	var tbt: TickBasedTimer = TickBasedTimer.new(object_lifetime, false, false, true)
	last_copy.add_child(tbt)
	
	await tbt.timeout
	
	last_copy.queue_free()
	
	

func on_event(id: int, state: bool) -> void:
	if id == fire_event_id and state == true:
		fire_turret()
