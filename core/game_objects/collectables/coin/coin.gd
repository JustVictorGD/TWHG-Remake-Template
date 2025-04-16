@tool
@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

# False by default because coins rarely move.
@export var motion_trail: bool = false
@export var constant_check: bool = false


func _ready() -> void:
	if not in_editor:
		if motion_trail:
			$GPUParticles2D.emitting = true
		
		if not registered:
			GameManager.money_requirement += 1
	
	# Call the _ready() function of the Collectable class.
	super()


func collect() -> void:
	super()
	
	GameManager.collected_money += 1
	Signals.coin_collected.emit()


func stay_collected() -> void:
	super()
	
	GameManager.collected_money += 1


func drop() -> void:
	super()
	
	Signals.coin_dropped.emit()
	GameManager.collected_money -= 1
