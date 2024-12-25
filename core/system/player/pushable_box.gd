extends Node2D
class_name PushableBox

const PLAYER_SIZE: Vector2i = Vector2i(42, 42)

enum subpixel {
	MIN = 0, # Going below makes it loop to MAX.
	DEFAULT = 500,
	MAX = 999, # Going above makes it loop to MIN.
	RANGE = 1000
}

# Physics and movement
var hitbox: Rect2i
var subpixels: Vector2i = Vector2i(subpixel.DEFAULT, subpixel.DEFAULT)


func get_nearby_walls() -> Array[Rect2i]:
	var nearby_walls: Array[Rect2i] = []
	
	var larger_check: Rect2i = Rect2i(
		hitbox.position - Vector2i(8, 8),
		hitbox.size + Vector2i(16, 16)
		)
	
	for wall: Rect2i in World.walls:
		if wall.intersects(larger_check):
			nearby_walls.append(wall)
	
	nearby_walls = WallTransformer.merge_walls(nearby_walls, hitbox)
	nearby_walls += WallTransformer.get_stretches(nearby_walls, hitbox)
	
	return nearby_walls


func push_out_of_walls(walls: Array[Rect2i]) -> Vector2i:
	return (Collider.updated_wall_push(hitbox, walls) - Vector2i(position)) * 1000

#region Corner Sliding

# This region is empty.

#endregion

# Floating point numbers cannot be trusted with precision,
# however keeping track of subpixel position is still needed.

#region Subpixels

func print_position() -> void:
	# Weird formatting explained at: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html#padding
	print("X = %s.%03d, Y = %s.%03d" % [position.x, subpixels.x, position.y, subpixels.y])


# Adds to the position using the subpixel system.
# This function uses subpixels. Multiply any input in pixels by 1000.
func move(movement: Vector2i) -> void:
	subpixels += movement
	
	while subpixels.x > subpixel.MAX:
		subpixels.x -= subpixel.RANGE
		position.x += 1
	while subpixels.x < subpixel.MIN:
		subpixels.x += subpixel.RANGE
		position.x -= 1
	while subpixels.y > subpixel.MAX:
		subpixels.y -= subpixel.RANGE
		position.y += 1
	while subpixels.y < subpixel.MIN:
		subpixels.y += subpixel.RANGE
		position.y -= 1
	
	position = round(position)
	hitbox.position = Vector2i(position) - PLAYER_SIZE / 2
	hitbox.size = PLAYER_SIZE

# Sets the position using the subpixel system.
# This function uses subpixels. Multiply any input in pixels by 1000.
func move_to(given_position: Vector2i) -> void:
	position = given_position / 1000
	
	subpixels.x = given_position.x % 1000
	subpixels.y = given_position.y % 1000
	
	while subpixels.x > subpixel.MAX:
		subpixels.x -= subpixel.RANGE
		position.x += 1
	while subpixels.x < subpixel.MIN:
		subpixels.x += subpixel.RANGE
		position.x -= 1
	while subpixels.y > subpixel.MAX:
		subpixels.y -= subpixel.RANGE
		position.y += 1
	while subpixels.y < subpixel.MIN:
		subpixels.y += subpixel.RANGE
		position.y -= 1
	
	position = round(position)
	
	hitbox.position = Vector2i(position) - PLAYER_SIZE / 2
	hitbox.size = PLAYER_SIZE

#endregion
