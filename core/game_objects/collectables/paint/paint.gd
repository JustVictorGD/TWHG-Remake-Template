@icon("res://core/misc_assets/images/node_icons/paint.png")
@tool
extends Collectable
class_name Paint

@export var coating_id: int = 0

var color_tuple: ColorTuple:
	get:
		return PaintManager.get_coating(coating_id)

var is_ghost: bool = false


func _process(_delta: float) -> void:
	if sprite == null:
		print("What have you done to make a paint lack its sprite node?")
		return
	
	sprite.outline_color = color_tuple.outline
	sprite.fill_color = color_tuple.fill
	sprite.update_colors()
	
	if not in_editor and state == States.UNCOLLECTED:
		if PaintManager.get_coating(coating_id) != PaintManager.error_coating and \
				PaintManager.coating_progress[coating_id] != 0:
			opacity_multiplier = 0.5
		else:
			opacity_multiplier = 1
		
		sprite.set_opacity(opacity_multiplier)


func collect() -> void:
	super()
	
	if PaintManager.get_progress(coating_id) == -1 or \
			PaintManager.coating_progress[coating_id] == 2:
		return # Handle error and abort if already
		# saved to prevent downgrading from 2 to 1.
	
	if save_behavior != SaveBehaviors.AUTOMATIC_SAVE:
		PaintManager.coating_progress[coating_id] = 1 # Set to collected.
	else:
		PaintManager.coating_progress[coating_id] = 2 # Set to saved.


func drop() -> void:
	super()
	
	if PaintManager.get_progress(coating_id) == 1:
		PaintManager.coating_progress[coating_id] = 0


func save() -> void:
	super()
	
	if PaintManager.get_progress(coating_id) == 1:
		if save_behavior != SaveBehaviors.UNSAVABLE:
			PaintManager.coating_progress[coating_id] = 2


func stay_collected() -> void:
	Utilities.disable_area(hitbox)
	
	state = States.SAVED
	sprite.set_opacity(0)
	
	if PaintManager.get_progress(coating_id) != -1:
		PaintManager.coating_progress[coating_id] = 2
