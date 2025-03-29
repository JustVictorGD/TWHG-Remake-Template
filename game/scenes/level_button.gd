@tool
extends Button
class_name LevelButton

@export var level_code: String
@export var visible_number: String = "?"
@export var outline_color: Color = Color(0.5, 0.5, 0.5, 1)
@export var fill_color: Color = Color.WHITE

@onready var in_editor: bool = Engine.is_editor_hint()

@onready var outline: ColorRect = $Outline
@onready var fill: ColorRect = $Fill
@onready var label: Label = $Label
@onready var locked: ColorRect = $Locked


func _ready() -> void:
	update()


func _pressed() -> void:
	GameManager.current_level = level_code
	SaveData.save_game()
	
	get_tree().change_scene_to_packed(load("res://game/scenes/world.tscn"))


func _process(delta: float) -> void:
	if in_editor:
		update()


func update() -> void:
	label.text = visible_number
	outline.color = outline_color
	fill.color = fill_color


func toggle(state: bool) -> void:
	$Locked.visible = not state
	disabled = not state
