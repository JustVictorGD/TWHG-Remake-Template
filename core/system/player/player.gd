extends Node2D
class_name Player


#region Properties

const PLAYER_SIZE: Vector2 = Vector2(42, 42)

@export var speed: int = 4000 # One pixel per tick is 1,000
@export var velocity: Vector2i = Vector2i(0, 0)
@export_range(0, 41) var sliding_sensitivity: int = 32

@onready var sprite: CanvasGroup = $CanvasGroup

enum subpixel {
	MIN = 0, # Going below makes it loop to MAX.
	DEFAULT = 500,
	MAX = 999, # Going above makes it loop to MIN.
	RANGE = 1000
}

# Physics and movement
var hitbox: RectangleCollider = RectangleCollider.new()
var subpixels: Vector2i = Vector2i(subpixel.DEFAULT, subpixel.DEFAULT)
var movement_direction: Vector2 = Vector2.ZERO

# Timers, used for fading the player in and out.
var respawn_timer: TickBasedTimer = TickBasedTimer.new(30)
var death_animation: TickBasedTimer = TickBasedTimer.new(15)
var respawn_animation: TickBasedTimer = TickBasedTimer.new(6)

# Respawning
var last_checkpoint_id: int = -1
var last_checkpoint_area: int # Unused... for now.
var dead: bool = false # Invincible but disables movement and is temporary

#endregion


func _input(_event: InputEvent) -> void:
	handle_key_press(GameManager.snappy_movement)
	
	if not dead:
		if Input.is_action_pressed("teleport"):
			move_to(get_global_mouse_position() * 1000)
		

func handle_key_press(snappy_movement: bool) -> void:
	if snappy_movement:
		# Horizontal
		# Normal movement
		if Input.is_action_just_pressed("left"):
			movement_direction.x = -1
		if Input.is_action_just_pressed("right"):
			movement_direction.x = 1
		# Release while holding opposite direction
		if Input.is_action_just_released("left") and Input.is_action_pressed("right"):
			movement_direction.x = 1
		if Input.is_action_just_released("right") and Input.is_action_pressed("left"):
			movement_direction.x = -1
		# Nothing held
		if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
			movement_direction.x = 0
		
		# Vertical
		# Normal movement
		if Input.is_action_just_pressed("up"):
			movement_direction.y = -1
		if Input.is_action_just_pressed("down"):
			movement_direction.y = 1
		# Release while holding opposite direction
		if Input.is_action_just_released("up") and Input.is_action_pressed("down"):
			movement_direction.y = 1
		if Input.is_action_just_released("down") and Input.is_action_pressed("up"):
			movement_direction.y = -1
		# Nothing held
		if not Input.is_action_pressed("up") and not Input.is_action_pressed("down"):
			movement_direction.y = 0
	else:
		movement_direction.x = (int(Input.is_action_pressed("right")) \
				- int(Input.is_action_pressed("left")))
		movement_direction.y = (int(Input.is_action_pressed("down")) \
				- int(Input.is_action_pressed("up")))
	


#region Game Loop


func _ready() -> void:
	sliding_sensitivity += 1
	respawn_timer.timeout.connect(respawn)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.finish.connect(finish)


func movement_update() -> void:
	var speed_hack_multiplier: int = int(GameManager.speed_hacking) + 1
	
	if not dead:
		move(movement_direction * speed * speed_hack_multiplier)
		move(velocity)
	
	if not GameManager.ghost:
		move(Collider.corner_slide(hitbox, World.walls, \
				sliding_sensitivity, velocity, movement_direction) * speed * speed_hack_multiplier)
		move_to(Collider.push_out_of_walls(hitbox, subpixels, World.walls))


func collision_update() -> void:
	Collider.touched_checkpoint_ids.clear()
	
	if dead:
		return
	
	for checkpoint: Checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if hitbox.intersects(checkpoint.hitbox):
			checkpoint.select()
			Collider.touched_checkpoint_ids.append(checkpoint.id)
			last_checkpoint_id = checkpoint.id
	
	for coin: Coin in get_tree().get_nodes_in_group("coins"):
		if hitbox.intersects(coin.hitbox):
			coin.collect()
	
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if not GameManager.invincible and hitbox.intersects(enemy.hitbox):
			enemy_death()
	
	for key: Key in get_tree().get_nodes_in_group("keys"):
		if hitbox.intersects(key.hitbox):
			key.collect()



func update_timers() -> void:
	respawn_timer.tick_and_timeout()
	death_animation.tick_and_timeout()
	respawn_animation.tick_and_timeout()
	
	sprite.self_modulate.a = 1
	
	if death_animation.active:
		sprite.self_modulate.a = death_animation.get_progress_left()
	elif dead: # Short time after the animation ends
		sprite.self_modulate.a = 0
	
	if respawn_animation.active == true:
		sprite.self_modulate.a = respawn_animation.get_progress()


#endregion


#region Gameplay Functions


func collect_coin(id: int) -> void:
	GlobalSignal.coin_collected.emit(id)


func enemy_death() -> void:
	dead = true
	GameManager.deaths += 1
	SFX.play("EnemyDeath")
	
	respawn_timer.reset_and_play()
	death_animation.reset_and_play()
	
	GlobalSignal.player_death.emit()


func respawn() -> void:
	for checkpoint: ColorRect in get_tree().get_nodes_in_group("checkpoints"):
		if checkpoint.id == last_checkpoint_id:
			move_to(checkpoint.hitbox.get_center() * 1000 + Vector2(500, 500))
	
	respawn_animation.reset_and_play()
	GlobalSignal.player_respawn.emit()
	
	dead = false


func finish() -> void:
	GameManager.invincible = true


#endregion


#region Special Position Handling


func print_position() -> void:
	# Weird formatting explained at: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html#padding
	print("X = %s.%03d, Y = %s.%03d" % [position.x, subpixels.x, position.y, subpixels.y])


# Adds to the position using the subpixel system.
# This function uses subpixels. Multiply any input in pixels by 1000.
func move(movement: Vector2i) -> void:
	subpixels += movement
	
	while subpixels.x > subpixel.MAX:
		subpixels.x -= subpixel.RANGE
		global_position.x += 1
	while subpixels.x < subpixel.MIN:
		subpixels.x += subpixel.RANGE
		global_position.x -= 1
	while subpixels.y > subpixel.MAX:
		subpixels.y -= subpixel.RANGE
		global_position.y += 1
	while subpixels.y < subpixel.MIN:
		subpixels.y += subpixel.RANGE
		global_position.y -= 1
	
	global_position = round(global_position)
	hitbox.position = global_position - PLAYER_SIZE / 2
	hitbox.size = PLAYER_SIZE


# Sets the position using the subpixel system.
# This function uses subpixels. Multiply any input in pixels by 1000.
func move_to(given_position: Vector2i) -> void:
	global_position = given_position / 1000
	
	subpixels.x = given_position.x % 1000
	subpixels.y = given_position.y % 1000
	
	while subpixels.x > subpixel.MAX:
		subpixels.x -= subpixel.RANGE
		global_position.x += 1
	while subpixels.x < subpixel.MIN:
		subpixels.x += subpixel.RANGE
		global_position.x -= 1
	while subpixels.y > subpixel.MAX:
		subpixels.y -= subpixel.RANGE
		global_position.y += 1
	while subpixels.y < subpixel.MIN:
		subpixels.y += subpixel.RANGE
		global_position.y -= 1
	
	global_position = round(global_position)
	
	hitbox.position = global_position - PLAYER_SIZE / 2
	hitbox.size = PLAYER_SIZE


#endregion
