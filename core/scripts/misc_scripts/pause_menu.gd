extends Control

func _ready() -> void:
	$ReturnToGame.button_down.connect(return_to_game_click)
	$MusicToggle.button_down.connect(music_click)
	$SFXToggle.button_down.connect(sfx_click)

func return_to_game_click() -> void:
	GameManager.toggle_pause()

func music_click() -> void:
	GameManager.music_enabled = not GameManager.music_enabled
	print("Music toggle")
	if GameManager.music_enabled:
		$MusicToggle.text = "Music (on)"
	else:
		$MusicToggle.text = "Music (off)"

func sfx_click() -> void:
	GameManager.sfx_enabled = not GameManager.sfx_enabled
	print("Music toggle")
	if GameManager.sfx_enabled:
		$SFXToggle.text = "SFX (on)"
	else:
		$SFXToggle.text = "SFX (off)"

func _process(_delta: float) -> void:
	if GameManager.paused:
		self.visible = true
	else:
		self.visible = false
