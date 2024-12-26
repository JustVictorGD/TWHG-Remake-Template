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

@onready var ticks: int = GameLoop.ticks
var seconds: int = 0
var minutes: int = 0
var hours: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameLoop.update_timers.connect(update_timers)
	$Menu.button_down.connect(menu_click)
	
	GlobalSignal.level_switched.connect(flash_timer.reset_and_play)


func menu_click() -> void:
	GameManager.paused = not GameManager.paused


func update_timers() -> void:
	if not GameManager.finished:
		ticks += 1
	
	while ticks >= 60:
		ticks -= 60
		seconds += 1
	
	while seconds >= 60:
		seconds -= 60
		minutes += 1
	
	while minutes >= 60:
		minutes -= 60
		hours += 1


func _process(_delta : float) -> void:
	level_code.text = "Level: " + World.current_level.level_code
	
	money.text = "$ " + str(World.collected_money) + \
			" / " + str(World.money_requirement)
	deaths.text = "Deaths: " + str(GameManager.deaths)
	
	if World.current_level != null:
		bottom_text.text = World.current_level.bottom_text
		
	timer.text = str(hours) + (":%02d:%02d" % [minutes, seconds])
	tick_timer.text = ".%02d" % [ticks]
	fps.text = str(Engine.get_frames_per_second()) + " FPS"
	
	if GameManager.finished:
		timer.modulate = Color.GOLD
		tick_timer.modulate = Color.GOLD
	else:
		timer.modulate = Color.WHITE
		tick_timer.modulate = Color.WHITE
	
	flash.color.a = flash_timer.get_progress_left()
	
	if World.current_level.theme != null:
		sides.modulate = World.current_level.theme.interface_sides
