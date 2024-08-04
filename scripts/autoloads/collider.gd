extends Node




const GAMEPLAY_SCALE: float = 0.625
const GAMEPLAY_POSITION: Vector2 = Vector2(160, 60)

# Objects
const ENEMY_RADIUS: float = 7
const COIN_RADIUS: float = 16
const WALL_SIZE: Vector2 = Vector2(54, 54)

var touched_checkpoint_ids: PackedInt32Array = []
var wall_positions: PackedVector2Array = []

var enemies: PackedVector2Array = []
var coins: PackedVector2Array = []
var checkpoints: Array[Rect2] = []

# Assigning unique IDs to objects
var next_enemy_id: int = -1
var next_checkpoint_id: int = -1
var next_coin_id: int = -1

# These functions return a unique ID for the given object type,
# and create more space to store their information in corresponding arrays.
func register_enemy_id() -> int:
	enemies.append(Vector2(NAN, NAN))
	next_enemy_id += 1
	return next_enemy_id

func register_checkpoint_id() -> int:
	checkpoints.append(Rect2(NAN, NAN, NAN, NAN))
	next_checkpoint_id += 1
	return next_checkpoint_id

func register_coin_id() -> int:
	coins.append(Vector2(NAN, NAN))
	next_coin_id += 1
	return next_coin_id
