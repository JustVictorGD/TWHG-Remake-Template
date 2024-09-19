extends Control

enum themes {
	BLUE,
	PURPLE,
	RED,
	BLACK
}

var area_theme: themes = themes.BLUE

# Time
var ticks: int = 0
var seconds: int = 0
var minutes: int = 0
var hours: int = 0

# Node references
@onready var area: Label = $Area
@onready var money: Label = $Money
@onready var deaths: Label = $Deaths
@onready var fps: Label = $FPS
@onready var bottom_text: Label = $BottomText
@onready var timer: Label = $Timer
@onready var tick_timer: Label = $TickTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameLoop.update_timers.connect(update_timers)
	$Menu.button_down.connect(menu_click)
	
	if area_theme == themes.BLUE:
		pass
	elif area_theme == themes.PURPLE:
		$ColorRect5.color = Color.html("502080")
		$ColorRect6.color = Color.html("502080")
	elif area_theme == themes.RED:
		$ColorRect5.color = Color.html("602020")
		$ColorRect6.color = Color.html("602020")
	else:
		$ColorRect5.color = Color.html("303030")
		$ColorRect6.color = Color.html("303030")

func menu_click() -> void:
	GameManager.toggle_pause()

func update_timers() -> void:
	if not GameManager.finished:
		ticks += 1
		
		while ticks >= 240:
			ticks -= 240
			seconds += 1
		
		while seconds >= 60:
			seconds -= 60
			minutes += 1
		
		while minutes >= 60:
			minutes -= 60
			hours += 1

func _process(_delta : float) -> void:
	money.text = "$ " + str(GameManager.money) + " / " + str(GameManager.max_money)
	deaths.text = "Deaths: " + str(GameManager.deaths)
	timer.text = str(hours) + (":%02d:%02d" % [minutes, seconds])
	tick_timer.text = ".%03d" % [ticks]
	fps.text = str(Engine.get_frames_per_second()) + " FPS"
	
	if GameManager.finished:
		timer.modulate = Color.GOLD
		tick_timer.modulate = Color.GOLD
