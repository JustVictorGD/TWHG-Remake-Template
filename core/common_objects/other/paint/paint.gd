@tool
extends Collectable
class_name Paint

@export var outline_color: Color = Color(0, 0.3, 0)
@export var fill_color: Color = Color(0, 0.75, 0)

@onready var outline: Sprite2D = $Outline
@onready var fill: Sprite2D = $Fill
@onready var hitbox: CircleCollider = $CircleCollider


func _ready() -> void:
	collect_sound = "Paint"


func _process(delta: float) -> void:
	outline.modulate = outline_color
	fill.modulate = fill_color
