@tool
extends Collectable
class_name Paint

@export var paint_id: int = 0

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill

func _ready() -> void:
	super()
	
	hitbox = $CircleCollider
	
	var color_tuple: ColorTuple = PaintManager.unlockable_paints[paint_id]
	outline.modulate = color_tuple.outline
	fill.modulate = color_tuple.fill
