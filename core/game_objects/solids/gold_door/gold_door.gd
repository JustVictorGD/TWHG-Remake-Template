@icon("res://core/misc_assets/images/node_icons/gold_door.png")
@tool
extends Door
class_name GoldDoor

## Values > 0 define the requirement directly.
## Values <= 0 copy the total amount of money
## in the level and optionally offset it.
@export var money_requirement: int = 0


func _ready() -> void:
	super()
	
	if not Engine.is_editor_hint():
		Signals.coin_collected.connect(coin_collected)
		Signals.player_respawn.connect(player_respawn)
		
		if money_requirement <= 0:
			money_requirement += GameManager.money_requirement
		
		if GameManager.collected_money >= money_requirement:
			stay_triggered()


func coin_collected() -> void:
	if GameManager.collected_money >= money_requirement:
		trigger_door()


func player_respawn() -> void:
	if GameManager.collected_money < money_requirement:
		untrigger_door()
