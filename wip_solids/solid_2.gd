@tool
extends ColorRect
class_name Solid2

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
@export_range(0, 65536) var outwards: int = 3
@export_range(0, 65536) var inwards: int = 3

var canvas_group: CanvasGroup = CanvasGroup.new()
var outline: ColorRect = ColorRect.new()
var fill: ColorRect = ColorRect.new()

var hitbox_index: int

func _ready() -> void:
	canvas_group.name = "CanvasGroup"
	outline.name = "Outline"
	fill.name = "Fill"
	
	for child: Node in get_children():
		child.queue_free()
	
	if merge_sprite and canvas_group not in get_children():
		add_child(canvas_group)
		canvas_group.add_child(outline)
		canvas_group.add_child(fill)
	
	if not merge_sprite and canvas_group in get_children():
		add_child(outline)
		add_child(fill)
		fill.z_index = 1
	
	self.z_index = 5
	#outline.z_index = -1
	color = Color.TRANSPARENT
	
	if not Engine.is_editor_hint():
		GameLoop.wall_update.connect(wall_update)
		
		if has_collision:
			hitbox_index = Collider.walls.size()
			Collider.walls.append(Rect2(NAN, NAN, NAN, NAN))
	
	child_ready()


func wall_update() -> void:
	
	
	#remove_child(canvas_group)
	
	#print(canvas_group.get_children(true))
	#print(outline, ", ", fill)
	#print()
	canvas_group.self_modulate.a = global_opacity
	
	outline.color = outline_color
	outline.position = Vector2(-outwards, -outwards)
	outline.size = self.size + Vector2(outwards * 2, outwards * 2)
	
	fill.color = fill_color
	fill.position = Vector2(inwards, inwards)
	fill.size = self.size - Vector2(inwards * 2, inwards * 2)
	
	if not Engine.is_editor_hint():
		Collider.walls[hitbox_index] = Rect2(outline.position + self.position, outline.size)


# Override these functions to add more behavior.
func child_ready() -> void:
	pass

func update_timers() -> void:
	pass

# Only happens in the Godot editor, not in game.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		wall_update()
		pass
		
		if merge_sprite and outline in self.get_children() and canvas_group not in get_children():
			print("HUH")
			remove_child(outline)
			remove_child(fill)
			add_child(canvas_group)
			canvas_group.add_child(outline)
			canvas_group.add_child(fill)
			fill.z_index = 0
		
		if not merge_sprite and outline not in self.get_children() and canvas_group in get_children():
			print("WAH")
			remove_child(canvas_group)
			canvas_group.remove_child(outline)
			canvas_group.remove_child(fill)
			self.add_child(outline)
			self.add_child(fill)
			fill.z_index = 1
