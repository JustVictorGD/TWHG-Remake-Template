extends Node2D

const PLAYER_SIZE: Vector2 = Vector2(42, 42)

@export_range(0, 41) var sliding_sensitivity: int = 32

enum subpixel {
	MIN = 0, # Going below makes it loop to MAX.
	DEFAULT = 500,
	MAX = 999, # Going above makes it loop to MIN.
	RANGE = 1000
}

# Movement
var subpixels: Vector2i = Vector2i(subpixel.DEFAULT, subpixel.DEFAULT)

var speed: float = 1
var movement_direction: Vector2 = Vector2.ZERO # Primarily used for corner sliding.
var velocity: Vector2

# Physics
var hitbox: Rect2 = Rect2(position - PLAYER_SIZE / 2, PLAYER_SIZE)
var test_box: Rect2 = Rect2(position - PLAYER_SIZE, PLAYER_SIZE * 2)

# Special states
var invincible: bool = false # Death can't trigger
var dead: bool = false # Invincible but disables movement and is temporary
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
	position = Collider.get_center(Collider.checkpoints[last_checkpoint_id].hitbox)
	
	Collider.player = self
	
	sliding_sensitivity += 1
	respawn_timer.timeout.connect(respawn)
	
	GameLoop.movement_update.connect(movement_update)
	#GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	
	GlobalSignal.finish.connect(finish)


func movement_update() -> void:
	velocity = Vector2.ZERO
	
	velocity.y += 0.5 # Conveyor effect
	
	if not dead:
		movement_direction.x = (int(Input.is_action_pressed("right")) \
				- int(Input.is_action_pressed("left")))
		movement_direction.y = (int(Input.is_action_pressed("down")) \
				- int(Input.is_action_pressed("up")))
		
		move(movement_direction * speed)
		move(velocity)
	
	move(Collider.corner_slide(hitbox, Collider.walls, \
			sliding_sensitivity, velocity, movement_direction) * speed)
	
	#move_to(Collider.push_out_of_walls(hitbox, Collider.walls))

# Adds to the position using the subpixel system.
func move(movement: Vector2) -> void:
	subpixels += Vector2i(movement * 1000)
	
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
	hitbox = Rect2(position - PLAYER_SIZE / 2, PLAYER_SIZE)
	test_box = Rect2(position - PLAYER_SIZE, PLAYER_SIZE * 2)

# Sets the position using the subpixel system.
func move_to(given_position: Vector2) -> void:
	position = floor(given_position)
	subpixels = Vector2i((given_position - position) * 1000)



#region Object Collision
func handle_object_collision() -> void:
	var touched_checkpoint_ids: PackedInt32Array = []
	# Handling checkpoints.
	for checkpoint: ColorRect in Collider.checkpoints:
		if hitbox.intersects(checkpoint.hitbox):
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
			if Collider.rect_and_circle_overlap(hitbox, coin.global_position, coin.RADIUS):
				coin.collect()
				GlobalSignal.anything_collected.emit()


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
	
	print_position()


func respawn() -> void:
	if last_checkpoint_id != -1:
		position = Collider.get_center(Collider.checkpoints[last_checkpoint_id].hitbox)
		position = round(position)
	
	respawn_animation.reset_and_play()
	GlobalSignal.player_respawn.emit()
	
	dead = false


func finish() -> void:
	invincible = true


func print_position() -> void:
	# Explanation at: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html#padding
	print("X = %s.%03d, Y = %s.%03d" % [position.x, subpixels.x, position.y, subpixels.y])
