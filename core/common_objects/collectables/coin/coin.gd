@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

@onready var hitbox: CircleCollider = $CircleCollider

var id: int

var coin_states: Array

func _ready() -> void:
	# Call the _ready() function of the Collectable class.
	super()
	
	World.money_requirement += 1
	
	await GlobalSignal.coins_processed
	coin_states = SaveFile.save_dictionary["levels"][GameManager.current_level]["coins"]
	
	
	state = coin_states[id]
	if state == states.SAVED:
		stay_collected()




func collect() -> void:
	super()
	
	World.collected_money += 1
	GlobalSignal.coin_collected.emit()
	coin_states[id] = state
	


func drop() -> void:
	super()
	
	World.collected_money -= 1
	coin_states[id] = state

func save() -> void:
	super()
	
	coin_states[id] = state
	
	
