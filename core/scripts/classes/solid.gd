@tool
extends ColorRect
class_name Solid

## Print certain debug information if there is any.
@export var tracking: bool = false

## Allows global_opacity to be used to make the solid semi-transparent without
## the opacities of the 2 layers stacking, but forces them to be on a single
## Z-index, preventing them from nicely being merged with other solids.
@export var merge_sprite: bool = false

## Only works if merge_sprite is true. Reduces the solid's opacity as if it was a single sprite.
@export_range(0, 1) var global_opacity: float = 1
@export var outline_color: Color = Color.BLACK
@export var fill_color: Color = Color.WHITE
@export var has_collision: bool = true

@export_category("Outline width")
@export_range(0, 65536) var outwards_width: int = 3
@export_range(0, 65536) var inwards_width: int = 3
var total_outline_width: int = outwards_width + inwards_width

# Components of the solid
var canvas_group: CanvasGroup = CanvasGroup.new()
var outline: ColorRect = ColorRect.new()
var fill: ColorRect = ColorRect.new()

# If false, doesn't call the set_sprite_size() function for better performance.
var dynamic_size: bool = false

# Misc
var sprite_is_merged: bool = false
var hitbox_index: int
@onready var original_opacity: float = canvas_group.modulate.a


func _ready() -> void:
	canvas_group.name = "CanvasGroup"
	outline.name = "Outline"
	fill.name = "Fill"
	
	color = Color.TRANSPARENT
	
	for child: Node in get_children():
		child.queue_free()
	
	sprite_is_merged = not merge_sprite
	set_merge_sprite(merge_sprite)
	set_sprite_size(Rect2(Vector2.ZERO, size))
	
	if not Engine.is_editor_hint():
		GameLoop.wall_update.connect(wall_update)
		
		if has_collision:
			hitbox_index = Collider.walls.size()
			Collider.walls.append(Rect2(NAN, NAN, NAN, NAN))
	
	child_ready()


func wall_update() -> void:
	total_outline_width = outwards_width + inwards_width
	canvas_group.self_modulate.a = global_opacity
	outline.color = outline_color
	fill.color = fill_color
	
	if dynamic_size or Engine.is_editor_hint():
		set_sprite_size(Rect2(Vector2.ZERO, size))
	
	if not Engine.is_editor_hint() and has_collision:
	# Only play in game, not in editor.
		if merge_sprite:
			canvas_group.self_modulate.a = global_opacity
		else:
			fill.self_modulate.a = global_opacity
			outline.self_modulate.a = global_opacity
			
		if has_collision and GameManager.ghost:
			if merge_sprite:
				canvas_group.self_modulate.a = global_opacity * 0.5
			else:
				fill.self_modulate.a = global_opacity * 0.5
				outline.self_modulate.a = global_opacity * 0.5
		
		
		Collider.walls[hitbox_index] = Rect2(outline.position + self.position, outline.size)


func set_sprite_size(sprite: Rect2) -> void:
	outline.position = sprite.position - Vector2(outwards_width, outwards_width)
	outline.size = sprite.size + Vector2(outwards_width, outwards_width) * 2
	fill.position = outline.position + Vector2(total_outline_width, total_outline_width)
	fill.size = outline.size - Vector2(total_outline_width, total_outline_width) * 2

func set_outline_size(sprite: Rect2) -> void:
	outline.position = sprite.position
	outline.size = sprite.size
	fill.position = outline.position + Vector2(total_outline_width, total_outline_width)
	fill.size = outline.size - Vector2(total_outline_width, total_outline_width) * 2


# Override this function to add more behavior.
func child_ready() -> void:
	pass


func set_merge_sprite(suggest_merge: bool) -> void:
	# Turning on
	if suggest_merge and not sprite_is_merged and canvas_group not in get_children():
		
		if outline in get_children():
			self.remove_child(outline)
			self.remove_child(fill)
		
		self.add_child(canvas_group)
		canvas_group.add_child(outline)
		canvas_group.add_child(fill)
		fill.z_index = 0
		sprite_is_merged = true
	
	# Turning off
	if not suggest_merge and sprite_is_merged:
		
		if canvas_group in get_children():
			self.remove_child(canvas_group)
			canvas_group.remove_child(outline)
			canvas_group.remove_child(fill)
		
		self.add_child(outline)
		self.add_child(fill)
		fill.z_index = 1
		sprite_is_merged = false

func _process(delta: float) -> void:
# Only happens in the Godot editor, not in game.
	if Engine.is_editor_hint():
		wall_update()
		set_merge_sprite(merge_sprite)
		
		# Prevents a weird bug that stops you from resizing the solid by dragging it.
		if has_meta("_edit_use_anchors_"):
			set_meta("_edit_use_anchors_", false)
