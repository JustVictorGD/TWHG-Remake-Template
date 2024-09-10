extends Collectable

var hitbox: CircleCollider = CircleCollider.new(Vector2.ZERO, 13)

var id: int

func _ready() -> void:
	collect_sound = "Coin"
	
	GlobalSignal.checkpoint_touched.connect(checkpoint_touched)
	# This is how collision works here.
	id = Collider.register_coin_id(self)

func extra_collect() -> void:
	GameManager.money += 1
	GlobalSignal.coin_collected.emit()

func extra_drop() -> void:
	GameManager.money -= 1

func checkpoint_touched(_id: int) -> void:
	save()

func movement_update() -> void:
	hitbox.position = self.global_position
