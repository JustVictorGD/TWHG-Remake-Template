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


func push_out_of_walls() -> Vector2i:
	var nearby_walls: Array[Rect2i] = []
	
	var larger_check: Rect2i = Rect2i(
		hitbox.position - Vector2i(8, 8),
		hitbox.size + Vector2i(16, 16)
		)
	
	for wall: Rect2i in World.walls:
		if wall.intersects(larger_check): nearby_walls.append(wall)
	
	nearby_walls = merge_walls(nearby_walls, hitbox)
	var first_push: Vector2i = Collider.updated_wall_push(hitbox, nearby_walls) - Vector2i(position)
	
	move(first_push * 1000)
	
	nearby_walls = stretch_walls(nearby_walls, hitbox)
	var second_push: Vector2i = Collider.updated_wall_push(hitbox, nearby_walls) - Vector2i(position)
	
	move(first_push * -1000)
	
	return (first_push + second_push) * 1000

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

#region Corner Sliding

# This region is empty.

#endregion

# Everything below is INSANELY convoluted. Not recommended to mess
# around with. The purpose of these functions is to achieve more
# reliable wall physics through merging and stretching walls.

#region Wall Utilities

func get_distance(a: Rect2i, b: Rect2i) -> Vector2i:
	return Vector2i(
		max(a.position.x - b.end.x, b.position.x - a.end.x),
		max(a.position.y - b.end.y, b.position.y - a.end.y)
	)


func point_above_vector(point: Vector2i, vector: Rect2i) -> bool:
	var result: bool = (point.x - vector.position.x) * vector.size.y - (point.y - vector.position.y) * vector.size.x > 0
	
	if vector.size.x > 0:
		return result
	
	return not result


func get_rect_corner_signs(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		-1 if point.x <= rect_middle.x else 1,
		-1 if point.y <= rect_middle.y else 1
	)


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


func two_stretches_towards_signs(signs: Vector2i) -> Array[Rect2i]:
	@warning_ignore("shadowed_variable")
	var stretch: Rect2i = Rect2i()
	
	if signs.x == -1:
		stretch.size.x = 1
	else:
		stretch.position.x = 1
	
	if signs.y == -1:
		stretch.size.y = 1
	else:
		stretch.position.y = 1
	
	return [stretch, stretch]


func stretch(rect: Rect2i, direction: Vector2i) -> Rect2i:
	const STRETCH: int = 65536
	
	match direction:
		Vector2i.LEFT:
			rect.position.x -= STRETCH
			rect.size.x += STRETCH
		Vector2i.UP:
			rect.position.y -= STRETCH
			rect.size.y += STRETCH
		Vector2i.RIGHT:
			rect.size.x += STRETCH
		Vector2i.DOWN:
			rect.size.y += STRETCH
		_:
			push_error("Invalid direction.")
	
	return rect


#endregion

#region Wall Merging

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

#region Wall Stretching

func stretch_walls(walls: Array[Rect2i], player: Rect2i) -> Array[Rect2i]:
	var transformations: Array[Rect2i] = []
	
	for i: int in range(walls.size()):
		transformations.append(Rect2i())
	
	for i: int in range(walls.size() - 1):
		for j: int in range(i + 1, walls.size()):
			var potential_stretches: Array[Rect2i] = get_stretch(
				walls[i], walls[j], player
			)
			transformations[i].position += potential_stretches[0].position
			transformations[i].size += potential_stretches[0].size
			
			transformations[j].position += potential_stretches[1].position
			transformations[j].size += potential_stretches[1].size
	
	for i: int in range(transformations.size()):
		var transformation: Rect2i = transformations[i]
		
		if transformation.position.x != 0:
			walls[i] = stretch(walls[i], Vector2i.LEFT)
		if transformation.position.y != 0:
			walls[i] = stretch(walls[i], Vector2i.UP)
		if transformation.size.x != 0:
			walls[i] = stretch(walls[i], Vector2i.RIGHT)
		if transformation.size.y != 0:
			walls[i] = stretch(walls[i], Vector2i.DOWN)
	
	return walls



func get_stretch(a: Rect2i, b: Rect2i, player: Rect2i) -> Array[Rect2i]:
	var distance: Vector2i = get_distance(a, b)
	
	# Abort if the gap is large enough for the player to go through.
	if distance.x >= player.size.x or distance.y >= player.size.y:
		return [Rect2i(), Rect2i()]
	
	var player_pos: Vector2 = Vector2(player.position) + player.size * 0.5
	var a_signs: Vector2i = get_rect_corner_signs(player_pos, a)
	var b_signs: Vector2i = get_rect_corner_signs(player_pos, b)
	
	# Case A: Identical signs.
	if a_signs == b_signs:
		return two_stretches_towards_signs(a_signs)
	
	# Case B: Signs match on one axis.
	elif (a_signs.x == b_signs.x) != (a_signs.y == b_signs.y):
		return stretch_case_half_match(a, b, player, a_signs, b_signs)
	
	# Case C: Signs are opposites and walls overlap on both or no axes.
	elif (distance.x < 0) == (distance.y < 0):
		return stretch_case_opposites(a, b, player_pos, a_signs, b_signs)
	
	# Case D: Signs are opposites and walls overlap on one axis.
	else:
		return stretch_case_tunnel(a, b, player_pos, a_signs, b_signs)


@warning_ignore("unused_parameter")
func stretch_case_half_match(a: Rect2i, b: Rect2i, player: Rect2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
	var stretch_pattern: Vector2i
	
	if a_signs.x == b_signs.x:
		if a_signs.x == -1:
			stretch_pattern = a_signs if a.position.x < b.position.x else b_signs
		else:
			stretch_pattern = a_signs if a.end.x > b.end.x else b_signs
	else:
		if a_signs.y == -1:
			stretch_pattern = a_signs if a.position.y < b.position.y else b_signs
		else:
			stretch_pattern = a_signs if a.end.y > b.end.y else b_signs
	
	return two_stretches_towards_signs(stretch_pattern)


func stretch_case_opposites(a: Rect2i, b: Rect2i, player_pos: Vector2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
	var stretch_pattern: Vector2i = Vector2i(1, 1)
	
	# This diagonal boundary is one of the parameters for the stretch pattern.
	var deciding_vector: Rect2i = Rect2i(
		get_rect_corner(a, a_signs),
		get_rect_corner(b, b_signs) - get_rect_corner(a, a_signs)
	)
	
	if deciding_vector.size == Vector2i.ZERO:
		deciding_vector.size = a_signs
	
	# The vector is flipped 180 degrees if it points
	# up for a less ambiguous "right" direction.
	if deciding_vector.size.y < 0:
		deciding_vector.size *= -1
	
	# Mirror stretch pattern horizontally if vector points right.
	if deciding_vector.size.x > 0:
		stretch_pattern.x *= -1
	
	# Flip stretch pattern 180 degrees if player is above the deciding vector.
	if point_above_vector(player_pos, deciding_vector):
		stretch_pattern *= -1
	
	return two_stretches_towards_signs(stretch_pattern)


@warning_ignore("unused_parameter")
func stretch_case_tunnel(a: Rect2i, b: Rect2i, player_pos: Vector2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
	var nearest_a: Vector2i = get_rect_corner(a, a_signs)
	var nearest_b: Vector2i = get_rect_corner(b, b_signs)
	
	var halfway_point: Vector2i = (nearest_a + nearest_b) / 2
	var stretch_pattern: Vector2i = Vector2i(1, 1)
	
	# There are a lot of conditions, yeah. At least it's very compact.
	
	# This condition being true means it's a horizontal tunnel.
	if get_distance(a, b).x < 0:
		if a_signs.x == a_signs.y:
			stretch_pattern.y *= -1
		
		if player_pos.x < halfway_point.x:
			stretch_pattern *= -1
	else:
		if a_signs.x == a_signs.y:
			stretch_pattern.x *= -1
		
		if player_pos.y < halfway_point.y:
			stretch_pattern *= -1
	
	return two_stretches_towards_signs(stretch_pattern)





#endregion
