extends Collectable

var radius: int = 13

var id: int

func _ready() -> void:
	collect_sound = "Coin"
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	# This is how collision works here.
	id = Collider.register_coin_id(self)

func extra_collect() -> void:
	AreaManager.money += 1

func extra_drop() -> void:
	AreaManager.money -= 1

func checkpoint_touched(_id: int) -> void:
	save()
