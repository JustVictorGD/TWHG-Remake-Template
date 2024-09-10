@tool
extends Door

## Values above 0 define the requirement directly.
## Values equal or less than 0 result in the requirement copying
## the total amount of money and being offset by the set value.
@export var money_requirement: int = 0

func child_child_ready() -> void:
	if not Engine.is_editor_hint():
		GlobalSignal.coin_collected.connect(coin_collected)
		GlobalSignal.player_respawn.connect(player_respawn)
		
		if money_requirement <= 0:
			money_requirement += GameManager.max_money

func coin_collected() -> void:
	if GameManager.money >= money_requirement:
		trigger_door()

func player_respawn() -> void:
	if GameManager.money < money_requirement:
		untrigger_door()
