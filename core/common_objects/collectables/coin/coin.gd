@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

var coin_states: Array

func _ready() -> void:
	# Call the _ready() function of the Collectable class.
	super()
	
	hitbox = $CircleCollider
	World.money_requirement += 1
	
	await GlobalSignal.collectables_processed
	coin_states = SaveFile.save_dictionary["levels"][GameManager.current_level]["coins"]
	
	
	#state = coin_states[id]
	#if state == states.SAVED:
		#stay_collected()




func collect() -> void:
	super()
	
	World.collected_money += 1
	GlobalSignal.coin_collected.emit()
	
	


func drop() -> void:
	super()
	
	World.collected_money -= 1
