extends TextureButton
class_name PaintButton

var paint_id: int

func _ready() -> void:
	button_down.connect(on_click)
	#await get_parent().ready
	#custom_minimum_size = Vector2(24, 24)
	
	if paint_id == -1:
		self_modulate = PaintManager.default_player.fill
		change_outline_modulate(PaintManager.default_player.outline)
	else:
		self_modulate = PaintManager.unlockable_paints[paint_id].fill
		change_outline_modulate(PaintManager.unlockable_paints[paint_id].outline)
		

func on_click() -> void:
	print(paint_id) # Does this for now, will make it actually change the player color tomorrow

func change_outline_modulate(color: Color) -> void:
	print(color)
	for child: Node in get_children():
		child.color = color
