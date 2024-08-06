extends Node2D

@export_range(0, 41) var sliding_sensitivity: int = 32

const PLAYER_SIZE: Vector2 = Vector2(42, 42)

var speed: float = 1
# Physics
var player_hitbox: Rect2 = Rect2(self.position - PLAYER_SIZE / 2, PLAYER_SIZE)
var last_direction: Vector2 = Vector2.ZERO
var internal_position: Vector2

# Special states
var invincible: bool = false # Death can't trigger
var dead: bool = false # Invincible but can't move
var ghost: bool = false # Ignore walls
var flying: bool = false # Ignore terrains

# Timers, used for fading the player in and out.
var respawn_timer: TickBasedTimer = TickBasedTimer.new(120)
var death_animation: TickBasedTimer = TickBasedTimer.new(90)
var respawn_animation: TickBasedTimer = TickBasedTimer.new(24)

# Respawning
var last_checkpoint_id: int = -1
var last_checkpoint_area: String # Unused... for now.


func _ready() -> void:
	internal_position = Collider.get_center(Collider.checkpoints[last_checkpoint_id].hitbox)
	sliding_sensitivity += 1
	respawn_timer.timeout.connect(respawn)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	
	GlobalSignal.finish.connect(finish)


func movement_update() -> void:
	var direction : Vector2 = Vector2.ZERO # Player Control
	
	if not dead:
		direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
		direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		
		internal_position += direction * speed
		last_direction = direction


func collision_update() -> void:
	position = round(internal_position)
	player_hitbox = Rect2(self.position - PLAYER_SIZE / 2, PLAYER_SIZE)
	
	handle_wall_collision()
	position = round(internal_position)
	player_hitbox = Rect2(self.position - PLAYER_SIZE / 2, PLAYER_SIZE)
	
	if not dead:
		handle_object_collision()
		position = round(internal_position)


#region Wall Collision
func handle_wall_collision() -> void:
	var intersected_walls: Array = []
	
	for wall_position: Vector2 in Collider.wall_positions:
		var wall_hitbox: Rect2 = Rect2(wall_position * 48 - Vector2(3, 3), Collider.WALL_SIZE)
		
		if player_hitbox.intersects(wall_hitbox):
			var intersection : Rect2 = player_hitbox.intersection(wall_hitbox)
			intersection.position -= self.position
			push_out_of_wall(intersection, wall_hitbox)
			intersected_walls.append(intersection)
	
	# No diagonals!
	if intersected_walls.size() > 0 and (last_direction.x == 0 or last_direction.y == 0):
		corner_slide(intersected_walls)

# TODO: Make this function more compact.
func corner_slide(intersections : Array) -> void:
	var points : Dictionary = {
		"top_left_corner" = false, "top_right_corner" = false,
		"bottom_left_corner" = false, "bottom_right_corner" = false,
		# First movement direction, then one of the corners to disable.
		"up_left_limit" = false, "up_right_limit" = false,
		"left_top_limit" = false, "left_bottom_limit" = false,
		"down_left_limit" = false, "down_right_limit" = false,
		"right_top_limit" = false, "right_bottom_limit" = false
	}
	# pls don't judge
	for intersection: Rect2 in intersections:
		if Collider.point_in_rect(Vector2(-21, -21), intersection):
			points["top_left_corner"] = true
		if Collider.point_in_rect(Vector2(21, -21), intersection):
			points["top_right_corner"] = true
		if Collider.point_in_rect(Vector2(-21, 21), intersection):
			points["bottom_left_corner"] = true
		if Collider.point_in_rect(Vector2(21, 21), intersection):
			points["bottom_right_corner"] = true
		
		if Collider.point_in_rect(Vector2(-21 + sliding_sensitivity, -21), intersection):
			points["up_left_limit"] = true
		if Collider.point_in_rect(Vector2(21 - sliding_sensitivity, -21), intersection):
			points["up_right_limit"] = true
		if Collider.point_in_rect(Vector2(-21, -21 + sliding_sensitivity), intersection):
			points["left_top_limit"] = true
		if Collider.point_in_rect(Vector2(-21, 21 - sliding_sensitivity), intersection):
			points["left_bottom_limit"] = true
		if Collider.point_in_rect(Vector2(-21 + sliding_sensitivity, 21), intersection):
			points["down_left_limit"] = true
		if Collider.point_in_rect(Vector2(21 - sliding_sensitivity, 21), intersection):
			points["down_right_limit"] = true
		if Collider.point_in_rect(Vector2(21, -21 + sliding_sensitivity), intersection):
			points["right_top_limit"] = true
		if Collider.point_in_rect(Vector2(21, 21 - sliding_sensitivity), intersection):
			points["right_bottom_limit"] = true
	
	# Moving up
	if last_direction.y == -1:
		if points["top_left_corner"] and not points["up_left_limit"]:
			internal_position.x += speed
		elif points["top_right_corner"] and not points["up_right_limit"]:
			internal_position.x -= speed
	# Moving left
	elif last_direction.x == -1:
		if points["top_left_corner"] and not points["left_top_limit"]:
			internal_position.y += speed
		elif points["bottom_left_corner"] and not points["left_bottom_limit"]:
			internal_position.y -= speed
	# Moving down
	elif last_direction.y == 1:
		if points["bottom_left_corner"] and not points["down_left_limit"]:
			internal_position.x += speed
		elif points["bottom_right_corner"] and not points["down_right_limit"]:
			internal_position.x -= speed
	# Moving right
	else:
		if points["top_right_corner"] and not points["right_top_limit"]:
			internal_position.y += speed
		elif points["bottom_right_corner"] and not points["right_bottom_limit"]:
			internal_position.y -= speed


func push_out_of_wall(intersection : Rect2, wall_hitbox : Rect2) -> void:
	# Case: Intersection is horizontal or large enough on both axis. Push player up or down.
	if intersection.size.x > intersection.size.y or intersection.size >= Vector2(2, 2):
		if intersection.position.y == -21:
			internal_position.y = wall_hitbox.end.y + 21
		if intersection.end.y == 21:
			internal_position.y = wall_hitbox.position.y - 21
	# Case: Intersection is vertical. Push player left or right.
	elif intersection.size.x < intersection.size.y:
		if intersection.position.x == -21:
			internal_position.x = wall_hitbox.end.x + 21
		if intersection.end.x == 21:
			internal_position.x = wall_hitbox.position.x - 21
#endregion


#region Object Collision
func handle_object_collision() -> void:
	var touched_checkpoint_ids: PackedInt32Array = []
	# Handling checkpoints.
	for checkpoint: ColorRect in Collider.checkpoints:
		if player_hitbox.intersects(checkpoint.hitbox):
			# Only activate when entering a checkpoint, when it wasn't being touched previously.
			if Collider.touched_checkpoint_ids.count(checkpoint.id) == 0:
				GlobalSignal.checkpoint_touched.emit(checkpoint.id)
			
			touched_checkpoint_ids.append(checkpoint.id)
			last_checkpoint_id = checkpoint.id
	
	Collider.touched_checkpoint_ids = touched_checkpoint_ids
	
	# Handling coins
	for coin: Node2D in Collider.coins:
		if Collider.point_in_rect(coin.global_position, \
				Rect2(-PLAYER_SIZE + position, PLAYER_SIZE * 2)):
			if Collider.rect_and_circle_overlap(player_hitbox, coin.global_position, coin.RADIUS):
				coin.collect()
				GlobalSignal.anything_collected.emit()
	
	# Handling enemies
	if not invincible:
		for enemy: Node2D in Collider.enemies:
			if Collider.point_in_rect(enemy.global_position, \
					Rect2(-PLAYER_SIZE + position, PLAYER_SIZE * 2)):
				if Collider.rect_and_circle_overlap(player_hitbox, \
						enemy.global_position, enemy.radius) and not dead:
					enemy_death()


func collect_coin(id: int) -> void:
	GlobalSignal.coin_collected.emit(id)


func enemy_death() -> void:
	dead = true
	AreaManager.deaths += 1
	SFX.play("EnemyDeath")
	
	respawn_timer.reset_and_play()
	death_animation.reset_and_play()
	
	GlobalSignal.player_death.emit()
#endregion


func update_timers() -> void:
	respawn_timer.tick()
	death_animation.tick()
	respawn_animation.tick()
	
	if death_animation.active:
		$CanvasGroup.self_modulate.a = death_animation.get_progress_left()
	elif dead: # Short time after the animation ends
		$CanvasGroup.self_modulate.a = 0
	
	if respawn_animation.active == true:
		$CanvasGroup.self_modulate.a = respawn_animation.get_progress()


func respawn() -> void:
	dead = false
	if last_checkpoint_id != -1:
		internal_position = Collider.get_center(Collider.checkpoints[last_checkpoint_id].hitbox)
		pass
	
	respawn_animation.reset_and_play()
	
	GlobalSignal.player_respawn.emit()


func finish() -> void:
	invincible = true
