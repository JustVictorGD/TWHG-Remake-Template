@icon("res://core/misc_assets/images/node_icons/circle.png")
extends Node
class_name Circle

## Radius from the circle object, where the objects will be created.
@export var radius : float = 1
## Amount of objects, which the circle will create.
@export var object_count : int = 1
## Angle of the arc, in which the objects will be created. 360 degrees is a full circle.
@export var arc_degrees : float = 360
## Type of object, which the circle will create. If empty, the circle will spawn enemies by default.
@export var node: PackedScene = load("res://core/common_objects/other/enemy/enemy.tscn")
## If this is false, then there will be an object at the start and at the end of the arc. However, if arc_degrees = 360, then the start and end overlap and the object count looks like it's reduced by 1. Changing this to true will make the circle work like in Edit1 and Edit3.
@export var full_circle_mode : bool = true

var arc: float
var children: Array[Node]

func _ready() -> void:
	
	GameLoop.animation_update.connect(animation_update)
	
	# Makes the orange square invisible in-game
	$Sprite2D.modulate.a = 0
	
	# Creates the objects
	for i: int in range(object_count):
		if node == null:
			push_warning("No scene is chosen, circle won't work.")
			return
		var copy: Node = node.instantiate()
		
		add_child(copy)
		children.append(copy)
		
		if owner is Area:
			copy.owner = self.owner
			
			if copy is Enemy:
				copy.update_colors()

func animation_update() -> void:
	arc = deg_to_rad(arc_degrees)
	
	for i: int in range(children.size()):
		if children[i] is Node2D:
			if full_circle_mode:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / object_count))
			else:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / (object_count - 1)))
