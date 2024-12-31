@icon("res://core/misc_assets/images/node_icons/player.png")
@tool
extends PushableBox
class_name Player


#region Properties

@export var speed: int = 4000 # One pixel per tick is 1,000

## How much the player is allowed to travel from a wall 
## push relative to its own size without getting crushed.
@export var crush_leniency: float = 1.0/3.0

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Solid = $Sprite
@onready var fancy_hitbox: RectangleCollider = $RectangleCollider

#var paint_id: int
var color_tuple: ColorTuple:
	get: 
		if PaintManager.current_paint_id == -1:
			return PaintManager.default_player
		else:
			return PaintManager.unlockable_paints[PaintManager.current_paint_id]
		#return PaintManager.default_player if PaintManager.current_paint_id == -1 else PaintManager.unlockable_paints[paint_id]

var movement_direction: Vector2 = Vector2.ZERO

# Timers, used for fading the player in and out.
@onready var respawn_timer: TickBasedTimer = $RespawnTimer
@onready var death_animation: TickBasedTimer = $DeathAnimationTimer
@onready var respawn_animation: TickBasedTimer = $RespawnAnimationTimer

# Respawning
var last_checkpoint_id: int = -1
var last_checkpoint_area: int # Unused... for now.
var dead: bool = false # Invincible but disables movement and is temporary

# Used for the snappy movement option.
var last_direction: Vector2i = Vector2i.ZERO

#endregion

#region Game Loop

func _input(_event: InputEvent) -> void:
	handle_key_press(GameManager.snappy_movement)
	
	if not dead:
		if Input.is_action_pressed("teleport"):
			move_to(get_global_mouse_position() * 1000)


func handle_key_press(snappy_movement: bool) -> void:
	var pressing_up: bool = Input.is_action_pressed("up")
	var pressing_left: bool = Input.is_action_pressed("left")
	var pressing_down: bool = Input.is_action_pressed("down")
	var pressing_right: bool = Input.is_action_pressed("right")
	
	if not snappy_movement:
		movement_direction.x = (int(pressing_right) - int(pressing_left))
		movement_direction.y = (int(pressing_down) - int(pressing_up))
	
	else:
		movement_direction = Vector2i.ZERO
		
		if Input.is_action_just_pressed("left"):
			last_direction.x = -1
		elif Input.is_action_just_pressed("right"):
			last_direction.x = 1
		if Input.is_action_just_pressed("up"):
			last_direction.y = -1
		elif Input.is_action_just_pressed("down"):
			last_direction.y = 1
		
		if pressing_left and pressing_right:
			movement_direction.x = last_direction.x
		elif pressing_left:
			movement_direction.x = -1
		elif pressing_right:
			movement_direction.x = 1
		
		if pressing_up and pressing_down:
			movement_direction.y = last_direction.y
		elif pressing_up:
			movement_direction.y = -1
		elif pressing_down:
			movement_direction.y = 1


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	respawn_timer.timeout.connect(respawn)
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	GlobalSignal.paint_changed.connect(on_paint_change)
	
	PaintManager.current_paint_id = SaveFile.save_dictionary["global"]["color"]


func change_size(size: Vector2i) -> void:
	hitbox.size = size
	fancy_hitbox.position = -size / 2
	fancy_hitbox.scale = size
	particles.process_material.scale = size
	sprite.change_shape(Rect2(-size / 2, size))


func movement_update() -> void:
	var sliding_sensitivity: float = GameManager.sliding_sensitivity
	
	sprite.outline_color = color_tuple.outline
	sprite.fill_color = color_tuple.fill
	particles.modulate = color_tuple.fill
	
	var speed_hack_multiplier: int = 2 if GameManager.speed_hacking else 1
	
	if not dead:
		particles.emitting = true
		$TerrainVelocityComponent.enabled = true
		$InputVelocityComponent.enabled = true
	else:
		particles.emitting = false
		$TerrainVelocityComponent.enabled = false
		$InputVelocityComponent.enabled = false
		return
	
	var movement: Vector2i = movement_direction * speed * speed_hack_multiplier
	var pixel_movement: Vector2i = movement / 1000
	
	# Movement from player controls.
	move(movement)
	
	if not GameManager.ghost:
		# Comes from the 'PushableBox' class!
		var walls: Array[Rect2i] = get_nearby_walls(sliding_sensitivity)
		
		var up_crush_threshold: int = int(-hitbox.size.x * crush_leniency)
		var left_crush_threshold: int = int(-hitbox.size.y * crush_leniency)
		var down_crush_threshold: int = int(hitbox.size.x * crush_leniency)
		var right_crush_threshold: int = int(hitbox.size.y * crush_leniency)
		
		if movement.x < 0:
			right_crush_threshold -= pixel_movement.x
		else:
			left_crush_threshold -= pixel_movement.x
		
		if movement.y < 0:
			down_crush_threshold -= pixel_movement.y
		else:
			up_crush_threshold -= pixel_movement.y
		
		move(corner_slide(walls, movement_direction * 4, Vector2i(0, 0), sliding_sensitivity) * speed)
		
		var push: Vector2i = push_out_of_walls(walls)
		var queue_death: bool = false
		var pixel_push: Vector2i = push / 1000
		
		if GameManager.invincible:
			move(push)
		
		else:
			if up_crush_threshold <= pixel_push.y and \
					pixel_push.y <= down_crush_threshold:
				move(Vector2i(0, push.y))
			else:
				queue_death = true
			
			if left_crush_threshold <= pixel_push.x and \
					pixel_push.x <= right_crush_threshold:
				move(Vector2i(push.x, 0))
			else:
				queue_death = true
			
			if queue_death:
				enemy_death()


func collision_update() -> void:
	if not GameManager.collectables_processed:
		return
	
	fancy_hitbox.enabled = true
	World.touched_checkpoint_ids.clear()
	
	if dead:
		fancy_hitbox.enabled = false
		return
	
	for checkpoint: Checkpoint in get_tree().get_nodes_in_group("checkpoints"):
		if fancy_hitbox.intersects(checkpoint.hitbox):
			checkpoint.select()
			World.touched_checkpoint_ids.append(checkpoint.id)
			last_checkpoint_id = checkpoint.id
	
	for coin: Coin in get_tree().get_nodes_in_group("coins"):
		if fancy_hitbox.intersects(coin.hitbox):
			coin.try_collect()
	
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if not GameManager.invincible and not GameManager.finished and fancy_hitbox.intersects(enemy.hitbox):
			enemy_death()
	
	for key: Key in get_tree().get_nodes_in_group("keys"):
		if fancy_hitbox.intersects(key.hitbox):
			key.try_collect()
	
	for paint: Paint in get_tree().get_nodes_in_group("paints"):
		if fancy_hitbox.intersects(paint.hitbox):
			paint.try_collect()
			
			PaintManager.current_paint_id = paint.paint_id
			#SaveFile.save_dictionary["global"]["color"] = paint.paint_id


func update_timers() -> void:
	sprite.modulate.a = 1
	
	if death_animation.active:
		sprite.modulate.a = death_animation.get_progress_left()
	elif dead: # Short time after the animation ends
		sprite.modulate.a = 0
	
	if respawn_animation.active == true:
		sprite.modulate.a = respawn_animation.get_progress()


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


func on_paint_change(id: int) -> void:
	sprite.outline_color = color_tuple.outline
	sprite.fill_color = color_tuple.fill
	particles.modulate = color_tuple.fill

#endregion
