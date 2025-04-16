extends AudibleButton
class_name PaintButton

var id: int

@onready var outline: Control = $Outline
@onready var fill: ColorRect = $Fill
@onready var selected_outline: Control = $Selected
@onready var locked_icon: Control = $Locked

func _ready() -> void:
	button_down.connect(on_click)
	
	fill.modulate = PaintManager.coatings[id].fill
	outline.modulate = PaintManager.coatings[id].outline


func _process(delta: float) -> void:
	if id == -1 or PaintManager.coating_progress[id] > 0:
		disabled = false
		locked_icon.visible = false
	else:
		disabled = true
		locked_icon.visible = true
	
	if PaintManager.current_coating == id:
		selected_outline.visible = true
	else:
		selected_outline.visible = false


func on_click() -> void:
	PaintManager.current_coating = id
	Signals.paint_changed.emit(id) # Does this for now, will make it actually change the player color tomorrow
