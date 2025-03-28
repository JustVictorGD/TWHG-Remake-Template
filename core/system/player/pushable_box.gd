extends Node2D
class_name PushableBox

enum subpixel {
	MIN = 0, # Going below makes it loop to MAX.
	DEFAULT = 500,
	MAX = 999, # Going above makes it loop to MIN.
	RANGE = 1000
}

# Physics and movement
var hitbox: Rect2i = Rect2i(0, 0, 42, 42)
var subpixels: Vector2i = Vector2i(subpixel.DEFAULT, subpixel.DEFAULT)


func get_nearby_walls(sliding_sensitivity: float) -> Array[Rect2i]:
	var nearby_walls: Array[Rect2i] = []
	
	var larger_check: Rect2i = Rect2i(
		hitbox.position - Vector2i(8, 8),
		hitbox.size + Vector2i(16, 16)
		)
	
	larger_check.position -= Vector2i(hitbox.size * sliding_sensitivity)
	
	larger_check.size += Vector2i(hitbox.size * sliding_sensitivity * 2)
	
	for wall: Rect2i in GameManager.walls:
		if wall.intersects(larger_check):
			nearby_walls.append(wall)
	
	nearby_walls = WallTransformer.merge_walls(nearby_walls, hitbox)
	nearby_walls += WallTransformer.get_stretches(nearby_walls, hitbox)
	
	return nearby_walls


#region Wall Physics


func push_out_of_walls(walls: Array[Rect2i]) -> Vector2i:
	for wall: Rect2 in walls:
		hitbox = push_out_rectangle(hitbox, wall)
	
	return (hitbox.position + hitbox.size / 2 - Vector2i(position)) * 1000


func get_closest(anchor: int, a: int, b: int) -> int:
	return a if abs(anchor - a) < abs(anchor - b) else b


func push_out_rectangle(rect: Rect2i, wall: Rect2i) -> Rect2i:
	# Calculate overlaps
	var left_overlap: int = wall.position.x - (rect.position.x + rect.size.x)
	var right_overlap: int = (wall.position.x + wall.size.x) - rect.position.x
	var top_overlap: int = wall.position.y - (rect.position.y + rect.size.y)
	var bottom_overlap: int = (wall.position.y + wall.size.y) - rect.position.y
	
	# If there's no overlap, return the rectangle as is
	if left_overlap > 0 or right_overlap < 0 or top_overlap > 0 or bottom_overlap < 0:
		return rect
	
	var push: Vector2i = Vector2i(
		get_closest(0, left_overlap, right_overlap),
		get_closest(0, top_overlap, bottom_overlap)
	)
	
	# Slightly favor X axis.
	if abs(push.x) <= abs(push.y):
		push.y = 0
	else:
		push.x = 0
	
	rect.position += push
	return rect

#endregion

#region Corner Sliding

# This function suggests a direction in which you should move in to
# avoid getting stuck on a corner. The way you use it is up to you.
func corner_slide(walls: Array[Rect2i], speed_from_input: Vector2i, external_velocity: Vector2i, sensitivity: float) -> Vector2i:
	# Save resources if there are no walls to slide around by aborting.
	if walls.size() == 0:
		return Vector2i.ZERO
	
	# The interpreted movement direction.
	# Expecting Vector2i.UP, LEFT, DOWN or RIGHT.
	var movement_direction: Vector2i = sign(speed_from_input) if \
			speed_from_input != Vector2i.ZERO else sign(external_velocity)
	
	# Abort in case of diagonal or no movement.
	if (movement_direction.x != 0 and movement_direction.y != 0) or \
			movement_direction == Vector2i.ZERO:
		return Vector2i.ZERO
	
	# Position X being at -2.147 billion is a way
	# to determine if this variable is untouched.
	var chosen_wall: Rect2i = Rect2i(-2147483648, 0, 0, 0)
	
	var touching_a_wall: bool = false
	
	for wall: Rect2i in walls:
		if hitbox.intersects(wall):
			touching_a_wall = true
			
			# Sorry for the repetitive code, I just need to get this working.
			
			match movement_direction:
				Vector2i.UP:
					if wall.end.y < hitbox.end.y:
						# The first touched wall should assign itself to "chosen_wall."
						if chosen_wall.position.x == -2147483648:
							chosen_wall = wall
						
						if chosen_wall.end.y <= wall.end.y:
							if chosen_wall.end.y < wall.end.y or wall.size.x > chosen_wall.size.x:
								chosen_wall = wall
				
				Vector2i.LEFT:
					if wall.end.x < hitbox.end.x:
						# The first touched wall should assign itself to "chosen_wall."
						if chosen_wall.position.x == -2147483648:
							chosen_wall = wall
						
						if chosen_wall.end.x <= wall.end.x:
							if chosen_wall.end.x < wall.end.x or wall.size.y > chosen_wall.size.y:
								chosen_wall = wall
				
				Vector2i.DOWN:
					if wall.position.y > hitbox.position.y:
						# The first touched wall should assign itself to "chosen_wall."
						if chosen_wall.position.x == -2147483648:
							chosen_wall = wall
						
						if chosen_wall.position.y >= wall.position.y:
							if chosen_wall.position.y > wall.position.y or wall.size.x > chosen_wall.size.x:
								chosen_wall = wall
				
				Vector2i.RIGHT:
					if wall.position.x > hitbox.position.x:
						# The first touched wall should assign itself to "chosen_wall."
						if chosen_wall.position.x == -2147483648:
							chosen_wall = wall
						
						if chosen_wall.position.x >= wall.position.x:
							if chosen_wall.position.x > wall.position.x or wall.size.y > chosen_wall.size.y:
								chosen_wall = wall
	
	if not touching_a_wall:
		return Vector2i.ZERO
	
	if chosen_wall.position.x == -2147483648:
		return Vector2i.ZERO
	
	var half_size: Vector2i = hitbox.size / 2
	var box_center: Vector2i = hitbox.position + half_size
	
	# Repetition...
	
	# Moving either left or right.
	if movement_direction.y == 0:
		var distance_up: int = box_center.y - chosen_wall.position.y + half_size.y
		var distance_down: int = chosen_wall.end.y - box_center.y + half_size.y
		
		# Don't slide in case of a perfect tie
		if distance_up == distance_down:
			return Vector2i.ZERO
		
		if distance_up > hitbox.size.y * sensitivity and distance_down > hitbox.size.y * sensitivity:
			return Vector2i.ZERO
		
		return Vector2i.UP if distance_up < distance_down else Vector2i.DOWN
	
	# Moving either up or down.
	else:
		var distance_left: int = box_center.x - chosen_wall.position.x + half_size.x
		var distance_right: int = chosen_wall.end.x - box_center.x + half_size.x
		
		# Don't slide in case of a perfect tie
		if distance_left == distance_right:
			return Vector2i.ZERO
		
		if distance_left > hitbox.size.x * sensitivity and distance_right > hitbox.size.x * sensitivity:
			return Vector2i.ZERO
		
		return Vector2i.LEFT if distance_left < distance_right else Vector2i.RIGHT

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
	
	clamp_subpixels()

# Sets the position using the subpixel system.
# This function uses subpixels. Multiply any input in pixels by 1000.
func move_to(given_position: Vector2i) -> void:
	position = given_position / 1000
	subpixels = given_position % 1000
	
	clamp_subpixels()


func clamp_subpixels() -> void:
	@warning_ignore("integer_division")
	var wraps: Vector2i = Vector2i(
		subpixels.x / subpixel.RANGE,
		subpixels.y / subpixel.RANGE
	)
	
	subpixels -= wraps * subpixel.RANGE
	
	if subpixels.x < 0:
		subpixels.x += subpixel.RANGE
		wraps.x -= 1
	if subpixels.y < 0:
		subpixels.y += subpixel.RANGE
		wraps.y -= 1
	
	position += Vector2(wraps)
	hitbox.position = Vector2i(position) - hitbox.size / 2

#endregion
