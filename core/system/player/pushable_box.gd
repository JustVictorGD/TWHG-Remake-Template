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


func push_out_of_walls() -> void:
	var nearby_walls: Array[Rect2i] = []
	
	var larger_check: Rect2i = Rect2i(
		hitbox.position - Vector2i(8, 8),
		hitbox.size + Vector2i(16, 16)
		)
	
	for wall: Rect2i in World.walls:
		if wall.intersects(larger_check): nearby_walls.append(wall)
	
	nearby_walls = merge_walls(nearby_walls, hitbox)
	
	var wall_push: Vector2i = Collider.updated_wall_push(hitbox, nearby_walls) - Vector2i(position)
	
	move(wall_push * 1000)

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

# Everything below may be confusing for some (potentially most) readers.
# The purpose of these functions is to achieve more reliable wall physics
# through merging and stretching walls and performing corner sliding.

#region Wall Utilities

func is_point_above_vector(point: Vector2i, vector: Rect2i) -> bool:
	var result: bool = (point.x - vector.position.x) * vector.size.y - (point.y - vector.position.y) * vector.size.x > 0
	
	if vector.size.x > 0:
		return result
	
	return not result


func get_rect_separation(rect_a: Rect2i, rect_b: Rect2i) -> Vector2i:
	return Vector2i(
		max(rect_a.position.x - rect_b.end.x, rect_b.position.x - rect_a.end.x),
		max(rect_a.position.y - rect_b.end.y, rect_b.position.y - rect_a.end.y)
	)


func get_rect_corner(rect: Rect2i, coordinate_signs: Vector2i) -> Vector2i:
	return Vector2i(
		rect.position.x if coordinate_signs.x != 1 else rect.end.x,
		rect.position.y if coordinate_signs.y != 1 else rect.end.y
	)


func get_nearest_corner_signs(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		-1 if point.x <= rect_middle.x else 1,
		-1 if point.y <= rect_middle.y else 1
	)


func get_nearest_corner_position(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		rect.position.x if point.x < rect_middle.x else rect.end.x,
		rect.position.y if point.y < rect_middle.y else rect.end.y
	)

#endregion

#region Wall Transformations

func can_merge(a: Rect2i, b: Rect2i, player_pos: Vector2, leniency: Vector2) -> bool:
	if a.encloses(b) or b.encloses(a): return true
	
	var a_signs: Vector2i = get_nearest_corner_signs(player_pos, a)
	var b_signs: Vector2i = get_nearest_corner_signs(player_pos, b)
	
	if a_signs.x == b_signs.x and get_rect_separation(a, b).y <= leniency.y:
		if get_rect_corner(a, a_signs).x == get_rect_corner(b, b_signs).x:
			return true
	
	if a_signs.y == b_signs.y and get_rect_separation(a, b).x <= leniency.x:
		if get_rect_corner(a, a_signs).y == get_rect_corner(b, b_signs).y:
			return true
	
	return false


func merge_walls(walls: Array[Rect2i], player: Rect2i) -> Array[Rect2i]:
	var player_pos: Vector2 = player.position + player.size / 2
	var leniency: Vector2 = player.size - Vector2i.ONE
	
	var did_merge: bool = true
	
	while did_merge:
		did_merge = false
		var new_walls: Array[Rect2i] = []
		
		while walls.size() > 0:
			var current: Rect2i = walls.pop_front()
			var merged: bool = false
			
			for i: int in range(new_walls.size()):
				if can_merge(current, new_walls[i], player_pos, leniency):
					new_walls[i] = new_walls[i].merge(current)
					merged = true
					did_merge = true
					break
			
			if not merged:
				new_walls.append(current)
		
		walls = new_walls
	
	return walls





#endregion

#region Corner Sliding

# This region is empty.

#endregion
