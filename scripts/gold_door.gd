extends Door

@export var money_requirement: int = 0
@onready var money_left_text: Label = $MoneyLeft

var money_left: int

func extra_update_timers() -> void:
	money_left = money_requirement - AreaManager.money
	money_left_text.text =  "$" + str(money_left)
	
	if money_left <= 0:
		money_left_text.modulate.a = 0
	else:
		money_left_text.modulate.a = 1
	
	if money_requirement == 0:
		money_requirement = AreaManager.max_money
	
	if AreaManager.money >= money_requirement:
		trigger_door()
