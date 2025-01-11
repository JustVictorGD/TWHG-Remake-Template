extends Node2D

@export var object_count: int
@export var object: PackedScene
@export var properties: Resource
@export var speed: float = 5

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rotation = rng.randf_range(0, 2*PI)
	create_objects.call_deferred()
	
func create_objects() -> void:
	for i: int in object_count:
		var copy: Node = object.instantiate()
		add_sibling(copy)
		copy.position = position
		
		var vc: VelocityComponent = VelocityComponent.new()
		copy.add_child(vc)
		
		copy.owner = owner
		#if copy is Enemy:
			#if properties != null and properties is EnemyProperties:
				#copy.set_properties(properties)
		
		copy._ready()
		
		vc.velocity = Vector2(speed, 0).rotated(rotation + (float(i) / object_count) * 2*PI)
		print(i)
