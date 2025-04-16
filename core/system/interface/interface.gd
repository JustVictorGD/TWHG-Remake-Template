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

@onready var screen_flash: AnimationPlayer = $ScreenFlash
@onready var update_deaths: AnimationPlayer = $UpdateDeaths
@onready var collect_money: AnimationPlayer = $CollectMoney
@onready var drop_money: AnimationPlayer = $DropMoney


func _ready() -> void:
	Signals.coin_collected.connect(coin_collected)
	Signals.player_death.connect(player_death)
	Signals.coin_dropped.connect(coin_dropped)


func coin_collected() -> void:
	collect_money.play("new_animation")


func player_death() -> void:
	update_deaths.play("new_animation")


func coin_dropped() -> void:
	drop_money.play("new_animation")


func _on_menu_pressed() -> void:
	GameManager.paused = not GameManager.paused


func _process(_delta : float) -> void:
	if not is_instance_valid(World.instance):
		return
	
	if not is_instance_valid(World.instance.active_level):
		return
	
	level_code.text = "Level: " + World.instance.active_level.level_code
	
	money.text = "$ " + str(GameManager.collected_money) + \
			" / " + str(GameManager.money_requirement)
	deaths.text = "Deaths: " + str(GameManager.deaths)
	
	if World.instance.active_level != null:
		bottom_text.text = World.instance.active_level.bottom_text
	
	timer.text = format_time(GameManager.time)
	tick_timer.text = ".%02d" % [GameManager.time % 60]
	fps.text = str(int(Engine.get_frames_per_second())) + " FPS"
	
	if GameManager.finished:
		timer.modulate = Color.GOLD
		tick_timer.modulate = Color.GOLD
	else:
		timer.modulate = Color.WHITE
		tick_timer.modulate = Color.WHITE
	
	if World.instance.active_level.theme != null:
		sides.modulate = World.instance.active_level.theme.interface_sides


static func format_time(total_ticks: int) -> String:
	@warning_ignore("integer_division")
	var hours: int = total_ticks / 216_000
	@warning_ignore("integer_division")
	var minutes: int = total_ticks / 3_600 % 60
	@warning_ignore("integer_division")
	var seconds: int = total_ticks / 60 % 60
	return str(hours) + ":%02d:%02d" % [minutes, seconds]
