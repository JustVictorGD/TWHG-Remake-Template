extends FlowContainer

func _ready() -> void:
	for i: int in range(PaintManager.unlockable_paints.size() + 1):
		var scene: PackedScene = load("res://core/system/interface/pause_menu/paint_container/paint_button.tscn")
		var paint_button: PaintButton = scene.instantiate()
		paint_button.paint_id = i - 1
		add_child(paint_button)
