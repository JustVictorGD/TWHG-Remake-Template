extends Node
## Radius from the circle object, where the objects will be created.
@export var radius : float = 1
## Amount of objects, which the circle will create.
@export var object_count : int = 1
## Angle of the arc, in which the objects will be created. 360 degrees is a full circle.
@export var arc_degrees : float = 360
## Type of object, which the circle will create.
@export var object_type : obj = obj.ENEMIES
## If this is false, then there will be an object at the start and at the end of the arc. However, if arc_degrees = 360, then the start and end overlap and the object count looks like it's reduced by 1. Changing this to true will make the circle work like in Edit1 and Edit3.
@export var full_circle_mode : bool = true

var arc: float
var children: Array[Node]

enum obj {
	ENEMIES,
	COINS
}

func _ready() -> void:
	
	GameLoop.animation_update.connect(animation_update)
	
	# Makes the orange square invisible in-game
	$Sprite2D.modulate.a = 0
	
	# Loads the chosen object
	var object: PackedScene
	if object_type == obj.ENEMIES:
		object = preload("res://core/common_objects/other/enemy/enemy.tscn")
	elif object_type == obj.COINS:
		object = preload("res://core/common_objects/collectables/coin/coin.tscn")
	
	# Creates the objects
	for i: int in range(object_count):
		var new_object : Node2D = object.instantiate()
		add_child(new_object)
		children.append(new_object)

func animation_update() -> void:
	arc = deg_to_rad(arc_degrees)
	
	for i: int in range(children.size()):
		if children[i] is Node2D:
			if full_circle_mode:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / object_count))
			else:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / (object_count - 1)))
