extends Button
class_name PaintButton

var paint_id: int
var unlocked: bool = false

@onready var outline: Control = $Outline
@onready var fill: ColorRect = $Fill

func _ready() -> void:
	button_down.connect(on_click)
	
	if paint_id == -1:
		unlocked = true
		fill.modulate = PaintManager.default_player.fill
		outline.modulate = PaintManager.default_player.outline
	else:
		fill.modulate = PaintManager.unlockable_paints[paint_id].fill
		outline.modulate = PaintManager.unlockable_paints[paint_id].outline
		


func _process(delta: float) -> void:
	pass


func on_click() -> void:
	GlobalSignal.paint_changed.emit(paint_id) # Does this for now, will make it actually change the player color tomorrow
