extends Collectable

@export var lock_scale: bool = true
@export var lock_rotation: bool = true

var id: int

func _ready() -> void:
	GameLoop.movement_update.connect(movement_update)
	GlobalSignal.coin_collected.connect(any_coin_collected)
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	
	# This is how collision works here.
	id = Collider.register_coin_id()

func movement_update() -> void:
	if state == states.UNCOLLECTED:
		Collider.coins[id] = round(NiceFunctions.global_to_normal_position(self.global_position))
	else:
		Collider.coins[id] = Vector2(NAN, NAN)
	
	if lock_scale:
		global_scale.x = Collider.GAMEPLAY_SCALE
		global_scale.y = Collider.GAMEPLAY_SCALE
	if lock_rotation:
		global_rotation = 0

func any_coin_collected(given_id: int) -> void:
	if given_id == id:
		SFX.play("Coin")
		collect()

func checkpoint_touched(_id: int) -> void:
	if state == states.PICKED_UP:
		state = states.SAVED
