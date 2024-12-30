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


func collect() -> void:
	super()
	
	if PaintManager.paint_progress[paint_id] == 2:
		return # Abort if already saved to prevent downgrading from 2 to 1.
	
	if save_behavior != save_behaviors.AUTOMATIC_SAVE:
		PaintManager.paint_progress[paint_id] = 1 # Set to collected.
	else:
		PaintManager.paint_progress[paint_id] = 2 # Set to saved.


func drop() -> void:
	super()
	
	if PaintManager.paint_progress[paint_id] == 1:
		PaintManager.paint_progress[paint_id] = 0


func save() -> void:
	super()
	
	if PaintManager.paint_progress[paint_id] == 1:
		if save_behavior != save_behaviors.UNSAVABLE:
			PaintManager.paint_progress[paint_id] = 2


func stay_collected() -> void:
	hitbox.enabled = false
	state = states.SAVED
	sprite.set_opacity(0)


func _process(_delta: float) -> void:
	if sprite == null:
		print("What have you done to make a paint lack its sprite node?")
		return
	
	if color_tuple != null:
		sprite.outline_color = color_tuple.outline
		sprite.fill_color = color_tuple.fill
		
		# For some reason all paints are green if I don't add this update.
		update_colors()
	
	# This already causes the error "Out of bounds get index '{paint_id}'
	# (on base: 'Array[ColorTuple]')" which is why a push_error() isn't added.
	else:
		sprite.outline_color = Color.BLACK
		sprite.fill_color = Color.MAGENTA
	
	if not in_editor and state == states.UNCOLLECTED:
		if PaintManager.paint_progress[paint_id] != 0:
			opacity_multiplier = 0.5
		else:
			opacity_multiplier = 1
		
		sprite.set_opacity(opacity_multiplier)
	
	super(_delta)
