@tool
extends ColorRect
class_name Solid2

@export var tracking: bool = false

@export var outline_color: Color = Color.BLACK
@export var fill_color: Color = Color.WHITE
@export var has_collision: bool = false

@export_category("Outline width")
@export_range(0, 65536) var outwards: int = 3
@export_range(0, 65536) var inwards: int = 3

var outline: ColorRect = ColorRect.new()
var fill: ColorRect = ColorRect.new()
var hitbox_index: int

func _ready() -> void:
	if Engine.is_editor_hint():
		for child: Node in get_children():
			child.queue_free()
	
	add_child(outline)
	add_child(fill)
	
	self.z_index = 5
	outline.z_index = -1
	color = Color.TRANSPARENT
	
	if not Engine.is_editor_hint():
		GameLoop.wall_update.connect(wall_update)
		
		if has_collision:
			hitbox_index = Collider.walls.size()
			Collider.walls.append(Rect2(NAN, NAN, NAN, NAN))


func wall_update() -> void:
	outline.color = outline_color
	outline.position = Vector2(-outwards, -outwards)
	outline.size = self.size + Vector2(outwards * 2, outwards * 2)
	
	fill.color = fill_color
	fill.position = Vector2(inwards, inwards)
	fill.size = self.size - Vector2(inwards * 2, inwards * 2)
	
	self.pivot_offset = self.size / 2
	
	if not Engine.is_editor_hint():
		Collider.walls[hitbox_index] = Rect2(outline.position + self.position, outline.size)


# Only happens in the Godot editor, not in game.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		wall_update()
		
		if tracking:
			print(get_children())
			print()
