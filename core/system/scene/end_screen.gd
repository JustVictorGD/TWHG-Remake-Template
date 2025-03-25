extends Node2D

@onready var flash: ColorRect = $Flash
@onready var flash_timer: TickBasedTimer = $TickBasedTimer


func _ready() -> void:
	$Button.pressed.connect(on_button_pressed)
	GameManager.current_level = GameManager.starting_level_code
	
	$FinalDeaths.text = str("Final deaths: ", GameManager.deaths)
	$FinalTime.text = "Final time: " + format_time(GameManager.time)


func _process(delta: float) -> void:
	flash.color.a = flash_timer.get_progress_left()


func on_button_pressed() -> void:
	GameManager.reset_stats()
	SaveData.wipe_save(0)
	SaveData.load_game(0)
	
	get_tree().change_scene_to_packed(load("res://game/scenes/world.tscn"))


func format_time(total_ticks: int) -> String:
	@warning_ignore("integer_division")
	var hours: int = total_ticks / 216_000
	@warning_ignore("integer_division")
	var minutes: int = total_ticks / 3_600 % 60
	@warning_ignore("integer_division")
	var seconds: int = total_ticks / 60 % 60
	var ticks: int = total_ticks % 60
	return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, ticks]
