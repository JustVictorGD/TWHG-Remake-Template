extends Control

enum themes {
	BLUE,
	PURPLE,
	RED,
	BLACK
}

var area_theme : int = themes.BLUE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func _process(_delta : float) -> void:
	$Deaths.text = "Deaths: " + str(AreaManager.deaths)
	$Timer.text = GameLoop.time_string
	$Timer2.text = GameLoop.tick_string
