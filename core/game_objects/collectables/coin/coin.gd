@tool
@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

# False by default because coins rarely move.
@export var motion_trail: bool = false
@export var constant_check: bool = false


func _ready() -> void:
	if motion_trail:
		$GPUParticles2D.emitting = true
	
	hitbox = $CircleCollider
	
	if not registered:
		World.money_requirement += 1
	
	# Call the _ready() function of the Collectable class.
	super()


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
