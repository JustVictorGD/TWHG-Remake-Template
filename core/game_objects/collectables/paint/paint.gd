@icon("res://core/misc_assets/images/node_icons/paint.png")
@tool
extends Collectable
class_name Paint

@export var paint_id: int = 0

var color_tuple: ColorTuple:
	get:
		return PaintManager.unlockable_paints[paint_id]

var is_ghost: bool = false


func _ready() -> void:
	super()
	hitbox = $CircleCollider


func stay_collected() -> void:
	hitbox.enabled = false
	is_ghost = true


func _process(_delta: float) -> void:
	if sprite == null:
		print("What have you done to make a paint lack its sprite node?")
		return
	
	if color_tuple != null:
		sprite.outline_color = color_tuple.outline
		sprite.fill_color = color_tuple.fill
		
		# For some reason all paints are green if I don't add this update.
		update_colors()
	
	else:
		push_error("Paint ID ", paint_id, " doesn't exist.")
		sprite.outline_color = Color.BLACK
		sprite.fill_color = Color.MAGENTA
	
	if is_ghost:
		sprite.set_opacity(0.5)
	
	super(_delta)
