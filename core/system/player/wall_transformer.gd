extends Node
class_name WallTransformer


#region Utility Functions


static func get_distance(a: Rect2i, b: Rect2i) -> Vector2i:
	return Vector2i(
		max(a.position.x - b.end.x, b.position.x - a.end.x),
		max(a.position.y - b.end.y, b.position.y - a.end.y)
	)


static func point_above_vector(point: Vector2i, vector: Rect2i) -> bool:
	var result: bool = (point.x - vector.position.x) * vector.size.y - (point.y - vector.position.y) * vector.size.x > 0
	
	if vector.size.x > 0:
		return result
	
	return not result


static func get_rect_corner_signs(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		-1 if point.x <= rect_middle.x else 1,
		-1 if point.y <= rect_middle.y else 1
	)


static func is_point_above_vector(point: Vector2i, vector: Rect2i) -> bool:
	var result: bool = (point.x - vector.position.x) * vector.size.y - (point.y - vector.position.y) * vector.size.x > 0
	
	if vector.size.x > 0:
		return result
	
	return not result


static func get_rect_separation(rect_a: Rect2i, rect_b: Rect2i) -> Vector2i:
	return Vector2i(
		max(rect_a.position.x - rect_b.end.x, rect_b.position.x - rect_a.end.x),
		max(rect_a.position.y - rect_b.end.y, rect_b.position.y - rect_a.end.y)
	)


static func get_rect_corner(rect: Rect2i, coordinate_signs: Vector2i) -> Vector2i:
	return Vector2i(
		rect.position.x if coordinate_signs.x != 1 else rect.end.x,
		rect.position.y if coordinate_signs.y != 1 else rect.end.y
	)


static func get_nearest_corner_signs(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		-1 if point.x <= rect_middle.x else 1,
		-1 if point.y <= rect_middle.y else 1
	)


static func get_nearest_corner_position(point: Vector2, rect: Rect2i) -> Vector2i:
	var rect_middle: Vector2i = rect.position + rect.size / 2
	
	return Vector2i(
		rect.position.x if point.x < rect_middle.x else rect.end.x,
		rect.position.y if point.y < rect_middle.y else rect.end.y
	)


static func two_stretches_towards_signs(signs: Vector2i) -> Array[Rect2i]:
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


static func stretch(rect: Rect2i, direction: Vector2i) -> Rect2i:
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


static func can_merge(a: Rect2i, b: Rect2i, player_pos: Vector2, leniency: Vector2) -> bool:
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


static func merge_walls(walls: Array[Rect2i], player: Rect2i) -> Array[Rect2i]:
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


static func get_stretches(walls: Array[Rect2i], player: Rect2i) -> Array[Rect2i]:
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
	
	var stretched_walls: Array[Rect2i] = []
	
	for i: int in range(transformations.size()):
		var transformation: Rect2i = transformations[i]
		
		if transformation.position == Vector2i.ZERO and \
				transformation.size == Vector2i.ZERO:
			continue
		
		var new_wall: Rect2i = walls[i]
		
		if transformation.position.x != 0:
			new_wall = stretch(new_wall, Vector2i.LEFT)
		if transformation.position.y != 0:
			new_wall = stretch(new_wall, Vector2i.UP)
		if transformation.size.x != 0:
			new_wall = stretch(new_wall, Vector2i.RIGHT)
		if transformation.size.y != 0:
			new_wall = stretch(new_wall, Vector2i.DOWN)
		
		stretched_walls.append(new_wall)
	
	return stretched_walls



static func get_stretch(a: Rect2i, b: Rect2i, player: Rect2i) -> Array[Rect2i]:
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
static func stretch_case_half_match(a: Rect2i, b: Rect2i, player: Rect2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
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


static func stretch_case_opposites(a: Rect2i, b: Rect2i, player_pos: Vector2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
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
	if deciding_vector.size.y <= 0:
		deciding_vector.size *= -1
	
	# Mirror stretch pattern horizontally if vector points right.
	if deciding_vector.size.x >= 0:
		stretch_pattern.x *= -1
	
	# Flip stretch pattern 180 degrees if player is above the deciding vector.
	if point_above_vector(player_pos, deciding_vector):
		stretch_pattern *= -1
	
	# Fixing quite specific bug
	if deciding_vector.size.x == 0 or deciding_vector.size.y == 0:
		stretch_pattern *= -1
	
	return two_stretches_towards_signs(stretch_pattern)


@warning_ignore("unused_parameter")
static func stretch_case_tunnel(a: Rect2i, b: Rect2i, player_pos: Vector2i, a_signs: Vector2i, b_signs: Vector2i) -> Array[Rect2i]:
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
