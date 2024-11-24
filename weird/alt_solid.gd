@tool
extends Control
class_name AltSolid

const PIXEL: PackedScene = preload("res://core/common_objects/solids/pixel.tscn")

## Only recommended to turn on when using themes that gradually change color.
@export var dynamic_color: bool = false
## Turning this on will prevent the solid from existing collision wise at all.
@export var decorative: bool = false
## Expands outline outwards.
@export var outwards_width: float = 3
## Expands outline inwards.
@export var inwards_width: float = 3
@export var outline_color: Color = Color(0.282, 0.282, 0.4)
@export var fill_color: Color = Color(0.7, 0.7, 1)
## Negative values will allow solids to visually merge with each other.
@export var outline_z_offset: int = -1

@onready var in_editor: bool = Engine.is_editor_hint()

var fill: Sprite2D = PIXEL.instantiate()
var outline: Node2D = Node2D.new()
var top: Sprite2D = PIXEL.instantiate()
var left: Sprite2D = PIXEL.instantiate()
var bottom: Sprite2D = PIXEL.instantiate()
var right: Sprite2D = PIXEL.instantiate()

var outwards_2d: Vector2:
	get:
		return Vector2(outwards_width, outwards_width)

var outer_bound: Rect2:
	get:
		return Rect2(-outwards_2d, size + outwards_2d * 2)

var global_bound: Rect2:
	get:
		return Rect2(-outwards_2d + position, size + outwards_2d * 2)

var total_width: float:
	get:
		return outwards_width + inwards_width

var hitbox_index: int


func _ready() -> void:
	for child: Node in get_children():
		# Spare anything extending Control if text needs to be included.
		if child is Node2D:
			child.queue_free()
	
	add_child(fill)
	add_child(outline)
	
	var segments: Array[Sprite2D] = [top, left, bottom, right]
	
	for segment: Sprite2D in segments:
		outline.add_child(segment)
	
	outline.modulate = outline_color
	fill.modulate = fill_color
	outline.z_index = outline_z_offset
	
	change_shape(outer_bound)
	
	if not decorative and not in_editor:
		hitbox_index = World.walls.size()
		World.walls.append(global_bound)


func change_shape(rect: Rect2) -> void:
	rect.size.x = clamp(rect.size.x, 0, INF)
	rect.size.y = clamp(rect.size.y, 0, INF)
	
	var inwards_2d: Vector2 = Vector2(inwards_width, inwards_width) * 2
	
	var inner: Rect2 = Rect2(
		rect.position + inwards_2d,
		rect.size - inwards_2d * 2
	)
	
	if inner.size.x <= 0:
		inner.size.x = 0
		if inner.end.x > rect.end.x:
			inner.position.x = rect.end.x
	
	if inner.size.y <= 0:
		inner.size.y = 0
		if inner.end.y > rect.end.y:
			inner.position.y = rect.end.y
	
	transform_pixel(fill, inner)
	# I don't see a convenient pattern so I have to do things manually like this.
	transform_pixel(top, sides_to_rect(rect.position.y, inner.position.x, inner.position.y, rect.end.x))
	transform_pixel(left, sides_to_rect(rect.position.y, rect.position.x, inner.end.y, inner.position.x))
	transform_pixel(bottom, sides_to_rect(inner.end.y, rect.position.x, rect.end.y, inner.end.x))
	transform_pixel(right, sides_to_rect(inner.position.y, inner.end.x, rect.end.y, rect.end.x))


# A Rect2 can't really be turned off but it can be moved billions of pixels away.
func nullify_hitbox() -> void:
	if not decorative:
		World.walls[hitbox_index] = Rect2(-4294967296, -4294967296, 0, 0)


func _process(_delta: float) -> void:
	if dynamic_color or in_editor:
		outline.modulate = outline_color
		fill.modulate = fill_color
	
	if in_editor:
		outline.z_index = outline_z_offset
		change_shape(outer_bound)


func transform_pixel(pixel: Sprite2D, rect: Rect2) -> void:
	pixel.position = (rect.position + rect.end) / 2
	pixel.scale = rect.size


@warning_ignore("shadowed_variable")
func sides_to_rect(top: float, left: float, bottom: float, right: float) -> Rect2:
	return Rect2(left, top, right - left, bottom - top)
