extends ColorRect
class_name Solid

@export var outline_size: int = 6
@export var outline_color: Color = Color(0, 0, 0, 1)
@export var can_collide: bool = true

var hitbox_index: int
var outline: ColorRect

func _ready() -> void:
	GameLoop.animation_update.connect(animation_update)
	GameLoop.update_timers.connect(update_timers)
	
	# Scales and positions the wall, so full tiles in editor work the same as in the TileMap grid
	# WARNING: Please use a parent node to animate wall objects, because the AnimationPlayer overrides these changes.
	size -= Vector2(6, 6)
	position += Vector2(3, 3)
	
	# Creates the outline
	outline = ColorRect.new()
	add_child(outline)
	outline.color = outline_color
	outline.z_index = -1
	outline.position = -Vector2(self.outline_size, self.outline_size)
	outline.size = Vector2(size.x + 2 * self.outline_size, size.y + 2 * self.outline_size)
	
	# Creates hitbox
	if can_collide:
		hitbox_index = Collider.walls.size()
		Collider.walls.append(Rect2(position - Vector2(outline_size, outline_size), self.size + 2 * Vector2(outline_size, outline_size)))
	
	child_ready()

func animation_update() -> void:
	# Update outline
	outline.size = Vector2(size.x + 2 * self.outline_size, size.y + 2 * self.outline_size)
	# Update hitbox
	if can_collide:
		Collider.walls[hitbox_index] = Rect2(position - Vector2(outline_size, outline_size), self.size + 2 * Vector2(outline_size, outline_size))
	else:
		Collider.walls[hitbox_index] = Rect2(Vector2.ZERO, Vector2.ZERO)

# Override these functions to add more behavior.
func child_ready() -> void:
	pass

func update_timers() -> void:
	pass
