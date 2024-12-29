extends TextureButton
class_name PaintButton

var paint_id: int

func _ready() -> void:
	button_down.connect(on_click)
	await get_parent().ready
	custom_minimum_size = Vector2(50, 50)
	
	if paint_id == -1:
		modulate = PaintManager.default_player.fill 
	else:
		modulate = PaintManager.unlockable_paints[paint_id].fill

func on_click() -> void:
	print(paint_id) # Does this for now, will make it actually change the player color tomorrow
