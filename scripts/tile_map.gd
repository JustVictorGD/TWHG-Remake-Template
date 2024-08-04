extends TileMap

func _ready() -> void:
	Collider.wall_positions = get_used_cells(0)
