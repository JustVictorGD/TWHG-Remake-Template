extends Control
class_name Interface

# Node references
@onready var level_code: Label = $LevelCode
@onready var money: Label = $Money
@onready var deaths: Label = $Deaths
@onready var fps: Label = $FPS
@onready var bottom_text: Label = $BottomText
@onready var timer: Label = $Timer
@onready var tick_timer: Label = $TickTimer

@onready var sides: Control = $Sides
@onready var flash: ColorRect = $Flash

@onready var flash_timer: TickBasedTimer = $FlashTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.button_down.connect(menu_click)
	
	Signals.level_switched.connect(flash_timer.reset_and_play)


func menu_click() -> void:
	GameManager.paused = not GameManager.paused


@warning_ignore("integer_division")
func format_time(total_ticks: int) -> String:
	var hours: int = total_ticks / 216_000
	var minutes: int = total_ticks / 3_600 % 60
	var seconds: int = total_ticks / 60 % 60
	return str(hours) + ":%02d:%02d" % [minutes, seconds]


func _process(_delta : float) -> void:
	level_code.text = "Level: " + World.active_level.level_code
	
	money.text = "$ " + str(World.collected_money) + \
			" / " + str(World.money_requirement)
	deaths.text = "Deaths: " + str(GameManager.deaths)
	
	if World.active_level != null:
		bottom_text.text = World.active_level.bottom_text
	
	timer.text = format_time(GameManager.time)
	tick_timer.text = ".%02d" % [GameManager.time % 60]
	fps.text = str(Engine.get_frames_per_second()) + " FPS"
	
	if GameManager.finished:
		timer.modulate = Color.GOLD
		tick_timer.modulate = Color.GOLD
	else:
		timer.modulate = Color.WHITE
		tick_timer.modulate = Color.WHITE
	
	flash.color.a = flash_timer.get_progress_left()
	
	if World.active_level.theme != null:
		sides.modulate = World.active_level.theme.interface_sides
