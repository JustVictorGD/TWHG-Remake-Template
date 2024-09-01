extends Node

# Objects
const WALL_SIZE: Vector2 = Vector2(54, 54)

var touched_checkpoint_ids: PackedInt32Array = []
var walls: Array[Rect2] = []

var player: Node2D
var enemies: Array[Node] = []
var coins: Array[Node] = []
var checkpoints: Array[Node] = []
var keys: Array[Node] = []

# Assigning unique IDs to objects
var next_enemy_id: int = -1
var next_checkpoint_id: int = -1
var next_coin_id: int = -1
var next_key_id: int = -1


# These functions return a unique ID for the given object type,
# and create more space to store their information in corresponding arrays.
func register_enemy_id(node: Node) -> int:
	Objects.arrays["Enemies"].append(node)
	next_enemy_id += 1
	return next_enemy_id

func register_checkpoint_id(node: Node) -> int:
	checkpoints.append(node)
	next_checkpoint_id += 1
	return next_checkpoint_id

func register_coin_id(node: Node) -> int:
	coins.append(node)
	next_coin_id += 1
	AreaManager.max_money += 1
	return next_coin_id

func register_key_id(node: Node) -> int:
	keys.append(node)
	next_key_id += 1
	return next_key_id



# Purely convenient functions.
func rect_is_nan(rect: Rect2) -> bool:
	if is_nan(rect.position.x) or is_nan(rect.position.y) or is_nan(rect.size.x) or is_nan(rect.size.y):
		return true
	return false

func get_center(rect: Rect2) -> Vector2:
	return rect.position + rect.size / 2

func point_in_rect(position: Vector2, rect: Rect2) -> bool:
	if position.x >= rect.position.x and position.x <= rect.end.x and \
			position.y >= rect.position.y and position.y <= rect.end.y:
		return true
	return false

func point_in_rotated_rect(position: Vector2, rect: Rect2, rotation: float) -> bool:
	position = position.rotated(-rotation)
	rect.position = rect.position.rotated(-rotation)
	if point_in_rect(position, rect):
		return true
	return false

func rect_and_circle_overlap(rect: Rect2, circle_pos: Vector2, circle_radius: float) -> bool:
	var closest_point: Vector2 = Vector2(NAN, NAN)
	closest_point.x = clamp(circle_pos.x, rect.position.x, rect.end.x)
	closest_point.y = clamp(circle_pos.y, rect.position.y, rect.end.y)
	
	var distance: float = circle_pos.distance_to(closest_point)
	return distance < circle_radius



func push_out_of_walls(hitbox: Rect2, subpixels: Vector2i, given_walls: Array[Rect2]) -> Vector2:
	var proposed_position: Vector2i = get_center(hitbox) * 1000
	var half_size: Vector2 = hitbox.size / 2
	
	var intersections: Array[Rect2] = []
	for wall: Rect2 in given_walls:
		if hitbox.intersects(wall):
			var intersection: Rect2 = hitbox.intersection(wall)
			intersection.position -= get_center(hitbox)
			intersections.append(intersection)
	
	var edge: Vector2i = Vector2i.ZERO
	
	for intersection: Rect2 in intersections:
		if edge.x == 0:
			# Case: Vertical intersection
			if intersection.size.x < intersection.size.y:
				if intersection.position.x == -half_size.x:
					@warning_ignore("narrowing_conversion")
					proposed_position.x += intersection.size.x * 1000
					edge.x = -1
				
				if intersection.end.x == half_size.x:
					@warning_ignore("narrowing_conversion")
					proposed_position.x -= intersection.size.x * 1000
					edge.x = 1
		
		if edge.y == 0:
			# Case: Horizontal or square intersection
			if intersection.size.x > intersection.size.y or \
					intersection.size >= Vector2(4, 4):
				if intersection.position.y == -half_size.y:
					@warning_ignore("narrowing_conversion")
					proposed_position.y += intersection.size.y * 1000
					edge.y = -1
				
				if intersection.end.y == half_size.y:
					@warning_ignore("narrowing_conversion")
					proposed_position.y -= intersection.size.y * 1000
					edge.y = 1
	
	if edge.x == 0:
		proposed_position.x += subpixels.x
	if edge.x == 1:
		proposed_position.x += 999
	if edge.y == 0:
		proposed_position.y += subpixels.y
	if edge.y == 1:
		proposed_position.y += 999
	
	return proposed_position






# Danger zone below...





# Continue at your own risk...





# WARNING: This function is so complex that it tends to melt people's brains.
func corner_slide(dynamic_rect: Rect2, given_walls: Array[Rect2], sensitivity: float, velocity: Vector2, controls: Vector2i) -> Vector2:
	var player_movement: bool = false
	
	if controls != Vector2i.ZERO:
		player_movement = true
		velocity = Vector2.ZERO
	elif velocity == Vector2.ZERO:
		return Vector2.ZERO
	else:
		sensitivity *= 0.625 # Sensitivity is lower when not pressing anything.
	
	# Aborting in case of diagonal movement.
	if player_movement == true:
		if controls.x != 0 and controls.y != 0:
			return Vector2.ZERO
	else:
		if velocity.x != 0 and velocity.y != 0:
			return Vector2.ZERO
	
	# Finding any intersected walls.
	var intersections: Array[Rect2] = []
	for wall: Rect2 in given_walls:
		if dynamic_rect.intersects(wall):
			intersections.append(Rect2(dynamic_rect.intersection(wall).position - \
					get_center(dynamic_rect), dynamic_rect.intersection(wall).size))
	# Aborting in case of no wall intersections.
	if intersections.size() == 0:
		return Vector2.ZERO
	
	
	# Setting up important collision points: Corners and their limits that disable them.
	var half_size: float = dynamic_rect.size.x / 2
	var toggles: Dictionary = {
		"top_left_corner": false, "top_right_corner": false, "bottom_left_corner": false, "bottom_right_corner": false,
		# First word is movement direction, second word decides which relevant corner to disable.
		"up_left_limit": false, "up_right_limit": false, "left_up_limit": false, "left_down_limit": false,
		"down_left_limit": false, "down_right_limit": false, "right_up_limit": false, "right_down_limit": false,
	}
	
	var corners: Dictionary = {
		"top_left_corner": Vector2(-half_size, -half_size),
		"top_right_corner": Vector2(half_size, -half_size),
		"bottom_left_corner": Vector2(-half_size, half_size),
		"bottom_right_corner": Vector2(half_size, half_size),
	}
	
	var limits: Dictionary = {
		"up_left_limit": Vector2(-half_size + sensitivity, -half_size), 
		"up_right_limit": Vector2(half_size - sensitivity, -half_size),
		"left_up_limit": Vector2(-half_size, -half_size + sensitivity), 
		"left_down_limit": Vector2(-half_size, half_size - sensitivity),
		"down_left_limit": Vector2(-half_size + sensitivity, half_size), 
		"down_right_limit": Vector2(half_size - sensitivity, half_size),
		"right_up_limit": Vector2(half_size, -half_size + sensitivity), 
		"right_down_limit": Vector2(half_size, half_size - sensitivity),
	}
	# Compressing relevant information to loop through.
	var direction_checks: Array[Dictionary] = [
		# Case 0: Up
		{"corners": ["top_left_corner", "top_right_corner"], "limits": \
				["up_left_limit", "up_right_limit"], "offset": Vector2(1, 0)},
		# Case 1: Left
		{"corners": ["top_left_corner", "bottom_left_corner"], "limits": \
				["left_up_limit", "left_down_limit"], "offset": Vector2(0, 1)},
		# Case 2: Down
		{"corners": ["bottom_left_corner", "bottom_right_corner"], "limits": \
				["down_left_limit", "down_right_limit"], "offset": Vector2(1, 0)},
		# Case 3: Right
		{"corners": ["top_right_corner", "bottom_right_corner"], "limits": \
				["right_up_limit", "right_down_limit"], "offset": Vector2(0, 1)}
	]
	
	
	# Testing which collision points touch walls.
	for intersection: Rect2 in intersections:
		for corner: String in corners.keys():
			if point_in_rect(corners[corner], intersection):
				toggles[corner] = true
		
		for limit: String in limits.keys():
			if point_in_rect(limits[limit], intersection):
				toggles[limit] = true
	
	# Deciding the player's direction of movement to react to.
	# 0 for Up, 1 for Left, 2 for Down, 3 for Right. Order of WASD.
	var direction: int
	
	if player_movement: # Case: Movement keys are pressed
		if controls.y != 0:
			direction = 0 if controls.y < 0 else 2
		else:
			direction = 1 if controls.x < 0 else 3
	else: # Case: External forces like conveyors, no key presses.
		if velocity.y != 0:
			direction = 0 if velocity.y < 0 else 2
		else:
			direction = 1 if velocity.x < 0 else 3
	
	# Finally, based on all information previously gathered, the return values.
	var proposed_direction: Vector2 = Vector2.ZERO
	
	for i: int in range(2):
		if toggles[direction_checks[direction]["corners"][i]] and not \
			toggles[direction_checks[direction]["limits"][i]]:
			if i == 0:
				proposed_direction = direction_checks[direction]["offset"]
			else:
				proposed_direction = -direction_checks[direction]["offset"]
	
	return proposed_direction
