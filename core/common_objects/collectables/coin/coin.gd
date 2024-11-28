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

func movement_update() -> void:
	hitbox.global_position = self.global_position
	hitbox.radius = self.global_scale.x * 13 # 13 units is the default scale of the coin.
	# This assumes that enemy scale.x and scale.y are equal as oval hitboxes are not implemented.
