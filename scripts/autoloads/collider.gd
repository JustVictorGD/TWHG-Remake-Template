extends Node


# Objects
const WALL_SIZE: Vector2 = Vector2(54, 54)

var touched_checkpoint_ids: PackedInt32Array = []
var wall_positions: PackedVector2Array = []

var enemies: Array[Node] = []
var coins: Array[Node] = []
var checkpoints: Array[Node] = []

# Assigning unique IDs to objects
var next_enemy_id: int = -1
var next_checkpoint_id: int = -1
var next_coin_id: int = -1

# These functions return a unique ID for the given object type,
# and create more space to store their information in corresponding arrays.
func register_enemy_id(node: Node) -> int:
	enemies.append(node)
	next_enemy_id += 1
	return next_enemy_id

func register_checkpoint_id(node: Node) -> int:
	checkpoints.append(node)
	next_checkpoint_id += 1
	return next_checkpoint_id

func register_coin_id(node: Node) -> int:
	coins.append(node)
	next_coin_id += 1
	AreaManager.max_money += 1
	return next_coin_id


# Purely convenient functions.
func get_center(rect: Rect2) -> Vector2:
	return rect.position + rect.size / 2

func point_in_rect(position: Vector2, rect: Rect2) -> bool:
	if position.x >= rect.position.x and position.x <= rect.end.x and \
			position.y >= rect.position.y and position.y <= rect.end.y:
		return true
	return false

func rect_and_circle_overlap(rect: Rect2, circle_pos: Vector2, circle_radius: float) -> bool:
	var closest_point: Vector2 = Vector2(NAN, NAN)
	closest_point.x = clamp(circle_pos.x, rect.position.x, rect.end.x)
	closest_point.y = clamp(circle_pos.y, rect.position.y, rect.end.y)
	
	var distance: float = circle_pos.distance_to(closest_point)
	return distance < circle_radius
