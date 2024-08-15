extends Collectable

@export var lock_scale: bool = true
@export var lock_rotation: bool = true

var radius: int = 13

var id: int

func _ready() -> void:
	collect_sound = "Coin"
	
	GameLoop.movement_update.connect(movement_update)
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	
	# This is how collision works here.
	id = Collider.register_coin_id(self)

func movement_update() -> void:
	if lock_scale:
		global_scale = Vector2(1, 1)
	if lock_rotation:
		global_rotation = 0

func extra_collect() -> void:
	AreaManager.money += 1

func extra_drop() -> void:
	AreaManager.money -= 1

func checkpoint_touched(_id: int) -> void:
	if state == states.PICKED_UP:
		state = states.SAVED
