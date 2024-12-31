extends Node

@export var default_player: ColorTuple
@export var ghost_tint: Color = Color(Color.WHITE, 0.2)
@export var unlockable_paints: Array[ColorTuple] = []

var paint_progress: PackedInt32Array = []
var current_paint_id: int = -1


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for i: int in range(unlockable_paints.size()):
		paint_progress.append(0)
