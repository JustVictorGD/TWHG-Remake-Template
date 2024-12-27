@tool
@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

# False by default because coins rarely move.
@export var motion_trail: bool = false
@export var constant_check: bool = false

@export var copy_area_theme: bool = true
@export var outline_color: Color = Color(0.584, 0.467, 0)
@export var fill_color: Color = Color(0, 0.8, 0)

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill

func _ready() -> void:
	# Call the _ready() function of the Collectable class.
	super()
	
	update_colors()
	
	if motion_trail:
		$GPUParticles2D.emitting = true
	
	hitbox = $CircleCollider
	World.money_requirement += 1

func _process(_delta: float) -> void:
	if constant_check or Engine.is_editor_hint():
		update_colors()

func collect() -> void:
	super()
	
	World.collected_money += 1
	GlobalSignal.coin_collected.emit()


func stay_collected() -> void:
	super()
	
	World.collected_money += 1


func drop() -> void:
	super()
	
	World.collected_money -= 1


func update_colors() -> void:
	var theme: AreaTheme
	
	if owner is Area:
		theme = owner.theme
	
	if copy_area_theme and theme != null:
		outline.modulate = theme.gold_outline
		fill.modulate = theme.gold_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
	
	$GPUParticles2D.modulate = fill.modulate
