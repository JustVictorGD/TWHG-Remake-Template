extends Control

var music_index: int
var sfx_index: int

var fps_values: Array = [60, 120, 240]
var fps_value_index: int = 0

func _ready() -> void:
	$ReturnToGame.button_down.connect(return_to_game_click)
	$MusicToggle.button_down.connect(music_click)
	$SFXToggle.button_down.connect(sfx_click)
	$MaxFPS.button_down.connect(max_fps_click)
	$MovementType.button_down.connect(movement_type_click)
	
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	$MusicVolumeSlider.value_changed.connect(music_value_changed)
	$SFXVolumeSlider.value_changed.connect(sfx_value_changed)

func return_to_game_click() -> void:
	GameManager.paused = not GameManager.paused

func music_click() -> void:
	AudioServer.set_bus_mute(music_index, not AudioServer.is_bus_mute(music_index))
	
	if AudioServer.is_bus_mute(music_index):
		$MusicToggle/State.text = "(off)"
		$MusicVolumeSlider.editable = false
	else:
		$MusicToggle/State.text = "(on)"
		$MusicVolumeSlider.editable = true
	

func sfx_click() -> void:
	AudioServer.set_bus_mute(sfx_index, not AudioServer.is_bus_mute(sfx_index))
	
	if AudioServer.is_bus_mute(sfx_index):
		$SFXToggle/State.text = "(off)"
		$SFXVolumeSlider.editable = false
	else:
		$SFXToggle/State.text = "(on)"
		$SFXVolumeSlider.editable = true
	
	

func max_fps_click() -> void:
	if fps_value_index == fps_values.size() - 1:
		fps_value_index = 0
	else:
		fps_value_index += 1
	
	Engine.max_fps = fps_values[fps_value_index]
	
	$MaxFPS/State.text = "(" + str(Engine.max_fps) + ")"

func movement_type_click() -> void:
	GameManager.snappy_movement = not GameManager.snappy_movement
	
	if GameManager.snappy_movement:
		$MovementType/State.text = "Snappy"
	else:
		$MovementType/State.text = "Default"

func music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_index, linear_to_db(value))

func sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))

func _process(_delta: float) -> void:
	if GameManager.paused:
		self.visible = true
	else:
		self.visible = false
