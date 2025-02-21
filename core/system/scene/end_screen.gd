extends Node2D

@onready var flash: ColorRect = $Flash
@onready var flash_timer: TickBasedTimer = $TickBasedTimer


func _ready() -> void:
	$Button.pressed.connect(on_button_pressed)
	GameManager.current_level = World.starting_level_static
	
	$FinalDeaths.text = str("Final deaths: ", GameManager.deaths)
	$FinalTime.text = "Final time: " + format_time(GameManager.time)


func _process(delta: float) -> void:
	flash.color.a = flash_timer.get_progress_left()


func on_button_pressed() -> void:
	GameManager.reset_stats()
	
	get_tree().change_scene_to_packed(load("res://game/scenes/world.tscn"))


@warning_ignore("integer_division")
func format_time(total_ticks: int) -> String:
	var hours: int = total_ticks / 216_000
	var minutes: int = total_ticks / 3_600 % 60
	var seconds: int = total_ticks / 60 % 60
	var ticks: int = total_ticks % 60
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, ticks]
