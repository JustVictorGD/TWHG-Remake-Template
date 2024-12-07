@icon("res://core/misc_assets/images/node_icons/player.png")
extends PushableBox
class_name Player


#region Properties



@export var speed: int = 4000 # One pixel per tick is 1,000
@export_range(0, 41) var sliding_sensitivity: int = 32

@onready var sprite: CanvasGroup = $CanvasGroup
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var outline: Sprite2D = $CanvasGroup/Outline
@onready var fill: Sprite2D = $CanvasGroup/Fill

@onready var fancy_hitbox: RectangleCollider = $RectangleCollider


var movement_direction: Vector2 = Vector2.ZERO

# Timers, used for fading the player in and out.
@onready var respawn_timer: TickBasedTimer = $RespawnTimer
@onready var death_animation: TickBasedTimer = $DeathAnimationTimer
@onready var respawn_animation: TickBasedTimer = $RespawnAnimationTimer

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
	fancy_hitbox.scale = PLAYER_SIZE
	
	respawn_timer.timeout.connect(respawn)
	
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.finish.connect(finish)


func movement_update() -> void:
	
	particles.emitting = true
	$TerrainVelocityComponent.enabled = true
	$InputVelocityComponent.enabled = true
	var speed_hack_multiplier: int = 2 if GameManager.speed_hacking else 1
	
	if dead:
		particles.emitting = false
		$TerrainVelocityComponent.enabled = false
		$InputVelocityComponent.enabled = false
		return
	
	# Movement from player controls.
	
	move(movement_direction * speed * speed_hack_multiplier)
	
	if GameManager.ghost:
		return
	
	# Wall related behavior.
	
	var touching_walls: Array[Rect2i] = []
	
	var larger_check: Rect2i = Rect2i(
		hitbox.position - Vector2i(8, 8),
		hitbox.size + Vector2i(16, 16)
		)
	
	for wall: Rect2i in World.walls:
		if wall.intersects(larger_check): touching_walls.append(wall)
	
	var merged_walls: Array[Rect2i] = []
	
	# It's going to be understandable to not understand this.
	
	if touching_walls.size() >= 2:
		for i: int in range(touching_walls.size() - 1):
			# Either Rect2i or null.
			var merge: Variant = Collider.try_merge(position, \
					touching_walls[i], touching_walls[i + 1], PLAYER_SIZE.x)
			
			if merge != null:
				merged_walls.append(merge)
			
			else:
				merged_walls.append(touching_walls[i])
				
				if i == touching_walls.size() - 2:
					merged_walls.append(touching_walls[i + 1])
	else:
		merged_walls = touching_walls
	
	var wall_push: Vector2i = Collider.updated_wall_push(hitbox, merged_walls) - Vector2i(position)
	
	move(wall_push * 1000)


func collision_update() -> void:
	fancy_hitbox.enabled = true
	Collider.touched_checkpoint_ids.clear()
	
	if dead:
		fancy_hitbox.enabled = false
		return
	
	for checkpoint: Checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if fancy_hitbox.intersects(checkpoint.hitbox):
			checkpoint.select()
			Collider.touched_checkpoint_ids.append(checkpoint.id)
			last_checkpoint_id = checkpoint.id
	
	for coin: Coin in get_tree().get_nodes_in_group("coins"):
		if fancy_hitbox.intersects(coin.hitbox):
			coin.try_collect()
	
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if not GameManager.invincible and fancy_hitbox.intersects(enemy.hitbox):
			enemy_death()
	
	for key: Key in get_tree().get_nodes_in_group("keys"):
		if fancy_hitbox.intersects(key.hitbox):
			key.try_collect()
	
	for paint: Paint in get_tree().get_nodes_in_group("paints"):
		if fancy_hitbox.intersects(paint.hitbox):
			paint.try_collect()
			outline.modulate = paint.outline_color
			fill.modulate = paint.fill_color
			particles.modulate = paint.fill_color


func update_timers() -> void:
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
	SFX.play(SFX.sounds.ENEMY_DEATH)
	
	respawn_timer.reset_and_play()
	death_animation.reset_and_play()
	
	GlobalSignal.player_death.emit()


func respawn() -> void:
	for checkpoint: Checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if checkpoint.id == last_checkpoint_id:
			move_to(checkpoint.hitbox.get_center() * 1000 + Vector2(500, 500))
	
	respawn_animation.reset_and_play()
	GlobalSignal.player_respawn.emit()
	
	dead = false


func finish() -> void:
	GameManager.invincible = true


#endregion
