@tool
extends Door
class_name GoldDoor

## Values > 0 define the requirement directly.
## Values <= 0 copy the total amount of money
## in the level and optionally offset it.
@export var money_requirement: int = 0


func child_child_ready() -> void:
	if not Engine.is_editor_hint():
		GlobalSignal.coin_collected.connect(coin_collected)
		GlobalSignal.player_respawn.connect(player_respawn)
		
		if money_requirement <= 0:
			money_requirement += World.money_requirement


func coin_collected() -> void:
	if World.collected_money >= money_requirement:
		trigger_door()


func player_respawn() -> void:
	if World.collected_money < money_requirement:
		untrigger_door()
