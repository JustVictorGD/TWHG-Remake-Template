@tool
@icon("res://core/misc_assets/images/node_icons/enemy.png")
extends GameObject2D
class_name Enemy

## True by default because enemies rarely stay still.
## Turn off for static enemies to reduce unneeded GPU load.
@export var motion_trail: bool = true

## If true, it will keep updating its colors and size every frame in game.
## May cost some performance but allows themes that gradually change.
@export var constant_check: bool = false
@export var lock_scale: bool = false


@export var outline_shader: ShaderMaterial
@export var fill_shader: ShaderMaterial

var id: int

@onready var particles: GPUParticles2D = $GPUParticles2D


func _ready() -> void:
	super()
	
	# There's currently a problem with additional shaders now that 2
	# sprites of the enemy have been merged into one MaskedSprite.
	
	#if outline_shader != null:
	#	outline.material = outline_shader
	#if fill_shader != null:
	#	fill.material = fill_shader
	#	particles.material = fill_shader
	
	if not in_editor:
		if motion_trail:
			particles.emitting = GameManager.motion_trails
			
			if sprite != null:
				particles.modulate = sprite.fill_color
		
		if not GameManager.is_connected("movement_update", movement_update):
			GameManager.movement_update.connect(movement_update)
			Signals.trails_toggled.connect(trails_toggled)


func movement_update() -> void:
	if lock_scale:
		global_scale = Vector2(1, 1)


func _process(_delta: float) -> void:
	super(_delta)
	
	if not in_editor:
		var opacity: float = 0.5 if GameManager.invincible else 1.0
		
		sprite.material.set_shader_parameter("opacity", opacity)


func set_properties(properties: EnemyProperties) -> void:
	constant_check = properties.constant_check
	lock_scale = properties.lock_scale
	copy_area_theme = properties.copy_area_theme
	outline_color = properties.outline_color
	fill_color = properties.fill_color
	
	#if properties.outline_shader != null:
	#	outline.material = properties.outline_shader
	if properties.fill_shader != null:
	#	fill.material = properties.fill_shader
		particles.material = properties.fill_shader


func trails_toggled() -> void:
	particles.emitting = GameManager.motion_trails


func _on_hitbox_area_entered(area2d: Area2D) -> void:
	if area2d.is_in_group("destroyer"):
		queue_free()
