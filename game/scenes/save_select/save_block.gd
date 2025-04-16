extends AudibleButton
class_name SaveBlock

@onready var animation_player: AnimationPlayer = $Flash/AnimationPlayer
@onready var background: ColorRect = $Background
@onready var label: Label = $Label
@onready var no_data: Label = $NoData
@onready var stage: Label = $Stage
@onready var deaths: Label = $Deaths
@onready var time: Label = $Time

@export var id: int = 0


func _ready() -> void:
	label.text = "SAVE " + str(id)


func update(exists: bool, flash: bool) -> void:
	no_data.visible = not exists
	stage.visible = exists
	deaths.visible = exists
	time.visible = exists
	
	background.color = Color.WHITE if exists else Color(0.6, 0.6, 0.6)
	
	if flash:
		animation_player.play("new_animation")
