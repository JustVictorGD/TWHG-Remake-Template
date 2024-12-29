extends Node

@export var default_player: ColorTuple
@export var ghost_tint: Color = Color(Color.WHITE, 0.2)
@export var unlockable_paints: Array[ColorTuple] = []

var paint_progress: PackedInt32Array = []


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for i: int in range(unlockable_paints.size()):
		paint_progress.append(0)
	
	print("paint_progress: ", paint_progress)
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	GlobalSignal.player_respawn.connect(player_respawn)


func checkpoint_touched(_id: int) -> void:
	for i: int in range(paint_progress.size()):
		if paint_progress[i] == 1:
			paint_progress[i] = 2


func player_respawn() -> void:
	for i: int in range(paint_progress.size()):
		if paint_progress[i] == 1:
			paint_progress[i] = 0
