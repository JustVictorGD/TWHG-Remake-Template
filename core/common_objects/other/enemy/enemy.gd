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

@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var outline: Sprite2D = $CanvasGroup/Outline
@onready var fill: Sprite2D = $CanvasGroup/Fill


func _ready() -> void:
	update_colors(Engine.is_editor_hint())
	
	if not Engine.is_editor_hint():
		GameLoop.movement_update.connect(movement_update)


func movement_update() -> void:
	hitbox.position = self.global_position
	
	if lock_scale:
		global_scale = Vector2(1, 1)


func _process(_delta: float) -> void:
	if constant_check:
		update_colors(false)
	if Engine.is_editor_hint():
		update_colors(true)
	
	if not Engine.is_editor_hint():
		if GameManager.invincible:
			canvas_group.self_modulate.a = original_opacity * 0.5
		else:
			canvas_group.self_modulate.a = original_opacity


func update_colors(in_editor: bool) -> void:
	var theme: AreaTheme
	
	if in_editor:
		theme = owner.theme
	else:
		theme = World.current_level.theme
	
	if copy_area_theme and theme != null:
		outline.modulate = theme.enemy_outline
		fill.modulate = theme.enemy_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
