@icon("res://core/misc_assets/images/node_icons/player.png")
@tool
extends PushableBox
class_name Player


#region Properties

@export var speed: int = 4000 # One pixel per tick is 1,000
@export_range(0, 41) var sliding_sensitivity: int = 32
@export var size: Vector2i = Vector2i(42, 42)

@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Solid = $Sprite
@onready var fancy_hitbox: RectangleCollider = $RectangleCollider

var paint_id: int
var color_tuple: ColorTuple:
	get: return PaintManager.default_player if paint_id == -1 else PaintManager.unlockable_paints[paint_id]

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

#region Game Loop

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


func _ready() -> void:
	#sprite.change_shape(Rect2(Vector2.ZERO, size))
	
	if Engine.is_editor_hint():
		return
	
	
	hitbox.size = size
	
	sliding_sensitivity += 1
	
	fancy_hitbox.position = -size / 2
	fancy_hitbox.scale = size
	
	
	respawn_timer.timeout.connect(respawn)
	
	GameLoop.movement_update.connect(movement_update)
	GameLoop.collision_update.connect(collision_update)
	GameLoop.update_timers.connect(update_timers)
	
	#GlobalSignal.finish.connect(finish)
	
	paint_id = SaveFile.save_dictionary["global"]["color"]


func movement_update() -> void:
	sprite.outline_color = color_tuple.outline
	sprite.fill_color = color_tuple.fill
	particles.modulate = color_tuple.fill
	
	particles.process_material.scale = size
	
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
	
	# Movement from player controls.
	move(movement_direction * speed * speed_hack_multiplier)
	
	if not GameManager.ghost:
		# Comes from the 'PushableBox' class!
		var walls: Array[Rect2i] = get_nearby_walls()
		
		var push: Vector2i = push_out_of_walls(walls)
		
		var queue_death: bool = false
		
		if GameManager.invincible:
			move(push)
		
		else:
			if abs(push.x) / 1000 * 3 >= hitbox.size.x:
				queue_death = true
			else:
				move(Vector2i(push.x, 0))
			
			if abs(push.y) / 1000 * 3 >= hitbox.size.y:
				queue_death = true
			else:
				move(Vector2i(0, push.y))
			
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
			
			paint_id = paint.paint_id
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


func _process(delta: float) -> void:
	sprite.change_shape(Rect2(-size / 2, size))


#endregion
