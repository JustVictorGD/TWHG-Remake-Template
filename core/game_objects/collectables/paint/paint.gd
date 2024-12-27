@icon("res://core/misc_assets/images/node_icons/paint.png")
@tool
extends Collectable
class_name Paint

@export var paint_id: int = 0

var color_tuple: ColorTuple:
	get:
		return PaintManager.unlockable_paints[paint_id]

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill

var is_ghost: bool = false


func _ready() -> void:
	super()
	hitbox = $CircleCollider


func stay_collected() -> void:
	#state = states.SAVED
	hitbox.enabled = false
	is_ghost = true


func update_timers() -> void:
	super()
	
	if color_tuple != null:
		outline.modulate = color_tuple.outline
		fill.modulate = color_tuple.fill
	else:
		push_warning("Paint ID ", paint_id, " doesn't exist.")
	
	if is_ghost:
		modulate = PaintManager.ghost_tint


func _process(delta: float) -> void:
	outline.modulate = color_tuple.outline
	fill.modulate = color_tuple.fill
