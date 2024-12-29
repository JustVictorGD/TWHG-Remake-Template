@tool
@icon("res://core/misc_assets/images/node_icons/circle.png")
extends Node2D
class_name Circle

## Radius from the circle object, where the objects will be created.
@export var radius : float = 1
## Amount of objects, which the circle will create.
@export var object_count : int = 1
## Angle of the arc, in which the objects will be created. 360 degrees is a full circle.
@export var arc_degrees : float = 360
## Type of object, which the circle will create. If empty, the circle will spawn enemies by default.
@export var node: PackedScene = load("res://core/game_objects/other/enemy/enemy.tscn")
@export var properties: Resource
## If this is false, then there will be an object at the start and at the end of the arc. However, if arc_degrees = 360, then the start and end overlap and the object count looks like it's reduced by 1. Changing this to true will make the circle work like in Edit1 and Edit3.
@export var full_circle_mode : bool = true

var arc: float:
	get:
		return deg_to_rad(arc_degrees)

var children: Array[Node]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
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
			if properties != null and properties is EnemyProperties:
				copy.set_properties(properties)
			
			copy._ready()

func animation_update() -> void:
	for i: int in range(children.size()):
		if children[i] is Node2D:
			if full_circle_mode:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / object_count))
			else:
				children[i].position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / (object_count - 1)))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	for i: int in range(object_count):
		var object_position: Vector2
		if full_circle_mode:
			object_position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / object_count))
		else:
			object_position = Vector2(48 * radius, 0).rotated(lerp(0.0, arc, float(i) / (object_count - 1)))
		
		draw_circle(object_position, 12, Color(Color.BLACK, 0.5), false, 2, true)
		draw_line(Vector2.ZERO, object_position, Color(Color.BLACK, 0.5), 2, true)
