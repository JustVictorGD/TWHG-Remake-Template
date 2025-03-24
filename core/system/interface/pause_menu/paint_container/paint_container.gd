extends FlowContainer


func _ready() -> void:
	for i: int in range(PaintManager.coatings.size()):
		var scene: PackedScene = load("res://core/system/interface/pause_menu/paint_container/paint_button.tscn")
		var paint_button: PaintButton = scene.instantiate()
		paint_button.id = i
		add_child(paint_button)
