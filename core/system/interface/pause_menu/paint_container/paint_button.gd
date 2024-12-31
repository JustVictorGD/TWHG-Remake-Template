extends Button
class_name PaintButton

var paint_id: int

@onready var outline: Control = $Outline
@onready var fill: ColorRect = $Fill
@onready var selected_outline: Control = $Selected
@onready var locked_icon: Control = $Locked

#PaintManager.paint_progress

func _ready() -> void:
	button_down.connect(on_click)
	
	if paint_id == -1:
		fill.modulate = PaintManager.default_player.fill
		outline.modulate = PaintManager.default_player.outline
	else:
		fill.modulate = PaintManager.unlockable_paints[paint_id].fill
		outline.modulate = PaintManager.unlockable_paints[paint_id].outline
		


func _process(delta: float) -> void:
	if paint_id == -1 or PaintManager.paint_progress[paint_id] > 0:
		disabled = false
		locked_icon.visible = false
	else:
		disabled = true
		locked_icon.visible = true
	
	if PaintManager.current_paint_id == paint_id:
		selected_outline.visible = true
	else:
		selected_outline.visible = false


func on_click() -> void:
	PaintManager.current_paint_id = paint_id
	GlobalSignal.paint_changed.emit(paint_id) # Does this for now, will make it actually change the player color tomorrow
