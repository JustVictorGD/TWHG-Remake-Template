extends Node2D

const PLAYER_SIZE: Vector2 = Vector2(42, 42)

@export var speed: int = 1000 # One pixel per tick is 1,000
@export var velocity: Vector2i = Vector2i(0, 0)
@export_range(0, 41) var sliding_sensitivity: int = 32

@onready var sprite: CanvasGroup = $CanvasGroup

enum subpixel {
	MIN = 0, # Going below makes it loop to MAX.
	DEFAULT = 500,
	MAX = 999, # Going above makes it loop to MIN.
	RANGE = 1000
}

# Physics
var hitbox_2: RectangleCollider = RectangleCollider.new(Rect2(position - PLAYER_SIZE / 2, PLAYER_SIZE))

var hitbox: Rect2 = Rect2(position - PLAYER_SIZE / 2, PLAYER_SIZE)
var test_box: Rect2 = Rect2(position - PLAYER_SIZE, PLAYER_SIZE * 2)

var dead: bool = false # Invincible but disables movement and is temporary

# Timers, used for fading the player in and out.
var respawn_timer: TickBasedTimer = TickBasedTimer.new(120)
var death_animation: TickBasedTimer = TickBasedTimer.new(90)
var respawn_animation: TickBasedTimer = TickBasedTimer.new(24)

# Respawning
var last_checkpoint_id: int = -1
var last_checkpoint_area: String # Unused... for now.

# Movement
var subpixels: Vector2i = Vector2i(subpixel.DEFAULT, subpixel.DEFAULT)
var movement_direction: Vector2 = Vector2.ZERO # Primarily used for corner sliding.



func _ready() -> void:
	position = Collider.get_center(Collider.checkpoints[last_checkpoint_id].hitbox)
	
	Collider.player = self
	
	sliding_sensitivity += 1
	respawn_timer.timeout.connect(respawn)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.finish.connect(finish)


func movement_update() -> void:
	var speed_hack_multiplier : int = int(AreaManager.speed_hacking) + 1
	if not dead:
		movement_direction.x = (int(Input.is_action_pressed("right")) \
				- int(Input.is_action_pressed("left")))
		movement_direction.y = (int(Input.is_action_pressed("down")) \
				- int(Input.is_action_pressed("up")))
		
		move(movement_direction * speed * speed_hack_multiplier)
		
		move(velocity)
	
	if not AreaManager.ghost:
		move(Collider.corner_slide(hitbox, Collider.walls, \
				sliding_sensitivity, velocity, movement_direction) * speed * speed_hack_multiplier)
		move_to(Collider.push_out_of_walls(hitbox_2, subpixels, Collider.walls))


func collision_update() -> void:
	Collider.touched_checkpoint_ids.clear()
	
	if dead:
		return
	
	for checkpoint: ColorRect in get_tree().get_nodes_in_group("checkpoints"):
		if hitbox.intersects(checkpoint.hitbox):
			checkpoint.select()
			Collider.touched_checkpoint_ids.append(checkpoint.id)
			last_checkpoint_id = checkpoint.id
	
	for coin: Node2D in get_tree().get_nodes_in_group("coins"):
		if hitbox_2.intersects(coin.hitbox):
			coin.collect()
	
	for enemy: Node2D in get_tree().get_nodes_in_group("enemies"):
		if not AreaManager.invincible and hitbox_2.intersects(enemy.hitbox):
			enemy_death()
	
	for key: Node2D in get_tree().get_nodes_in_group("keys"):
		if hitbox_2.intersects(key.hitbox):
			key.collect()


func collect_coin(id: int) -> void:
	GlobalSignal.coin_collected.emit(id)


func enemy_death() -> void:
	dead = true
	AreaManager.deaths += 1
	SFX.play("EnemyDeath")
	
	respawn_timer.reset_and_play()
	death_animation.reset_and_play()
	
	GlobalSignal.player_death.emit()


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


# Using normal frames and not the tick system
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("speed_hack"):
		toggle_speed_hack()
		
	if Input.is_action_just_pressed("invincibility"):
		toggle_invincibility()
		
	if Input.is_action_just_pressed("ghost"):
		toggle_ghost()


func respawn() -> void:
	for checkpoint: ColorRect in get_tree().get_nodes_in_group("checkpoints"):
		if checkpoint.id == last_checkpoint_id:
			move_to(Collider.get_center(checkpoint.hitbox) * 1000 + Vector2(500, 500))
	
	respawn_animation.reset_and_play()
	GlobalSignal.player_respawn.emit()
	
	dead = false


func finish() -> void:
	AreaManager.invincible = true


func print_position() -> void:
	# Weird formatting explained at: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html#padding
	print("X = %s.%03d, Y = %s.%03d" % [position.x, subpixels.x, position.y, subpixels.y])



# Adds to the position using the subpixel system.
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
	hitbox_2.position = position - PLAYER_SIZE / 2
	hitbox_2.size = PLAYER_SIZE
	
	test_box = Rect2(position - PLAYER_SIZE, PLAYER_SIZE * 2)

# Sets the position using the subpixel system.
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
	
	hitbox_2.position = position - PLAYER_SIZE / 2
	hitbox_2.size = PLAYER_SIZE
	
	test_box = Rect2(position - PLAYER_SIZE, PLAYER_SIZE * 2)

func toggle_speed_hack() -> void:
	if AreaManager.speed_hacking:
		AreaManager.speed_hacking = false
	else:
		AreaManager.speed_hacking = true

func toggle_invincibility() -> void:
	
	if AreaManager.invincible:
		AreaManager.invincible = false
	else:
		AreaManager.invincible = true

func toggle_ghost() -> void:
	if AreaManager.ghost:
		AreaManager.ghost = false
	else:
		AreaManager.ghost = true
