@tool
@icon("res://core/misc_assets/images/node_icons/enemy.png")
extends Node2D
class_name Enemy

## If true, it will keep updating its colors and size every frame in game.
## May cost some performance but allows themes that gradually change.
@export var constant_check: bool = false
@export var lock_scale: bool = false

@export var copy_area_theme: bool = true

@export var outline_color: Color = Color(0, 0, 0.4)
@export var fill_color: Color = Color(0, 0, 1)

var hitbox: CircleCollider = CircleCollider.new(Vector2.ZERO, 7)
var id: int
# For cases when opacity is changed externally, like from invincibility
@onready var original_opacity: float = modulate.a

var in_editor: bool:
	get:
		return Engine.is_editor_hint()

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill


func _ready() -> void:
	update_colors()
	
	if not in_editor:
		GameLoop.movement_update.connect(movement_update)


func movement_update() -> void:
	hitbox.position = self.global_position
	
	if lock_scale:
		global_scale = Vector2(1, 1)


func _process(_delta: float) -> void:
	if constant_check or in_editor:
		update_colors()
	
	if not in_editor:
		if GameManager.invincible:
			modulate.a = original_opacity * 0.5
		else:
			modulate.a = original_opacity


func update_colors() -> void:
	var theme: AreaTheme
	
	if owner is Area:
		theme = owner.theme
	
	if copy_area_theme and theme != null:
		outline.modulate = theme.enemy_outline
		fill.modulate = theme.enemy_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
