extends TileMapLayer

func _ready() -> void:
	for cell: Vector2i in get_used_cells():
		Collider.walls.append(Rect2(Vector2(cell.x * 48 - 3, cell.y * 48 - 3), Vector2(54, 54)))
