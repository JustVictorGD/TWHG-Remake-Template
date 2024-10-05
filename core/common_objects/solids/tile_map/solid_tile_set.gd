@tool
extends TileMapLayer

## If the node's owner is a node of the "Area" type, the area's theme gets
## referenced instead of the wall's outline and fill colors being set manually.
@export var copy_area_theme: bool = true
## Gets overridden if "copy_area_theme" is on.
@export var outline_color: Color = Color.BLACK
## Gets overridden if "copy_area_theme" is on.
@export var fill_color: Color = Color.WHITE


@onready var outline: TileMapLayer = $Outline
@onready var fill: TileMapLayer = $Fill

var previous_cells: Array[Vector2i] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		for cell: Vector2i in get_used_cells():
			Collider.walls.append(Rect2(
				Vector2(cell.x * 48 - 3, cell.y * 48 - 3) + global_position,
				Vector2(54, 54)))


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if GameManager.ghost:
			modulate.a = 0.5
		else:
			modulate.a = 1
	
	if copy_area_theme:
		if owner is Area:
			if owner.theme != null:
				outline.modulate = owner.theme.wall_outline
				fill.modulate = owner.theme.wall_fill
	else:
		outline.modulate = outline_color
		fill.modulate = fill_color
	
	var current_cells: Array[Vector2i] = get_used_cells()
	
	# Abort if the tiles haven't changed
	if current_cells == previous_cells:
		return
	
	outline.clear()
	fill.clear()
	
	for cell: Vector2i in current_cells:
		if cell not in previous_cells:
			pass
		
		outline.set_cell(cell, 0, Vector2i(0, 0))
		fill.set_cell(cell, 0, Vector2i(0, 0))
	
	outline.set_cells_terrain_connect(current_cells, 0, 0)
	fill.set_cells_terrain_connect(current_cells, 0, 0)
	
	previous_cells = current_cells
