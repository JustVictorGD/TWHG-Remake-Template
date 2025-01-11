extends Turret

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func fire_turret() -> void:
	position.y = rng.randf_range(96,864)
	rotation = rng.randf_range(-0.125, 0.125)
	super()
