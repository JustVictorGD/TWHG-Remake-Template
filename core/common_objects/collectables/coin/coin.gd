@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin


func _ready() -> void:
	# Call the _ready() function of the Collectable class.
	super()
	
	$GPUParticles2D.emitting = true
	hitbox = $CircleCollider
	World.money_requirement += 1


func collect() -> void:
	super()
	
	World.collected_money += 1
	GlobalSignal.coin_collected.emit()


func stay_collected() -> void:
	super()
	
	World.collected_money += 1


func drop() -> void:
	super()
	
	World.collected_money -= 1
