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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameLoop.update_timers.connect(update_timers)
	
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
	$Money.text = "$ " + str(GameManager.money) + " / " + str(GameManager.max_money)
	$Deaths.text = "Deaths: " + str(GameManager.deaths)
	$Timer.text = str(hours) + (":%02d:%02d" % [minutes, seconds])
	$Timer2.text = ".%03d" % [ticks]
	$FPS.text = str(Engine.get_frames_per_second()) + " FPS"
	
	if GameManager.finished:
		$Timer.modulate = Color.GOLD
		$Timer2.modulate = Color.GOLD
