@icon("res://core/misc_assets/images/node_icons/coin.png")
extends Collectable
class_name Coin

@onready var hitbox: CircleCollider = $CircleCollider

var id: int

func _ready() -> void:
	collect_sound = "Coin"
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	
	World.money_requirement += 1

func extra_collect() -> void:
	World.collected_money += 1
	GlobalSignal.coin_collected.emit()

func extra_drop() -> void:
	World.collected_money -= 1

func checkpoint_touched(_id: int) -> void:
	save()
